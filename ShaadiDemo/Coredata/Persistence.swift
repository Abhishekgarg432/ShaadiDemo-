//
//  Persistence.swift
//  ShaadiDemo
//
//  Created by Abhishek Garg on 9/26/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ShaadiDemo")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func fetchAllProfiles() throws -> [CDProfile] {
        let ctx = container.viewContext
        let req = NSFetchRequest<CDProfile>(entityName: "CDProfile")
        req.sortDescriptors = [NSSortDescriptor(key: "fullName", ascending: true)]
        return try ctx.fetch(req)
    }
    
    func getProfileCount() throws -> Int {
        let ctx = container.viewContext
        let req = NSFetchRequest<CDProfile>(entityName: "CDProfile")
        return try ctx.count(for: req)
    }
    
    func upsertProfiles(_ items: [NetworkProfile]) throws {
        let ctx = container.viewContext
        
        // First, clean up any existing duplicates before inserting new data
        try removeDuplicateProfiles()
        
        for item in items {
            // Try to find an existing object by id.
            let fetch = NSFetchRequest<CDProfile>(entityName: "CDProfile")
            fetch.predicate = NSPredicate(format: "id == %@", item.id)
            fetch.fetchLimit = 1
            let existing = try ctx.fetch(fetch).first
            
            if let existing = existing {
                // Update existing profile with latest data (but preserve user decisions)
                existing.fullName = item.fullName
                existing.age = Int16(item.age)
                existing.city = item.city
                existing.imageURL = item.imageURL.absoluteString
                existing.updatedAt = Date()
            } else {
                // Only create new profile if it doesn't exist
                let obj = CDProfile(entity: ctx.persistentStoreCoordinator!.managedObjectModel.entitiesByName["CDProfile"]!, insertInto: ctx)
                
                // Map network fields → storage fields.
                obj.id = item.id
                obj.fullName = item.fullName
                obj.age = Int16(item.age)
                obj.city = item.city
                obj.imageURL = item.imageURL.absoluteString
                obj.status = DecisionStatus.none.rawValue
                obj.updatedAt = Date()
            }

        }
        if ctx.hasChanges { try ctx.save() }
    }
    
    func setDecision(id: String, status: DecisionStatus) throws {
         let ctx = container.viewContext
         let fetch = NSFetchRequest<CDProfile>(entityName: "CDProfile")
         fetch.predicate = NSPredicate(format: "id == %@", id)
         fetch.fetchLimit = 1
         if let obj = try ctx.fetch(fetch).first {
             obj.status = status.rawValue
             obj.updatedAt = Date()
             try ctx.save()
         }
     }
    
    func deleteAllProfiles() throws {
        let ctx = container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDProfile")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        try ctx.execute(deleteRequest)
        try ctx.save()
    }
    
    func removeDuplicateProfiles() throws {
        let ctx = container.viewContext
        
        // Fetch all profiles
        let fetchRequest = NSFetchRequest<CDProfile>(entityName: "CDProfile")
        let allProfiles = try ctx.fetch(fetchRequest)
        
        // Group profiles by ID to find duplicates
        let groupedProfiles = Dictionary(grouping: allProfiles) { $0.id ?? "" }
        
        // Remove duplicates, keeping the most recent one
        for (_, profiles) in groupedProfiles {
            if profiles.count > 1 {
                // Sort by updatedAt date, keeping the most recent
                let sortedProfiles = profiles.sorted { profile1, profile2 in
                    let date1 = profile1.updatedAt ?? Date.distantPast
                    let date2 = profile2.updatedAt ?? Date.distantPast
                    return date1 > date2
                }
                
                // Keep the first (most recent) profile, delete the rest
                for i in 1..<sortedProfiles.count {
                    ctx.delete(sortedProfiles[i])
                }
            }
        }
        
        if ctx.hasChanges {
            try ctx.save()
        }
    }
}

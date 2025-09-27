//
//  CDProfile+CoreDataProperties.swift
//  ShaadiDemo
//
//  Created by Abhishek Garg on 9/26/25.
//
//

import Foundation
import CoreData


extension CDProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProfile> {
        return NSFetchRequest<CDProfile>(entityName: "CDProfile")
    }

    @NSManaged public var id: String?
    @NSManaged public var fullName: String?
    @NSManaged public var age: Int16
    @NSManaged public var city: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var status: String?
    @NSManaged public var updatedAt: Date?
}

extension CDProfile : Identifiable {

}

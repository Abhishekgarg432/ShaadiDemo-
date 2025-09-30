//
//  ProfilesViewModel.swift
//  ShaadiDemo
//
//  Created by Abhishek Garg on 9/26/25.
//

import Foundation
import Combine
import CoreData
import Network
import SwiftUI
import UIKit

enum DecisionStatus: String {
    case none = "none"
    case accepted = "accepted"
    case declined = "declined"
}

@MainActor
final class ProfilesViewModel: ObservableObject {
    
    @Published private(set) var profiles: [CDProfile] = []
    @Published var errorMessage: String? = nil
    @Published var isOnline: Bool = true
    
    
    private let persistence: PersistenceController
    private let service: NetworkService
    private let monitor = NWPathMonitor()  // Network monitor (reachability)
    private let queue = DispatchQueue(label: "NetMonitor")
    private var currentTask: Task<Void, Never>?
    
    init(persistence: PersistenceController = .shared, service: NetworkService = NetworkService()) {
        self.persistence = persistence
        self.service = service
        startNetworkMonitoring()
        currentTask = Task { await load() }
    }
    
    deinit {
        monitor.cancel()
        currentTask?.cancel()
    }
    
    func load() async {
        guard !Task.isCancelled else {
            return
        }
        
        do {
            try refreshFromCache()
        } catch {
            errorMessage = "Failed to load cached data."
        }
        
        guard !Task.isCancelled else { return }
        
        if isOnline {
            print("[ViewModel] Online - attempting network refresh...")
            await refreshFromNetwork()
        } else {
            print("[ViewModel] Offline - skipping network refresh")
        }
    }
    
    func accept(id: String) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        updateDecision(id: id, to: .accepted)
    }
    
    func decline(id: String) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        updateDecision(id: id, to: .declined)
    }
    
    func refresh() {
        currentTask?.cancel()
        currentTask = Task { await load() }
    }
}

private extension ProfilesViewModel {
    
    // Monitor network reachability to toggle offline banner and decide refresh behavior.
    func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    } 
    
    // Update decision in Core Data and re-publish.
    func updateDecision(id: String, to status: DecisionStatus) {
        guard !Task.isCancelled else { return }
        
        do {
            try persistence.setDecision(id: id, status: status)
            try refreshFromCache()
        } catch {
            errorMessage = "Failed to save your decision. Try again."
        }
    }
}

//MARK: load Data
private extension ProfilesViewModel {
    
    func refreshFromCache() throws {
        profiles = try persistence.fetchAllProfiles()
    }
    
    func refreshFromNetwork() async {
        guard !Task.isCancelled else { 
            return
        }
        
        do {
            let items = try await service.fetchProfiles(count: 10)
            print("✅ [ViewModel] NetworkService returned \(items.count) profiles")
            
            guard !Task.isCancelled else { 
                return
            }
            
            try persistence.upsertProfiles(items)
            
            try refreshFromCache()
            
        } catch {
            if !Task.isCancelled {
                errorMessage = "Couldn't refresh from server. Working offline."
            }
        }
    }
}

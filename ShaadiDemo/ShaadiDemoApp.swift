//
//  ShaadiDemoApp.swift
//  ShaadiDemo
//
//  Created by Abhishek Garg on 9/26/25.
//

import SwiftUI

@main
struct ShaadiDemoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

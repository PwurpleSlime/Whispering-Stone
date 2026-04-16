//
//  Whispering_StoneApp.swift
//  Whispering Stone
//
//  Created by Pwurple on 2/18/26.
//

import SwiftUI
import SwiftData
import ClerkKit

@main
struct Whispering_StoneApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        Clerk.configure(publishableKey: "pk_test_c2hhcmluZy1tYXJsaW4tOS5jbGVyay5hY2NvdW50cy5kZXYk")
        

    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(Clerk.shared)
        }
        .modelContainer(sharedModelContainer)
    }
}

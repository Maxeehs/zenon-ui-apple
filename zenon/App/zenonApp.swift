//
//  zenonApp.swift
//  zenon
//
//  Created by Maxime Tiger on 30/05/2025.
//

import SwiftUI

@main
struct zenonApp: App {
    @StateObject private var session = SessionStore()
      
    var body: some Scene {
        WindowGroup {
            if session.isAuthenticated {
                ContentView()
                    .environmentObject(session)
            } else {
                LoginView()
                    .environmentObject(session)
            }
        }
    }
}

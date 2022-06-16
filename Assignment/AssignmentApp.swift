//
//  AssignmentApp.swift
//  Assignment
//
//  Created by Tuan on 14/06/2022.
//

import SwiftUI
import IQKeyboardManagerSwift

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

      IQKeyboardManager.shared.enable = true

      return true
    }
}

@main
struct AssignmentApp: App {
    let persistentService = DatabaseService.shared // Persistence service
    @StateObject var global = GlobalModel() // Global model
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.colorScheme, .light)
                .environment(\.managedObjectContext, persistentService.container.viewContext)
                .environmentObject(global)
        }
    }
}

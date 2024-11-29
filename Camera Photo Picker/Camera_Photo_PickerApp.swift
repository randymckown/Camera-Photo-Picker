//
//  Camera_Photo_PickerApp.swift
//  Camera Photo Picker
//
//  Created by Randy McKown on 11/14/24.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct Camera_Photo_PickerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var model = Model()  // Model instance for environment

       var body: some Scene {
           WindowGroup {
               ContentView()
                   .environmentObject(model)  // Pass Model as an environment object
           }
       }
   }

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // Control lock/unlock of orientation dynamically
    static var isOrientationLocked = false

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Check for supported devices and lock orientation if necessary
        if AppDelegate.isOrientationLocked {
            // Return portrait if locked, otherwise allow all orientations
            return .portrait
        }
        return .allButUpsideDown
    }
}

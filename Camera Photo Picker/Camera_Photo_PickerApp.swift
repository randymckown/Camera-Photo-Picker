//
//  Camera_Photo_PickerApp.swift
//  Camera Photo Picker
//
//  Created by Randy McKown on 11/14/24.
//

import SwiftUI
import SwiftData

@main
struct Camera_Photo_PickerApp: App {
    
    @StateObject private var model = Model()  // Model instance for environment

       var body: some Scene {
           WindowGroup {
               ContentView()
                   .environmentObject(model)  // Pass Model as an environment object
           }
       }
   }

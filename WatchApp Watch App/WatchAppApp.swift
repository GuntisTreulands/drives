//
//  WatchAppApp.swift
//  WatchApp Watch App
//
//  Created by GT on 02/02/2023.
//  Copyright © 2023 . All rights reserved.
//

import SwiftUI
import WatchKit
import WatchConnectivity


class MyWatchAppDelegate: NSObject, WKApplicationDelegate, ObservableObject {
    
    @Published var appInBackground = false
    
    func applicationDidFinishLaunching() { }
    
    func applicationWillEnterForeground() {
        appInBackground = false
    }
    
    func applicationWillResignActive() {
        appInBackground = true
    }
}

@main
struct WatchApp_Watch_AppApp: App {
    
    init() {
        if WCSession.isSupported() {
                print("To initiate it.")
            // To initiate it.
            _ = AppConnectionWorker.shared
        }
    }
    
    @WKApplicationDelegateAdaptor var appDelegate: MyWatchAppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

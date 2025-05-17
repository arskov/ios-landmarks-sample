//
//  LandmarksApp.swift
//  Landmarks
//
//  Created by Arseni Kavalchuk on 4.05.25.
//

import SwiftUI
#if os(watchOS)
import UIKit
#endif

@main
struct LandmarksApp: App {
    @State private var modelData = ModelData()
    
    #if os(watchOS)
    var wcSessionManager = WCSessionManagerWatch.shared
    #else
    var wcSessionManager = WCSessionManager.shared
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)
                #if !os(watchOS)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    wcSessionManager.setLandmarksApplicationContext()
                }
                #endif
        }
        #if os(watchOS)
        WKNotificationScene(controller: NotificationController.self, category: "LandmarkNear")
        #endif
    }
}

import os
import Foundation
import SwiftUI
#if os(watchOS)
import UIKit
import WatchKit
#endif

@main
struct LandmarksApp: App {
    @State private var modelData = ModelData()
    
    #if os(watchOS)
    @WKApplicationDelegateAdaptor
    private var appDelegate: LandmarksAppAppDelegate
    private var wcSessionManager = WCSessionManagerWatch.shared
    #else
    private var wcSessionManager = WCSessionManager.shared
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)
                #if !os(watchOS)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    wcSessionManager.setLandmarksApplicationContext()
                }
                .task {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if let error = error {
                            os_log(.error, "qqq: Notification auth error: %@", error.localizedDescription)
                        }
                    }
                }
                #endif
        }
        #if os(watchOS)
        WKNotificationScene(controller: NotificationController.self, category: "LandmarkNear")
        WKNotificationScene(controller: LandmarksNotificationController.self, category: "LandmarksReceived")
        #endif
    }
}

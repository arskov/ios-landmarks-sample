import os
import WatchConnectivity
import WatchKit
import UserNotifications
import Foundation

class LandmarksAppAppDelegate: NSObject, WKApplicationDelegate {
    private var activationStateObservation: NSKeyValueObservation?
    private var hasContentPendingObservation: NSKeyValueObservation?
    
    private var wcBackgroundTasks = [WKWatchConnectivityRefreshBackgroundTask]()
    
    override init() {
        super.init()
        
        activationStateObservation = WCSession.default.observe(\.activationState) { _, _ in
            DispatchQueue.main.async {
                self.completeBackgroundTasks()
            }
        }
        
        hasContentPendingObservation = WCSession.default.observe(\.hasContentPending) { _, _ in
            DispatchQueue.main.async {
                self.completeBackgroundTasks()
            }
        }
        
        NotificationCenter.default
            .addObserver(forName: .wcDidDataHandleComplete, object: nil, queue: .main) { [weak self] _ in
                self?.completeBackgroundTasks()
        }
    }
    
    deinit {
        activationStateObservation = nil
        hasContentPendingObservation = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    func completeBackgroundTasks() {
        guard !wcBackgroundTasks.isEmpty else { return }
        
        guard WCSession.default.activationState == .activated,
              WCSession.default.hasContentPending == false else { return }
        
        wcBackgroundTasks.forEach { $0.setTaskCompletedWithSnapshot(false) }
        wcBackgroundTasks.removeAll()
        
        let date = Date(timeIntervalSinceNow: 1)
        WKApplication.shared().scheduleSnapshotRefresh(withPreferredDate: date, userInfo: nil) { error in
            if let error {
                os_log(.error, "qqq: scheduleSnapshotRefresh error: \(error)")
            }
        }
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if let wcTask = task as? WKWatchConnectivityRefreshBackgroundTask {
                wcBackgroundTasks.append(wcTask)
                os_log(.info, "qqq: \(wcTask.description) was appended")
            } else {
                task.setTaskCompletedWithSnapshot(false)
                os_log(.info, "qqq: \(task.description) was completed")
            }
        }
    }
    
    func applicationDidFinishLaunching() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                os_log(.error, "qqq: Notification auth error: %@", error.localizedDescription)
            }
        }
    }

}

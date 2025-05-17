import os
import WatchKit
import SwiftUI
import UserNotifications

class LandmarksNotificationController: WKUserNotificationHostingController<LandmarksNotificationView> {
    
    var title: String?
    var message: String?
    
    override var body: LandmarksNotificationView {
        LandmarksNotificationView()
    }
    
    override func didReceive(_ notification: UNNotification) {
        os_log(.info, "qqq: Received landmarks User Notification")
        let content = notification.request.content
        title = content.title
        message = content.body
        // self.setNeedsBodyUpdate()
    }
}

import os
import Foundation
import WatchConnectivity
import UserNotifications

extension Notification.Name {
    static let wcDidDataHandleComplete = Notification.Name("wcDidDataHandleComplete")
}

class WCSessionManagerWatch: NSObject, WCSessionDelegate {
    
    static let shared = WCSessionManagerWatch()
        
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if error != nil {
            os_log(.error, "qqq: Error while activating a session: \(error)")
            return
        }
        os_log(.info, "qqq: Session activated \(activationState.rawValue)")
    }
    func sessionReachabilityDidChange(_ session: WCSession) {}

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        os_log(.info, "qqq: Session didReceiveMessage: \(message)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        os_log(.info, "qqq: Session didReceiveMessage: \(message) with replyHandler")
        if message["getLandmarks"] != nil {
            let dto = LandmarksInfo(landmarks: loadData("landmarkData.json"))
            replyHandler(["landmarks": dto])
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        os_log(.info, "qqq: Session didReceiveApplicationContext")
        guard let dtoString = applicationContext["landmarks"] as? String else {
            os_log(.error, "qqq: Failed to get the landmarks data")
            return
        }
        guard let jsonData = dtoString.data(using: .utf8) else {
            os_log(.error, "qqq: Failed to convert JSON string to data")
            return
        }
        do {
            let decoder = JSONDecoder()
            let landmarksInfo = try decoder.decode(LandmarksInfo.self, from: jsonData)
            NotificationCenter.default.post(name: .didReceiveLandmarks, object: landmarksInfo)
            NotificationCenter.default.post(name: .wcDidDataHandleComplete, object: nil)
            DispatchQueue.main.async {
                self.scheduleLocalNotification(with: landmarksInfo)
            }
        } catch {
            os_log(.error, "qqq: Decoding error: %{public}@", error.localizedDescription)
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        os_log(.info, "qqq: Session didReceiveUserInfo")
        guard let dtoString = userInfo["landmarks"] as? String else {
            os_log(.error, "qqq: Failed to get the landmarks data")
            return
        }
        guard let jsonData = dtoString.data(using: .utf8) else {
            os_log(.error, "qqq: Failed to convert JSON string to data")
            return
        }
        do {
            let decoder = JSONDecoder()
            let landmarksInfo = try decoder.decode(LandmarksInfo.self, from: jsonData)
            NotificationCenter.default.post(name: .didReceiveLandmarks, object: landmarksInfo)
            NotificationCenter.default.post(name: .wcDidDataHandleComplete, object: nil)
            DispatchQueue.main.async {
                self.scheduleLocalNotification(with: landmarksInfo)
            }
        } catch {
            os_log(.error, "qqq: Decoding error: %{public}@", error.localizedDescription)
        }
    }

    func scheduleLocalNotification(with landmarksInfo: LandmarksInfo) {
        let content = UNMutableNotificationContent()
        content.title = "New Landmarks List Received"
        content.body = "You have \(landmarksInfo.landmarks.count) new landmarks."
        content.sound = .default
        content.categoryIdentifier = "LandmarksReceived"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                os_log(.error, "Failed to schedule local notification: %@", error.localizedDescription)
            }
        }
    }
}

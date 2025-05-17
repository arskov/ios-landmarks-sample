//
//  WCSessionManager.swift
//  Landmarks
//
//  Created by Arseni Kavalchuk on 17.05.25.
//
import Foundation
import WatchConnectivity
import os

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
        os_log(.info, "qqq: Session didReceiveMessage: \(message)")
        if message["getLandmarks"] != nil {
            let dto = LandmarksInfo(landmarks: loadData("landmarkData.json"))
            replyHandler(["landmarks": dto])
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        os_log(.info, "qqq: Received: \(applicationContext)")
        let dtoString = applicationContext["landmarks"] as! String
        guard let jsonData = dtoString.data(using: .utf8) else {
            os_log(.error, "qqq: Failed to convert JSON string to data")
            return
        }
        do {
            let decoder = JSONDecoder()
            let landmarksInfo = try decoder.decode(LandmarksInfo.self, from: jsonData)
            NotificationCenter.default.post(name: .didReceiveLandmarks, object: landmarksInfo)
        } catch {
            os_log(.error, "qqq: Decoding error: %{public}@", error.localizedDescription)
        }
    }
    
}

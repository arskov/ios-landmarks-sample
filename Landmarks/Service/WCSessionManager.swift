//
//  WCSessionManager.swift
//  Landmarks
//
//  Created by Arseni Kavalchuk on 17.05.25.
//
import Foundation
import WatchConnectivity
import os

class WCSessionManager: NSObject, WCSessionDelegate {
    
    static let shared = WCSessionManager()
        
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
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        os_log(.info, "qqq: Session sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        os_log(.info, "qqq: Session sessionDidDeactivate")
    }
    
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
    
    func sendLandmarksData() {
        if !WCSession.default.isWatchAppInstalled {
            os_log(.error, "qqq: No watch app")
            return
        }
        if WCSession.default.activationState != WCSessionActivationState.activated {
            os_log(.error, "qqq: No session activated")
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let dto = LandmarksInfo(landmarks: loadData("landmarkData.json"))
            do {
                let encoder = JSONEncoder()
                let dtoData = try encoder.encode(dto)
                guard let dtoString = String(data: dtoData, encoding: .utf8) else {
                    os_log(.error, "qqq: Failed to convert dtoData to String")
                    return
                }
#if targetEnvironment(simulator)
                os_log(.info, "qqq: Updating application context with: \(dtoString)")
                try WCSession.default.updateApplicationContext(["landmarks": dtoString])
#else
                os_log(.info, "qqq: Transferring user data with: \(dtoString)")
                WCSession.default.transferUserInfo(["landmarks": dtoString])
#endif
            } catch {
                os_log(.error, "qqq: Can't update the data: \(error)")
            }
        }
    }
    
}

//
//  ConnectionWorker.swift
//  GPSTracker
//
//  Created by GT on 02/02/2023.
//  Copyright © 2023 . All rights reserved.
//

import Foundation
import WatchConnectivity
import UserNotifications

class WatchConnectionWorker: NSObject, WCSessionDelegate {

    static let shared = WatchConnectionWorker()
    
    var sessionIsActive: Bool = false
    
    private override init() {
        super.init()
        
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        sessionIsActive = activationState == .activated ? true : false
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        sessionIsActive = false
    }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        sessionIsActive = session.activationState == .activated ? true : false
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Did receive a message \(message)")
        
        if(message.keys.contains("ping")) {
            replyHandler(["ping":"ping"])
        } else {
            PrivateGatesHelperWorker.openTheGates { success in
                if success {
                    replyHandler(["success":"1"])
                } else {
                    replyHandler(["failure":"0"])
                }
            }
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                if(Bool.random()) {
//                    replyHandler(["success":"Received loud and clear After 2 secs"])
//                } else {
//                    replyHandler(["failure":"Received loud and clear After 2 secs"])
//                }
//            }
        }
    }
}


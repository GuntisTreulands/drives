//
//  AppConnectionWorker.swift
//  WatchApp
//
//  Created by GT on 03/02/2023.
//  Copyright © 2023 myEmerg. All rights reserved.
//

import Foundation
import WatchConnectivity
import UserNotifications

protocol AppConnectionWorkerProtocol {
    func ping()
    func requestOpenGates(_ answer: @escaping(_ success: Bool) -> Void)
}

class AppConnectionWorker: NSObject, WCSessionDelegate {

    static let shared = AppConnectionWorker()
    
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
    
    // MARK: AppConnectionWorkerProtocol
    
    func ping() {
        guard WCSession.default.activationState == .activated else {
            return
        }
        
        WCSession.default.sendMessage(["ping":"1"], replyHandler: { _ in
            print("Ping success")
        }) { error in
            print("Ping error: \(error)")
            WCSession.default.activate()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AppConnectionWorker.shared.ping()
            }
        }
    }
    
    func safePing(count: Int = 3, answer: @escaping(_ success: Bool) -> Void) {
        print("About to do safePing \(count)")
        
        WCSession.default.sendMessage(["ping":"1"], replyHandler: { _ in
            print("Ping success")
            
            answer(true)
        }) { error in
            print("Ping error: \(error)")
            WCSession.default.activate()
            
            if count == 0 {
                answer(false)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.safePing(count: count - 1, answer: answer)
                }
            }
        }
    }
    
    func requestOpenGates(_ answer: @escaping(_ success: Bool) -> Void) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            answer(true)
//        }
        
        safePing { success in
            if success == false {
                answer(false)
            } else {
                guard WCSession.default.activationState == .activated else {
                    WCSession.default.activate()
                    return answer(false)
                }


                WCSession.default.sendMessage(["request":"1"], replyHandler: { responseDict in
                    print("Response received from the app into watch... \(responseDict)")

                    if(responseDict.keys.contains("success")) {
                        answer(true)
                    } else {
                        answer(false)
                    }
                }) { error in
                    print("request error: \(error)")
                    answer(false)
                }
            }
        }
    }
}


//
//  GatesWorker.swift
//  GPSTracker
//
//  Created by Guntis on 18/02/2022.
//  Copyright © 2022 myEmerg. All rights reserved.
//

import CoreData
import CoreLocation
import CoreMotion
import UserNotifications
import UserNotificationsUI


protocol GatesWorkerLogic {
	func setUpGatesMonitorFromLocation(_ location: CLLocation)
	func userAtALocation(_ location: CLLocation)
	func userWalkingAtALocation(_ location: CLLocation)
}

class GatesWorker: NSObject, GatesWorkerLogic {

	static let shared = GatesWorker()

	private var encounters: Int = 0

	var shouldInitiateCallForGate = false

	var walkingReportWithinGate = false

	let gateRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: PrivateGatesHelperWorker.gateLatitude,
		longitude: PrivateGatesHelperWorker.gateLongitude), radius: 46, identifier: "drive_out_region")

	let largerGateRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: PrivateGatesHelperWorker.gateLatitude,
		longitude: PrivateGatesHelperWorker.gateLongitude), radius: 200, identifier: "drive_out_region")

	let walkingGateRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: PrivateGatesHelperWorker.gateLatitude,
		longitude: PrivateGatesHelperWorker.gateLongitude), radius: 33, identifier: "drive_out_region")

	private override init() {
		super.init()
	}

	// MARK: GatesWorkerLogic

	func setUpGatesMonitorFromLocation(_ location: CLLocation) {
		encounters = 0
		if gateRegion.contains(location.coordinate) {
			self.shouldInitiateCallForGate = true
		} else {
			self.shouldInitiateCallForGate = false
		}
	}

	func userAtALocation(_ location: CLLocation) {

		if gateRegion.contains(location.coordinate) && self.shouldInitiateCallForGate == true {
			if encounters >= 2 {
				PrivateGatesHelperWorker.openTheGates()
				self.shouldInitiateCallForGate = false
			} else {
				encounters += 1
			}
		} else if largerGateRegion.contains(location.coordinate) {
			// Priming! Enable gate calling!
			self.shouldInitiateCallForGate = true
		} else {
			encounters = 0
			self.shouldInitiateCallForGate = false
		}
	}

	func userWalkingAtALocation(_ location: CLLocation) {

//		if walkingGateRegion.contains(location.coordinate) {
//
//			walkingReportWithinGate = true
//			let content = UNMutableNotificationContent()
//			content.title = "Walking location"
//			content.body = "Within gate radius"
//			content.sound = UNNotificationSound.default
//			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//			let request = UNNotificationRequest(identifier: "Walking location", content: content, trigger: trigger)
//			UNUserNotificationCenter.current().add(request)
//		} else {
//			if walkingReportWithinGate == true {
//				walkingReportWithinGate = false
//				let content = UNMutableNotificationContent()
//				content.title = "Walking location"
//				content.body = "Outside gate radius"
//				content.sound = UNNotificationSound.default
//				let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//				let request = UNNotificationRequest(identifier: "Walking location", content: content, trigger: trigger)
//				UNUserNotificationCenter.current().add(request)
//			}
//		}
	}
}


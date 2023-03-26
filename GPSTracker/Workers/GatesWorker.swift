//
//  GatesWorker.swift
//  GPSTracker
//
//  Created by Guntis on 18/02/2022.
//  Copyright © 2022. All rights reserved.
//

import CoreData
import CoreLocation
import CoreMotion
import UserNotifications
import UserNotificationsUI


protocol GatesWorkerLogic {
	func setUpGatesMonitorFromLocation(_ location: CLLocation)
	func userAtALocation(_ location: CLLocation)
	func userWalkedAtALocation(_ location: CLLocation)
	func driveEndedAtALocation(_ location: CLLocation)
}

class GatesWorker: NSObject, GatesWorkerLogic {

	static let shared = GatesWorker()

	private var encounters: Int = 0

	var shouldInitiateCallForGate = false

	var walkingReportWithinGate = false

	let homeRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: PrivateGatesHelperWorker.homeLatitude,
		longitude: PrivateGatesHelperWorker.homeLongitude), radius: 105, identifier: "home_region")

	let gateRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: PrivateGatesHelperWorker.gateLatitude,
		longitude: PrivateGatesHelperWorker.gateLongitude), radius: 64, identifier: "drive_out_region")

	let walkGateRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: PrivateGatesHelperWorker.walkGateLatitude,
		longitude: PrivateGatesHelperWorker.walkGateLongitude), radius: 38, identifier: "walk_out_region")

	let largerGateRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: PrivateGatesHelperWorker.gateLatitude,
		longitude: PrivateGatesHelperWorker.gateLongitude), radius: 200, identifier: "drive_out_region_larger")

	private override init() {
		super.init()

		AppSettingsWorker.shared.startMonitoringForHomeRegionAtALocation()
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

		if gateRegion.contains(location.coordinate) {
			if self.shouldInitiateCallForGate == true {
				if encounters >= 2 {
                    PrivateGatesHelperWorker.openTheGates { _ in }
					self.shouldInitiateCallForGate = false
				} else {
					encounters += 1
				}
			}
		} else if largerGateRegion.contains(location.coordinate) {
			// Priming! Enable gate calling!
			self.shouldInitiateCallForGate = true
			encounters = 0
		} else {
			encounters = 0
			self.shouldInitiateCallForGate = false
		}
	}

	func userWalkedAtALocation(_ location: CLLocation) {
		// So.. only if we are on ground level more than 10 seconds.
		if AltitudeWorker.shared.lastTimeReachedGroundLevel != 0
			&& Date().timeIntervalSince1970 - AltitudeWorker.shared.lastTimeReachedGroundLevel > 2
		{
			if homeRegion.contains(location.coordinate) {
				AltitudeWorker.shared.startAltimeterChecking()

				// Only if not at apartment level. (Will work for cold start on the ground and all other cases)
				if AltitudeWorker.shared.justReachedApartment == false {
					if walkGateRegion.contains(location.coordinate) {
						if self.shouldInitiateCallForGate == true {
							if encounters >= 2 {
//								PrivateGatesHelperWorker.openTheGates() // Disable for now.
								self.shouldInitiateCallForGate = false
							} else {
								encounters += 1
							}
						}
					} else if largerGateRegion.contains(location.coordinate) {
						// Priming! Enable gate calling!
						self.shouldInitiateCallForGate = true
						encounters = 0
					} else {
						encounters = 0
						self.shouldInitiateCallForGate = false
					}
				}
			}
		}
	}

	func driveEndedAtALocation(_ location: CLLocation) {
		AltitudeWorker.shared.stopAltimeterChecking()
		if homeRegion.contains(location.coordinate) {
			AltitudeWorker.shared.justReachedApartment = false
			AltitudeWorker.shared.justReachedGroundLevel = true
			AltitudeWorker.shared.startAltimeterChecking()
		} else {
			AltitudeWorker.shared.justReachedApartment = false
			AltitudeWorker.shared.justReachedGroundLevel = false
		}
	}
}


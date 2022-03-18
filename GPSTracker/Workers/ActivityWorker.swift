//
//  ActivityWorker.swift
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


protocol ActivityWorkerLogic {
	func actOnAReceivedMotion(_ motion: CMMotionActivity)
	func tryToAddAPointFromALocation(_ location: CLLocation?)
}

class ActivityWorker: NSObject, ActivityWorkerLogic {

	static let shared = ActivityWorker()

	public var isDrivingCurrently = false
	public var isStationaryCurrently = false
	public var activeDrive: DriveEntity?

	let dayMonthYearDateFormatter = DateFormatter()
	let dayMonthDateFormatter = DateFormatter()
	let monthYearDateFormatter = DateFormatter()
	let monthDateFormatter = DateFormatter()


	private override init() {
		super.init()
		dayMonthYearDateFormatter.dateFormat = "dd.MM.yyyy"
		dayMonthDateFormatter.dateFormat = "dd.MM"
		monthYearDateFormatter.dateFormat = "MM.YYYY"
		monthDateFormatter.dateFormat = "MMM"
		monthDateFormatter.locale = Locale.init(identifier: "en_US")
	}

	// MARK: ActivityWorkerLogic

	func actOnAReceivedMotion(_ motion: CMMotionActivity) {
//		print("Drive?: \(motion.automotive) stationary: \(motion.stationary) walking: \(motion.walking)")

		if motion.automotive { 	// Asume we are driving
			isDrivingCurrently = true
			createANewDriveIfNecessary()
		}
		else if motion.stationary || motion.walking || motion.running {	// Asume we stopped driving. END OF DRIVE
			isDrivingCurrently = false
			stopExistingDrive()
		}

		// Second check of stationary & drive.
		if motion.stationary && motion.automotive {
			isStationaryCurrently = true
		} else {
			isStationaryCurrently = false
		}
	}

	func tryToAddAPointFromALocation(_ location: CLLocation?) {
		guard let location = location else {
			return
		}

		if location.horizontalAccuracy > 180 {
			return
		}

		if location.verticalAccuracy > 180 {
			return
		}

//		if isDrivingCurrently == false {
//			GatesWorker.shared.userWalkingAtALocation(location)
//		}

		guard let activeDrive = activeDrive else {
			return
		}

		if !activeDrive.isInProgress {
			return
		}

		if isDrivingCurrently && !isStationaryCurrently {
			var pLocation: CLLocation?
			var ppLocation: CLLocation?

			GatesWorker.shared.userAtALocation(location)

			let fetchRequest: NSFetchRequest<PointEntity> = PointEntity.fetchRequest()
			fetchRequest.predicate = NSPredicate(format:"rDrive == %@", activeDrive)
			fetchRequest.fetchLimit = 2
			let timestampSort = NSSortDescriptor(key: "timestamp", ascending: false)
			fetchRequest.sortDescriptors = [timestampSort]

			do {
				let results = try DataBaseManager.shared.mainManagedObjectContext().fetch(fetchRequest)

				let pPoint: PointEntity? = results.first
				let ppPoint: PointEntity? = results.last

				if let pPoint = pPoint {
					pLocation = CLLocation.init(latitude: pPoint.latitude, longitude: pPoint.longitude)
				}

				if let ppPoint = ppPoint {
					ppLocation = CLLocation.init(latitude: ppPoint.latitude, longitude: ppPoint.longitude)
				}

			} catch _ { }

			if let pLocation = pLocation {
				if let ppLocation = ppLocation {

					if pLocation.distance(from: location) > 8 && ppLocation.distance(from: location) > 8 {
						addAPointFromALocation(location)
					}
				}
			}
		}
	}

	// MARK: Functions

	func createANewDriveIfNecessary() {
		if let activeDrive = activeDrive {
			if activeDrive.isInProgress {
				return
			}
		}

		stopExistingDrive()

		let task = {
			// Continue, if no active drive, or ir active drive is NOT in progress
			ActivityWorker.shared.activeDrive = DriveEntity.init(context:DataBaseManager.shared.mainManagedObjectContext())

			if let activeDrive = ActivityWorker.shared.activeDrive {
				activeDrive.monthString = ActivityWorker.shared.monthDateFormatter.string(from: Date())
				activeDrive.sectionedMonthString = ActivityWorker.shared.monthYearDateFormatter.string(from: Date())
				activeDrive.sortingMonthDayYearString = ActivityWorker.shared.dayMonthYearDateFormatter.string(from: Date())
				activeDrive.identificator = "\(Date().timeIntervalSince1970)"
				activeDrive.isInProgress = true
				activeDrive.startTime = Date().timeIntervalSince1970
			}

			DataBaseManager.shared.saveContext()

			if let location = AppSettingsWorker.shared.getCurrentLocation() {
				ActivityWorker.shared.addAPointFromALocation(location)
				GatesWorker.shared.setUpGatesMonitorFromLocation(location)
			}
		}

		DataBaseManager.shared.addATask(action: task)

		AppSettingsWorker.shared.setLocationManagerInAnActiveState(true)

		AppSettingsWorker.shared.stopMonitoringAnyRegions()
	}

	func stopExistingDrive() {
		if let activeDrive = activeDrive {

			var distance: Double = 0

			var previousLocation: CLLocation!

			let sortedPoints: [PointEntity] = activeDrive.rPoints?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: false)]) as! [PointEntity]

			if let firstPoint = sortedPoints.first {
				previousLocation = CLLocation.init(latitude: firstPoint.latitude, longitude: firstPoint.longitude)

				for point in sortedPoints {
					let location = CLLocation.init(latitude: point.latitude, longitude: point.longitude)

					distance += previousLocation.distance(from: location)

					previousLocation = location
				}
			}

			let seconds: Double = (sortedPoints.first?.timestamp ?? 0) - (sortedPoints.last?.timestamp ?? 0)

			if AppSettingsWorker.shared.getNotifWarningIsEnabled() {

				let content = UNMutableNotificationContent()
				content.title = "debug_drive_ended_title".localized()
				content.body = """
					"\("debug_distance_title".localized()): \(HelperWorker.distanceFromMeters(distance))\n
					\("debug_time_title".localized()): \(HelperWorker.timeFromSeconds(Int(seconds)))
					"""
				content.sound = UNNotificationSound.default
				let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
				let request = UNNotificationRequest(identifier: "\(String(describing: activeDrive.identificator))", content: content, trigger: trigger)
				UNUserNotificationCenter.current().add(request)
			}

			let task = {
				if let activeDrive = ActivityWorker.shared.activeDrive {
					activeDrive.totalDistance = distance
					activeDrive.totalTime = seconds
					activeDrive.endTime = Date().timeIntervalSince1970
					activeDrive.isInProgress = false
					DataBaseManager.shared.saveContext()

					self.activeDrive = nil
				}
			}

			DataBaseManager.shared.addATask(action: task)

			AppSettingsWorker.shared.setLocationManagerInAnActiveState(false)


			AppSettingsWorker.shared.startMonitoringRegionForLocation(previousLocation)
		}
	}

	func addAPointFromALocation(_ location: CLLocation) {

		let task = {
			let activePoint = PointEntity.init(context:DataBaseManager.shared.mainManagedObjectContext())
			activePoint.latitude = location.coordinate.latitude
			activePoint.longitude = location.coordinate.longitude
			activePoint.rDrive = ActivityWorker.shared.activeDrive
			activePoint.timestamp = NSDate().timeIntervalSince1970
			DataBaseManager.shared.saveContext()
		}

		DataBaseManager.shared.addATask(action: task)
	}
}


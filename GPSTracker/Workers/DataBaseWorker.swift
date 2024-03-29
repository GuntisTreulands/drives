//
//  DataBaseWorker.swift
//  GPSTracker
//
//  Created by Guntis on 19/02/2022.
//  Copyright © 2022. All rights reserved.
//

import CoreData
import CoreLocation

protocol DataBaseWorkerLogic {
	static func invalidateAnyEntriesWithNoAddress()
	static func calculateFilteredPointsForDrives()
	static func calculateDistanceAndTimeForDrives()
	static func calculateStartAndEndAddressForDrives()
	static func getExportData() -> String
}

class DataBaseWorker: NSObject, DataBaseWorkerLogic {

	static func invalidateAnyEntriesWithNoAddress() {

		let task = {

			do {
				let context = DataBaseManager.shared.mainManagedObjectContext()
				let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
				fetchRequest.predicate = NSPredicate(format:"startAddress == %@ || endAddress == %@", "-", "-")
				let sortByMonth = NSSortDescriptor(key: "monthString", ascending: true)
				fetchRequest.sortDescriptors = [sortByMonth]

				do {
					let drives = try context.fetch(fetchRequest)


					for drive in drives {
						drive.startAddress = ""
						drive.endAddress = ""
						drive.totalDistance = 0
					}

					DataBaseManager.shared.saveContext()//(backgroundContext: backgroundContext)

				} catch { print("error \(error)")}
			}
		}

		DataBaseManager.shared.addATask(action: task)

		DataBaseWorker.calculateDistanceAndTimeForDrives()
		DataBaseWorker.calculateFilteredPointsForDrives()

//		}, completion:{
////			DataBaseWorker.calculateDistanceAndTimeForDrives()
//		})
	}

	static func calculateFilteredPointsForDrives() {

		DispatchQueue.background(background: {
			let task = {

				do {

					DataBaseManager.shared.persistentContainer!.performBackgroundTask { context in
					context.mergePolicy = NSOverwriteMergePolicy

					let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
					fetchRequest.predicate = NSPredicate(format:"isInProgress == FALSE && rFilteredPoints.@count == 0")
					let sortByMonth = NSSortDescriptor(key: "sectionedMonthString", ascending: false)
					let sortByDay = NSSortDescriptor(key: "sortingMonthDayYearString", ascending: false)
					let sortByStartTime = NSSortDescriptor(key: "startTime", ascending: true)

					fetchRequest.sortDescriptors = [sortByMonth, sortByDay, sortByStartTime]

					do {
						let drives = try context.fetch(fetchRequest)

						for drive in drives {

							let sortedPoints: [PointEntity] = drive.rPoints?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [PointEntity]

							var keepCount = 0

							for (index, point) in sortedPoints.enumerated() {

								point.rFilteredDrive = nil

								if sortedPoints.first == point {
									point.rFilteredDrive = drive
								} else if sortedPoints.last == point {
									point.rFilteredDrive = drive
								} else {
									let previousPoint: PointEntity = sortedPoints[index - 1]
									let nextPoint: PointEntity = sortedPoints[index + 1]
									let nextNextPoint: PointEntity = sortedPoints[min(sortedPoints.count - 1, index + 6)] //5 //6

									let dxc = point.latitude - previousPoint.latitude
									let dyc = point.longitude - previousPoint.longitude

									let dxl = nextPoint.latitude - previousPoint.latitude
									let dyl = nextPoint.longitude - previousPoint.longitude

									let dxl2 = nextNextPoint.latitude - previousPoint.latitude
									let dyl2 = nextNextPoint.longitude - previousPoint.longitude

									let cross: Double = dxc * dyl - dyc * dxl
									let cross2: Double = dxc * dyl2 - dyc * dxl2


									if (abs(cross) > 0.000000008) {
										point.rFilteredDrive = drive
										keepCount = min(30, keepCount + 12)
									} else {
										if (abs(cross2) > 0.000000009 && keepCount < 1) {
											point.rFilteredDrive = drive
											keepCount = min(30, keepCount + 12)
										} else {
											keepCount = max(0, keepCount - 1)
										}
									}
								}
							}
						}

						DataBaseManager.shared.saveBackgroundContext(backgroundContext: context)

					} catch _ { }
				}
				}
			}

			DataBaseManager.shared.addATask(action: task)

		}, completion:{ })
	}


	static func calculateDistanceAndTimeForDrives() {

		DispatchQueue.background(background: {
			let task = {

				do {

					DataBaseManager.shared.persistentContainer!.performBackgroundTask { context in
					context.mergePolicy = NSOverwriteMergePolicy

					let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
					fetchRequest.predicate = NSPredicate(format:"isInProgress == TRUE || totalDistance == 0 || totalTime < 10 || sortingMonthDayYearString == ''")
					let sortByMonth = NSSortDescriptor(key: "monthString", ascending: true)
					let sortByStartTime = NSSortDescriptor(key: "startTime", ascending: false)
					fetchRequest.sortDescriptors = [sortByMonth, sortByStartTime]

					do {
						let drives = try context.fetch(fetchRequest)


						for drive in drives {
//							print("drive.isInProgress \(drive.isInProgress)")
//							print("totalDistance \(drive.totalDistance)")
//							print("totalTime \(drive.totalTime)")
//							print("sortingMonthDayYearString \(drive.sortingMonthDayYearString)")

							var distance: Double = 0

							var previousLocation: CLLocation!

							let sortedPoints: [PointEntity] = drive.rPoints?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: false)]) as! [PointEntity]

							if let firstPoint = sortedPoints.first {
								previousLocation = CLLocation.init(latitude: firstPoint.latitude, longitude: firstPoint.longitude)

								for point in sortedPoints {
									let location = CLLocation.init(latitude: point.latitude, longitude: point.longitude)

									distance += previousLocation.distance(from: location)

									previousLocation = location
								}
							}

							let seconds: Double = (sortedPoints.first?.timestamp ?? 0) - (sortedPoints.last?.timestamp ?? 0)

							drive.totalDistance = distance
							drive.totalTime = seconds

//							let sortingString = ActivityWorker.shared.dayMonthYearDateFormatter.string(from: Date.init(timeIntervalSince1970: drive.startTime))
//							drive.sortingMonthDayYearString = sortingString
						}

						DataBaseManager.shared.saveBackgroundContext(backgroundContext: context)

					} catch _ { }
				}
				}
			}

			DataBaseManager.shared.addATask(action: task)

		}, completion:{ })
	}


	static func calculateStartAndEndAddressForDrives() {

		DispatchQueue.background(background: {

			let task = {

				do {

					DataBaseManager.shared.persistentContainer!.performBackgroundTask { context in
						context.mergePolicy = NSOverwriteMergePolicy

						let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
						fetchRequest.predicate = NSPredicate(format:"rPoints.@count > 10 && ((isInProgress == TRUE && startAddress == '') || (isInProgress == FALSE && (startAddress == '' || endAddress == '')))")
						let sortByMonth = NSSortDescriptor(key: "monthString", ascending: true)
						let sortByStartTime = NSSortDescriptor(key: "startTime", ascending: false)
						fetchRequest.sortDescriptors = [sortByMonth, sortByStartTime]
						fetchRequest.fetchLimit = 1



						let geocoder = CLGeocoder()

						do {
							let drives = try context.fetch(fetchRequest)
							for drive in drives {

//								print("drive.isInProgress \(drive.isInProgress)")
//								print("totalDistance \(drive.totalDistance)")
//								print("totalTime \(drive.totalTime)")
//								print("sortingMonthDayYearString \(drive.sortingMonthDayYearString)")

//								print("calculateStartAndEndAddressForDrives - Will work on drive!!! \(drive)")

								let sortedPoints: [PointEntity] = drive.rPoints?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [PointEntity]

								var addToStartAddress = false

								if drive.isInProgress || (!drive.isInProgress && drive.startAddress?.count == 0) {
									addToStartAddress = true
								}

								let group = DispatchGroup()
								var country = "-"
								var addressArray = [String]()

								if addToStartAddress && sortedPoints.count > 10 {

//									print("sortedPoints.count \(sortedPoints.count)")

									for index in 0 ..< 3 {
										let aPoint = sortedPoints[index]
										let location = CLLocation.init(latitude: aPoint.latitude, longitude: aPoint.longitude)

										group.enter()

										//print("Requesting 1 address for place \(location), date \(drive.sortingMonthDayYearString!)")

										geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
											DispatchQueue.background(background: {

												let address = HelperWorker.addressFromAPlacemark(placemarks?.first)

												if(address.address != "-") {
													addressArray.append(address.address)
													country = address.country
												}

//												print("1 Address = \(address)")
											}, completion:{
												group.leave()

											})
										})
										group.wait()
									}

								} else if sortedPoints.count > 10 {
									for index in sortedPoints.count-4 ..< sortedPoints.count-1 {
										let aPoint = sortedPoints[index]
										let location = CLLocation.init(latitude: aPoint.latitude, longitude: aPoint.longitude)

										group.enter()

										//print("Requesting 2 address for place \(location), date \(drive.sortingMonthDayYearString!)")

										geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
											DispatchQueue.background(background: {

												let address = HelperWorker.addressFromAPlacemark(placemarks?.first)

												if(address.address != "-") {
													addressArray.append(address.address)
													country = address.country
												}

//												print("2  Address = \(address)")

											}, completion:{
											group.leave() })
										})
										group.wait()
									}
								}

								let mostCommonAddress = addressArray.mostFrequent() ?? "-"
								if addToStartAddress {
									drive.startAddress = mostCommonAddress
									drive.startCountry = country
								}
								else {
									drive.endAddress = mostCommonAddress
									drive.endCountry = country
								}

								DataBaseManager.shared.saveBackgroundContext(backgroundContext: context)
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
									DataBaseWorker.calculateStartAndEndAddressForDrives()
								}
							}

						} catch _ { }
					}
				}
			}

			DataBaseManager.shared.addATask(action: task)

		}, completion:{ })
	}

	static func getExportData() -> String {
		let context = DataBaseManager.shared.mainManagedObjectContext()
		let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
		let sortByMonth = NSSortDescriptor(key: "sectionedMonthString", ascending: false)
		let sortByDay = NSSortDescriptor(key: "sortingMonthDayYearString", ascending: false)
		let sortByStartTime = NSSortDescriptor(key: "startTime", ascending: true)

		fetchRequest.sortDescriptors = [sortByMonth, sortByDay, sortByStartTime]

		var drives = [DriveEntity]()

		do {
			drives = try context.fetch(fetchRequest)
		} catch {
			return ""
		}

		var resultString = ""
		var totalTime: Double = 0
		var totalDistance: Double = 0
		var totalDriveDays: Int = 0

		let yearFormatter = DateFormatter()
		yearFormatter.dateFormat = "yyyy"

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd. MMM"



		var previousDay = ""
		var previousYear = ""

		var index = 1

		/*
			Entries, sorted by date.

			Need to report:

			Year: 2022
			Total time: 04:59
			Total distance: 59 km

			01.02 (3 h 53 m | 5 km) (business)
				1.) 27 min | 10.9 km (Lugažu iela, Rīga -> Stāmerienes iela, Rīga)
				2.) ...

			02.02 (4 h 53 m | 9 km) (business)
			..

			Year: 2021
			Total time: 04:59
			Total distance: 59 km

			01.02 (3 h 53 m | 5 km) (business)
				1.) 27 min | 10.9 km (Lugažu iela, Rīga -> Stāmerienes iela, Rīga)
				2.) ...

			02.02 (4 h 53 m | 9 km) (business)
			...
		 */

		var tempDayDrives = ""
		var daySeconds: Double = 0
		var dayDistance: Double = 0
		var dayStartTimestamp: Double = 0
		var dayEndTimestamp: Double = 0

		for drive in drives {

			let yearString = yearFormatter.string(from: Date.init(timeIntervalSince1970: drive.startTime))

			if yearString != previousYear && previousYear != "" {
				let totalTimeString = HelperWorker.timeFromSeconds(Int(totalTime))
				let totalDistanceString = HelperWorker.distanceFromMeters(totalDistance)

				resultString = """
					"\n\n Year: \(previousYear)
					\n\nTotal time: \(totalTimeString)
					\nTotal distance: \(totalDistanceString)
					\nTotal drive days: \(totalDriveDays)
					"""
					+ resultString

				totalTime = 0
				totalDistance = 0
			}

			previousYear = yearString


			let dateString = dateFormatter.string(from: Date.init(timeIntervalSince1970: drive.startTime))

			if dateString != previousDay {
				totalDriveDays += 1

				if daySeconds > 0 {
					let time1 = HelperWorker.readableTimeFromSeconds(Int(dayEndTimestamp - dayStartTimestamp))
					let time2 = HelperWorker.readableTimeFromSeconds(Int(daySeconds))
					let distance3 = HelperWorker.distanceFromMeters(dayDistance)
					resultString += " \(time1) | \(time2) | \(distance3) (business)"
				}

				resultString += tempDayDrives;

				resultString = resultString + "\n\n\(dateString)"
				tempDayDrives = ""
				daySeconds = 0
				dayDistance = 0
				dayStartTimestamp = 0
				dayEndTimestamp = 0

				index = 1
			}

			previousDay = dateString



			totalTime += drive.totalTime
			totalDistance += drive.totalDistance



			let startAddress = drive.startAddress ?? "-"
			let endAddress = drive.endAddress ?? "-"

			tempDayDrives = tempDayDrives +
				"""
				\n \(index).)
				\(String(format:"%.0f", drive.totalTime/60)) min |
				\(HelperWorker.distanceFromMeters(drive.totalDistance))
				(\(startAddress) -> \(endAddress))
				"""


			// If it is car wash drive or refuel drive
			if !drive.isBusinessDrive {
				tempDayDrives = tempDayDrives + " (Car wash or refuel)"
			} else {
				if dayStartTimestamp == 0 { dayStartTimestamp = drive.startTime }
				dayEndTimestamp = drive.endTime
				daySeconds += drive.totalTime
				dayDistance += drive.totalDistance
			}

			index += 1
		}

		if daySeconds > 0 {
			resultString += "\(String(format:"%.0f", daySeconds/60)) min | \(HelperWorker.distanceFromMeters(dayDistance)) (business)"
		}

		resultString += tempDayDrives;

		let totalTimeString = HelperWorker.timeFromSeconds(Int(totalTime))
		let totalDistanceString = HelperWorker.distanceFromMeters(totalDistance)


		resultString = "\n\n Year: \(previousYear)\n\nTotal time: \(totalTimeString)\nTotal distance: \(totalDistanceString)\nTotal drive days: \(totalDriveDays)" + resultString

		return resultString

		// TODO:  for each date, add total day distance, total day time, and elapsed day time.
	}
}

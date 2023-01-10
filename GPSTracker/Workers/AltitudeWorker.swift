//
//  AltitudeWorker.swift
//  GPSTracker
//
//  Created by Guntis on 08/04/2022.
//  Copyright © 2022. All rights reserved.
//

import Foundation
import CoreMotion

/*
	Main goal of this class is to detect in sudden elevation/.. anti-elevation
	Because by default, pressure changes by the minute (or even secods).. little by little.
 */


protocol AltitudeWorkerLogic {
	func startAltimeterChecking()
	func stopAltimeterChecking()
}

struct AltitudeEntry {
	var timestamp: Double = Date().timeIntervalSince1970
	var altitude: Float!
}

protocol AltitudeLogic: AnyObject {
	func justReachedGroundLevel()
	func justReachedApartmentLevel()
}


class AltitudeWorker: NSObject, AltitudeWorkerLogic {

	weak var controller: AltitudeLogic?

	static let shared = AltitudeWorker()

	lazy var altimeter = CMAltimeter()

	var movements: Array = [AltitudeEntry]()

	var altimeterIsActive = false
	var lastTimeReachedGroundLevel: TimeInterval = 0


	var justReachedGroundLevel = false {
		didSet {
			if justReachedGroundLevel == true && altimeterIsActive == true {
				lastTimeReachedGroundLevel = Date().timeIntervalSince1970
				controller?.justReachedGroundLevel()
			} else {
				lastTimeReachedGroundLevel = 0
			}
		}
	}

	var justReachedApartment = false {
		didSet {
			if justReachedApartment == true {
				controller?.justReachedApartmentLevel()
			}
		}
	}

	private override init() {
		super.init()
	}

	// MARK: AltitudeWorkerLogic

	func startAltimeterChecking() {
		if altimeterIsActive == false {
			altimeterIsActive = true
			if (CMAltimeter.isRelativeAltitudeAvailable()) {
				startAltimeter()
			}
		}
	}

	func stopAltimeterChecking() {
		if altimeterIsActive == true {
			altimeterIsActive = false
			justReachedGroundLevel = false
			justReachedApartment = false
			self.altimeter.stopRelativeAltitudeUpdates()
			self.movements.removeAll()
		}
	}

	// MARK: Functions

	private func startAltimeter() {
		self.altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: { (altitudeData:CMAltitudeData?, error:Error?) in

			if (error == nil) {
				self.movements.append(AltitudeEntry.init(altitude: altitudeData!.relativeAltitude.floatValue))
				self.doValidation()
			}
		})
	}

	private func doValidation() {

		if ActivityWorker.shared.isDrivingCurrently == true { // Just ignore. not important.
			movements.removeAll()
			return
		}

		if movements.last!.altitude - movements.first!.altitude > 10 {
			justReachedApartment = true
			justReachedGroundLevel = false
			movements.removeAll()
		} else if movements.first!.altitude - movements.last!.altitude > 10 {
			justReachedGroundLevel = true
			justReachedApartment = false
			movements.removeAll()
		}

		if movements.count > 70 {
			movements.removeFirst()
		}
	}
}

//
//  BoltDrivePriceWorker.swift
//  GPSTracker
//
//  Created by Guntis on 25/09/2022.
//  Copyright © 2022 . All rights reserved.
//

import Foundation

struct BoltDriveTier {

	func cost(days: Int, time: Int, distance: Double) -> Double {
		let kmCost = max(0, distance/1000 * 0.18)

		let hours = Int(time / 60 / 60)
		let minutes = (time - hours * 60 * 60) / 60

		var timeCost = 4.49 * Double(hours)
		timeCost += 0.07 * Double(minutes)

		timeCost = fmin(22.90, timeCost)

		var baseDays = 0

		if timeCost < 22.90 { baseDays = max(1, baseDays) }

		let extraDays = max(0, days - baseDays)

		if extraDays > 0 {
			timeCost = 22.90 * Double(extraDays)
		}

		return Int(timeCost + kmCost) == 0 ? 9999 : timeCost + kmCost
	}
}

struct BoltDrivePricing {
	var tier0H0KM = BoltDriveTier.init()

	func minPrice() -> Double {
		return 2.00
	}

	
	func cost(days: Int, time: Double, distance: Double) -> Double {

		return tier0H0KM.cost(days: days, time: Int(time), distance: distance)
	}
}

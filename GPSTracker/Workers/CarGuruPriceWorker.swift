//
//  CarGuruPriceWorker.swift
//  GPSTracker
//
//  Created by Guntis on 25/09/2022.
//  Copyright © 2022 . All rights reserved.
//

import Foundation

/*
	0.29 Eur min
	120 km daily free + 0.18 Eur / km

	Day standby 0.06 Eur
	Night standby 0 Eur
	Minimum price 2.5 Eur

	Long term
	1h = 9.99
	3h = 21.99
	24h = 44.99
	2d = 79.99
	3d = 119.99
	7d = 264.99


	Refuel Reward = 2GCoin
	1 GCoin = 1 Eur

	Day time 7:00 - 22:00
	Night time 22:00 - 07:00

	Cannot drive outside Latvia (can ask for permission)

	After each drive, you receive bonus points
	5 Eur drive  = 0.15 Points
	10 Eur drive = 0.30 Points
	25 Eur drive = 0.75 Points



 */
struct CarGuruTier {
	var baseCost: Double = 0
	var baseDailyDistance: Double = 120_000
	var baseHours: Int
	var baseDays: Int
	
	func cost(totalDriveDays: Int, totalDriveTime: Int, actualDriveTime: Int, distances: [Double]) -> Double {

		var kmCost: Double = 0
		var totalDistance: Double = 0

		for distance in distances {
			kmCost += max(0, (distance-baseDailyDistance)/1000 * 0.18)
			totalDistance += distance
		}

		let actualDriveTimeAdjusted = actualDriveTime - (baseHours * 60 * 60) - (baseDays * 60 * 60 * 24)
		let time = max(0, actualDriveTimeAdjusted)
		let hours = Int(time / 60 / 60)
		let minutes = (time - hours * 60 * 60) / 60

		var timeCost = 9.99 * Double(hours)
		timeCost += 0.29 * Double(minutes)

		let waitTime = max(0, (totalDriveTime - actualDriveTime) + min(0, actualDriveTimeAdjusted))
		let waitHours = Int(waitTime / 60 / 60)
		let waitMinutes = (waitTime - waitHours * 60 * 60) / 60
		timeCost += 0.06 * 60 * Double(waitHours)
		timeCost += 0.06 * Double(waitMinutes)


		timeCost = fmin(44.99, timeCost)

		var baseDays = baseDays

		if timeCost < 44.99 && totalDriveDays == 1 { baseDays = max(1, baseDays) }

		let extraDays = max(0, totalDriveDays - baseDays)

		if extraDays > 0 {
			timeCost = 44.99 * Double(extraDays)
		}

		let finalPrice = timeCost + kmCost + baseCost

		var cashback: Double = 0

		if finalPrice >= 25 {
			cashback = 0.75
		} else if finalPrice >= 10 {
			cashback = 0.30
		} else if finalPrice >= 5 {
			cashback = 0.15
		}

		if totalDistance >= 100 {
			cashback += 2
		}

		return Int(timeCost + kmCost + baseCost) == 0 ? 9999 : finalPrice - cashback
	}
}

struct CarGuruPricing {

	var tier0H = CarGuruTier.init(baseCost: 0, baseHours: 0, baseDays: 0)
	var tier1H = CarGuruTier.init(baseCost: 9.99, baseHours: 1, baseDays: 0)
	var tier3H = CarGuruTier.init(baseCost: 21.99, baseHours: 3, baseDays: 0)
	var tier24H = CarGuruTier.init(baseCost: 44.99, baseHours: 0, baseDays: 1)
	var tier2D = CarGuruTier.init(baseCost: 79.99, baseHours: 0, baseDays: 2)
	var tier3D = CarGuruTier.init(baseCost: 119.99, baseHours: 0, baseDays: 3)
	var tier7D = CarGuruTier.init(baseCost: 264.99, baseHours: 0, baseDays: 7)

	func minPrice() -> Double {
		return 2.50
	}

	func cost(totalDriveDays: Int, totalDriveTime: Double, actualDriveTime: Double, distances: [Double]) -> Double {

		var final = tier0H.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances)
		final = min(final, tier1H.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))
		final = min(final, tier3H.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))
		final = min(final, tier24H.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))
		final = min(final, tier2D.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))
		final = min(final, tier3D.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))
		final = min(final, tier7D.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))

//		print("tier0H : \(tier0H.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))")
//		print("tier1H : \(tier1H.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))")
//		print("tier3H : \(tier3H.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))")
//		print("tier24H : \(tier24H.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))")
//		print("tier2D : \(tier2D.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))")
//		print("tier3D : \(tier3D.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))")
//		print("tier7D : \(tier7D.cost(totalDriveDays: totalDriveDays, totalDriveTime: Int(totalDriveTime), actualDriveTime:Int(actualDriveTime), distances: distances))")

		return final
	}
}

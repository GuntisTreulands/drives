//
//  CityBeePriceWorker.swift
//  GPSTracker
//
//  Created by Guntis on 25/09/2022.
//  Copyright © 2022 . All rights reserved.
//

import Foundation

// Cashback 7%

struct CityBeeTier {
	var baseCost: Double
	var baseDistance: Double
	var baseHours: Int
	var baseDays: Int


	func cost(days: Int, time: Int, distance: Double) -> Double {
		let kmCost = max(0, (distance-baseDistance)/1000 * 0.22)

		let time = max(0, time - (baseHours * 60 * 60) - (baseDays * 60 * 60 * 24))
		let hours = Int(time / 60 / 60)
		let minutes = (time - hours * 60 * 60) / 60

		var timeCost = 4.99 * Double(hours)
		timeCost += 0.13 * Double(minutes)

		timeCost = fmin(27.89, timeCost)

		var baseDays = baseDays
		if timeCost <= 27.89 && days == 1 { baseDays = max(1, baseDays) }
		let extraDays = max(0, days - baseDays)

		if extraDays > 0 {
			timeCost = 27.89 * Double(extraDays)
		}

		let addition = baseCost <= 0 ? 0.5 : 0

		let finalPrice = timeCost + kmCost + baseCost + addition

		return Int(timeCost + kmCost + baseCost) == 0 ? 9999 : finalPrice - (finalPrice * 0.07)
	}
}

struct CityBeePricing {
	var tier0H0KM = CityBeeTier.init(baseCost: 0, baseDistance: 0, baseHours: 0, baseDays: 0)
	var tier1H10KM = CityBeeTier.init(baseCost: 7.49, baseDistance: 10000, baseHours: 1, baseDays: 0)
	var tier2H20KM = CityBeeTier.init(baseCost: 13.99, baseDistance: 20000, baseHours: 2, baseDays: 0)
	var tier3H30KM = CityBeeTier.init(baseCost: 19.99, baseDistance: 30000, baseHours: 3, baseDays: 0)
	var tier1D50KM = CityBeeTier.init(baseCost: 31, baseDistance: 50000, baseHours: 0, baseDays: 1)
	var tier1D150KM = CityBeeTier.init(baseCost: 49, baseDistance: 150000, baseHours: 0, baseDays: 1)
	var tier1D250KM = CityBeeTier.init(baseCost: 64, baseDistance: 250000, baseHours: 0, baseDays: 1)
	var tier1D350KM = CityBeeTier.init(baseCost: 85, baseDistance: 350000, baseHours: 0, baseDays: 1)
	var tier2D100KM = CityBeeTier.init(baseCost: 60, baseDistance: 100000, baseHours: 0, baseDays: 2)
	var tier2D250KM = CityBeeTier.init(baseCost: 85, baseDistance: 250000, baseHours: 0, baseDays: 2)
	var tier2D400KM = CityBeeTier.init(baseCost: 108, baseDistance: 400000, baseHours: 0, baseDays: 2)
	var tier3D175KM = CityBeeTier.init(baseCost: 96, baseDistance: 175000, baseHours: 0, baseDays: 3)
	var tier3D300KM = CityBeeTier.init(baseCost: 116, baseDistance: 300000, baseHours: 0, baseDays: 3)
	var tier3D500KM = CityBeeTier.init(baseCost: 148, baseDistance: 500000, baseHours: 0, baseDays: 3)
	var tier7D600KM = CityBeeTier.init(baseCost: 222, baseDistance: 600000, baseHours: 0, baseDays: 7)
	var tier7D900KM = CityBeeTier.init(baseCost: 283, baseDistance: 900000, baseHours: 0, baseDays: 7)
	var tier14D600KM = CityBeeTier.init(baseCost: 401, baseDistance: 600000, baseHours: 0, baseDays: 14)
	var tier14D1000KM = CityBeeTier.init(baseCost: 479, baseDistance: 1000000, baseHours: 0, baseDays: 14)


	func minPrice() -> Double {
		return 2.29
	}
	
	func cost(days: Int, time: Double, distance: Double) -> Double {

		var final = tier0H0KM.cost(days: days, time: Int(time), distance: distance)
		final = min(final, tier1H10KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier2H20KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier3H30KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier1D50KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier1D150KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier1D250KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier1D350KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier2D100KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier2D250KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier2D400KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier3D175KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier3D300KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier3D500KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier7D600KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier7D900KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier14D600KM.cost(days: days, time: Int(time), distance: distance))
		final = min(final, tier14D1000KM.cost(days: days, time: Int(time), distance: distance))
//
//		print("tier0H0KM : \(tier0H0KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier1H10KM : \(tier1H10KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier2H20KM : \(tier2H20KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier3H30KM : \(tier3H30KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier1D50KM : \(tier1D50KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier1D150KM : \(tier1D150KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier1D250KM : \(tier1D250KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier1D350KM : \(tier1D350KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier2D100KM : \(tier2D100KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier2D250KM : \(tier2D250KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier2D400KM : \(tier2D400KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier3D175KM : \(tier3D175KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier3D300KM : \(tier3D300KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier3D500KM : \(tier3D500KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier7D600KM : \(tier7D600KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier7D900KM : \(tier7D900KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier14D600KM : \(tier14D600KM.cost(days: days, time: Int(time), distance: distance))")
//		print("tier14D1000KM : \(tier14D1000KM.cost(days: days, time: Int(time), distance: distance))")

		return final
	}
}

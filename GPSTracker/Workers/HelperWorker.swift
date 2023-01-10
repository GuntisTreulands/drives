//
//  HelperWorker.swift
//  GPSTracker
//
//  Created by Guntis on 21/02/2022.
//  Copyright © 2022. All rights reserved.
//

import Foundation
import CoreLocation


protocol HelperWorkerLogic {
	static func timeFromSeconds(_ seconds: Int) -> String
	static func readableTimeFromSeconds(_ seconds: Int) -> String
	static func distanceFromMeters(_ meters: Double) -> String
	static func addressFromAPlacemark(_ placemark: CLPlacemark?) -> (address: String, country: String)
}

class HelperWorker: NSObject, HelperWorkerLogic {

	static func timeFromSeconds(_ seconds: Int) -> String {
		let hours = seconds / 3600
		let minutes = (seconds % 3600) / 60

//		let hourString = hours > 9 ? "\(hours)" : "0\(hours)"
//		let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"

		if hours == 0 {
			return "\(minutes)m"
		} else {
			return "\(hours)h \(minutes)m"
		}
		
//		return "\(hourString):\(minutesString)"
	}

	static func readableTimeFromSeconds(_ seconds: Int) -> String {
		let hours = seconds / 3600
		let minutes = (seconds % 3600) / 60

		if hours == 0 {
			return "\(minutes)m"
		} else {
			return "\(hours)h \(minutes)m"
		}
	}

	static func distanceFromMeters(_ meters: Double) -> String {
		return "\(String(format:"%.1f", meters/1000)) km"
	}

	static func addressFromAPlacemark(_ placemark: CLPlacemark?) -> (address: String, country: String) {
		if let placemark = placemark {
			var addressString : String = ""
			var countryString: String = ""

			if let th = placemark.thoroughfare { // Street name
				addressString = addressString + th + ", "
			}

			if let locality = placemark.locality {   // City
				addressString = addressString + locality// + ", "
			}

			if let country = placemark.country {  // Country
				countryString = country
			}

			print("addressString \(addressString)")
			
			return (address: addressString, country: countryString)
		}

		return (address: "-", country: "-")
	}
}

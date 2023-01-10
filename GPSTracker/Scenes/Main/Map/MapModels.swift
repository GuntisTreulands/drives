//
//  MapModels.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import CoreData

enum Map {
	// MARK: Use cases

	enum DeleteAPoint {
		struct Request {
			var point: MapPoint
		}
	}

	enum FetchPoints {
		struct Request {
		}
		struct Response {
			var fetchedPoints: [[PointEntity]]
			var monthIdentificator: String
		}
		struct ViewModel {
			struct DisplayedItem: Equatable {
				var title: String
				var subtitle: String
				var latitude: Double
				var longitude: Double
				var isStart: Bool
				var isEnd: Bool
				var objectID: NSManagedObjectID
			}
			var displayedItems: [[DisplayedItem]]
			var mapPoints: [[MapPoint]]
			var title: String
		}
	}
}

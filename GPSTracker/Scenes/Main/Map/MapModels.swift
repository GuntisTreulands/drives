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
import MapKit

enum Map {
	// MARK: Use cases

	enum DeleteAPoint {
		struct Request {
			var point: MapPoint
		}
	}
    
    enum MoveAPoint {
        struct Request {
            var point: MapPoint
            var newCoordinate: CLLocationCoordinate2D
        }
    }
    
    enum SplitAPoint {
        struct Request {
            var coordinate: CLLocationCoordinate2D
        }
    }
    
    enum DeleteInterval {
        struct Request {
            var point1: MapPoint
            var point2: MapPoint
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

//
//  MapPoint.swift
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
import MapKit
import CoreData

class MapPoint: NSObject, MKAnnotation {
	var title: String?
	var subtitle: String?
	var isStart: Bool
	var isEnd: Bool
	var coordinate: CLLocationCoordinate2D
	var objectID: NSManagedObjectID

	
    init(title: String, subtitle: String, isStart: Bool, isEnd: Bool, coordinate: CLLocationCoordinate2D, objectID: NSManagedObjectID) {
        self.title = title
        self.subtitle = subtitle
        self.isStart = isStart
        self.isEnd = isEnd
        self.coordinate = coordinate
        self.objectID = objectID
    }
}

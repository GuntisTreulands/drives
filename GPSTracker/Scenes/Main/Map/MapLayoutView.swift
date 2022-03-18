//
//  MapLayoutView.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit
import MapKit


protocol MapLayoutViewLogic: AnyObject {
	
}

protocol MapLayoutViewDataLogic: AnyObject {
	func updateData(data: [MapPoint])
}

class MapLayoutView: UIView, MapLayoutViewDataLogic, UIGestureRecognizerDelegate, MKMapViewDelegate {

	weak var controller: MapLayoutViewLogic?
	weak var superParentView: UIView!

	@IBOutlet var baseView: UIView!
	@IBOutlet var mapView: MKMapView!


	var data = [MapPoint]()

	var calculatedMaxPinWidth: CGFloat = 0
	var calculatedMaxPinHeight: CGFloat = 0
	var currentMapOffset: CGFloat = 0
//	var offsetRatio: Double = 1

	var allPinsMapRect: MKMapRect!
	var selectedPinMapRect: MKMapRect!

	var zoomOnUserWasDone: Bool = false
	var userDraggedOrZoomedMap: Bool = false
	var disableMapAdjusting: Bool = false

	var usedAccessoryViews: [MapPinAccessoryView] = []

	var polyLine: MKPolyline?


	// MARK: View lifecycle

	override init(frame: CGRect) {
   	super.init(frame: frame)
		setup()
  	}

  	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
    	setup()
	}

	deinit {

	}

	override func layoutSubviews() {
		super.layoutSubviews()
	}

	private func setup() {
		Bundle.main.loadNibNamed("MapLayoutView", owner: self, options: nil)
		addSubview(baseView)
		baseView.frame = self.bounds

		self.translatesAutoresizingMaskIntoConstraints = false
		baseView.translatesAutoresizingMaskIntoConstraints = false
		mapView.translatesAutoresizingMaskIntoConstraints = false

		baseView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		baseView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

		mapView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		mapView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

		mapView.delegate = self

		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragOrPinchMap(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.didDragOrPinchMap(_:)))
        panGesture.delegate = self
        pinchGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)
        mapView.addGestureRecognizer(pinchGesture)
  	}

	// MARK: Functions

	private func addNecessaryLinePoints() {
		if let polyLine = polyLine {
			mapView.removeOverlay(polyLine)
		}
		var array = [CLLocationCoordinate2D]()

		for i in 0 ..< self.data.count {
			array.append(self.data[i].coordinate)
		}

		let polyLine = MKPolyline.init(coordinates: array, count: array.count)
		mapView.addOverlay(polyLine)
		self.polyLine = polyLine
	}

	private func regionFor(mapPoints points: [MapPoint]) -> MKCoordinateRegion {
		var r = MKMapRect.null

		for i in 0 ..< points.count {
			let p = MKMapPoint(points[i].coordinate)
			r = r.union(MKMapRect(x: p.x, y: p.y, width: 0, height: 0))
		}

//		if points.isEmpty {
//			if mapView!.userLocation.location != nil {
//				let p = MKMapPoint(mapView!.userLocation.coordinate)
//				r = r.union(MKMapRect(x: p.x, y: p.y, width: 0, height: 0))
//			}
//		}

		var region = MKCoordinateRegion(r)

		region.span.latitudeDelta = max(0.002, region.span.latitudeDelta)
    	region.span.longitudeDelta = max(0.002, region.span.longitudeDelta)

		return region
	}

	private func MKMapRectForCoordinateRegion(region:MKCoordinateRegion) -> MKMapRect {
		let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
		let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))

		let a = MKMapPoint(topLeft)
		let b = MKMapPoint(bottomRight)

		return MKMapRect(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
	}

	private func zoomOnAllPins(animated: Bool) {

		let allPins = mapView.annotations.compactMap { $0 as? MapPoint }

		var r = MKMapRect.null

		for i in 0 ..< allPins.count {
			let p = MKMapPoint(allPins[i].coordinate)
			r = r.union(MKMapRect(x: p.x, y: p.y, width: 0.1, height: 0.1))
		}

		self.mapView.setVisibleMapRect(r, edgePadding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), animated: animated)


//
//		// For now, override.. because when user starts to mess with map, it sucks when it zooms out again..
//		if self.userDraggedOrZoomedMap == true { return }
//
//
//
//		if !disableMapAdjusting {
//			if self.userDraggedOrZoomedMap == true { disableMapAdjusting = true }
//
//			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//				self.userDraggedOrZoomedMap = false
//				self.disableMapAdjusting = false
//			})
//
//			if self.allPinsMapRect.origin.x != -1 { // In case allPinsMapRect is invalid (no pins?), zoom on country.
//
//				UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
//					self.mapView.setVisibleMapRect(self.allPinsMapRect, edgePadding: UIEdgeInsets(top: self.calculatedMaxPinHeight + 15, left: self.calculatedMaxPinWidth / 2 + 5, bottom: self.currentMapOffset + 5, right: self.calculatedMaxPinWidth / 2 + 5), animated: self.userDraggedOrZoomedMap == true ? true : animated)
//				}) { (result) in }
//			}
//		}
	}

	private func recalculateMapRect() {
		let allPins = mapView.annotations.compactMap { $0 as? MapPoint }
		let allPinsRegion = self.regionFor(mapPoints: allPins)
		allPinsMapRect = MKMapRectForCoordinateRegion(region: allPinsRegion)

		selectedPinMapRect = allPinsMapRect
	}

	// MARK: MapLayoutViewDataLogic

	func updateData(data: [MapPoint]) {

		self.data = data

		usedAccessoryViews.removeAll()

		mapView.removeAnnotations(mapView.annotations)

		mapView.addAnnotation(data.first!)

		mapView.addAnnotation(data.last!)
//		mapView.addAnnotations(data)

		recalculateMapRect()

		zoomOnAllPins(animated: false)

		addNecessaryLinePoints()
	}

	// MARK: MKMapViewDelegate

	@objc(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:) func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func didDragOrPinchMap(_ sender: UIGestureRecognizer) {
		userDraggedOrZoomedMap = true
    }

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

		guard !(annotation is MKUserLocation) else {
			return nil
		}

		let annotationIdentifier = "mapPoint"

		var annotationView: MKAnnotationView?
		if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
			annotationView = dequeuedAnnotationView
			annotationView?.annotation = annotation
		}
		else {
			let av = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
			annotationView = av

			if (annotation as! MapPoint).isStart {
				av.pinTintColor = UIColor.init(red: 69/255.0, green: 155/255.0, blue: 2/255.0, alpha: 1)
			} else {
				av.pinTintColor = .red
			}

			av.canShowCallout = true

			if #available(iOS 13.0, *) {
				let button = UIButton.init(type: .close)
				av.rightCalloutAccessoryView = button
			}

		}


//		if let annotationView = annotationView,
//		   let mapPointAnnotation = annotationView.annotation as? MapPoint {




//			annotationView.canShowCallout = false
//
//			// This is needed, otherwise, I noticed that in some cases, more than one gets added..
//			let mapPinAccessory = annotationView.viewWithTag(333) as? MapPinAccessoryView ?? MapPinAccessoryView()
//
//
//			mapPinAccessory.setAsTiny(true)
//			mapPinAccessory.title = mapPointAnnotation.title!
//
//
//			mapPinAccessory.setDistanceVisible(false)
//
//			mapPinAccessory.layoutIfNeeded()
//			mapPinAccessory.tag = 333
//
//
//			calculatedMaxPinWidth = max(mapPinAccessory.frame.width, calculatedMaxPinWidth)
//			calculatedMaxPinHeight = max(mapPinAccessory.frame.height, calculatedMaxPinHeight)
//
//			annotationView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
//			annotationView.addSubview(mapPinAccessory)
//
//			annotationView.frame = mapPinAccessory.frame
//
//			if usedAccessoryViews.contains(mapPinAccessory) == false {
//				usedAccessoryViews.append(mapPinAccessory)
//			}
//		}

		return annotationView
	}

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		guard !(view.annotation is MKUserLocation) else { return }

//		controller?.mapPinWasPressed(view.annotation as! MapPoint)
	}

//	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//		if !zoomOnUserWasDone {
//			zoomOnAllPins(animated: true)
//			zoomOnUserWasDone = true
//		}
//	}


	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay.isKind(of: MKPolyline.self) {
			// draw the track
			let polyLine = overlay
			let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
			polyLineRenderer.strokeColor = UIColor.black.withAlphaComponent(0.75)
			polyLineRenderer.lineWidth = 5.0

			return polyLineRenderer
		}

    	return MKPolylineRenderer()
	}
}

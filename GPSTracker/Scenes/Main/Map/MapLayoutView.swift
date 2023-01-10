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
	func mapPointWasPressed(_ point: MapPoint)
}

protocol MapLayoutViewDataLogic: AnyObject {
	func updateData(data: [[MapPoint]], editMode: Bool)
}

class MapLayoutView: UIView, MapLayoutViewDataLogic, UIGestureRecognizerDelegate, MKMapViewDelegate {

	weak var controller: MapLayoutViewLogic?
	weak var superParentView: UIView!

	@IBOutlet var baseView: UIView!
	@IBOutlet var mapView: MKMapView!


	var data = [[MapPoint]]()
	var editMode: Bool = false

	var calculatedMaxPinWidth: CGFloat = 0
	var calculatedMaxPinHeight: CGFloat = 0
	var currentMapOffset: CGFloat = 0

	var allPinsMapRect: MKMapRect!
	var selectedPinMapRect: MKMapRect!

	var zoomOnUserWasDone: Bool = false
	var userDraggedOrZoomedMap: Bool = false
	var disableMapAdjusting: Bool = false

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
		for overlay in mapView.overlays {
			mapView.removeOverlay(overlay)
		}

		var array = [CLLocationCoordinate2D]()

		for i in 0 ..< self.data.count {
			for j in 0 ..< self.data[i].count {
                array.append(self.data[i][j].coordinate)
			}

			let polyLine = MKPolyline.init(coordinates: array, count: array.count)
			mapView.addOverlay(polyLine)

			array.removeAll()
		}
	}

	private func regionFor(mapPoints points: [MapPoint]) -> MKCoordinateRegion {
		var r = MKMapRect.null

		for i in 0 ..< points.count {
			let p = MKMapPoint(points[i].coordinate)
			r = r.union(MKMapRect(x: p.x, y: p.y, width: 0, height: 0))
		}

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
	}

	private func recalculateMapRect() {
		let allPins = mapView.annotations.compactMap { $0 as? MapPoint }
		let allPinsRegion = self.regionFor(mapPoints: allPins)
		allPinsMapRect = MKMapRectForCoordinateRegion(region: allPinsRegion)

		selectedPinMapRect = allPinsMapRect
	}

	// MARK: MapLayoutViewDataLogic

	func updateData(data: [[MapPoint]], editMode: Bool) {

		self.editMode = editMode

		if self.data.isEmpty {
			self.data = data

			mapView.removeAnnotations(mapView.annotations)

			for drive in self.data {
				if !self.editMode {
					mapView.addAnnotation(drive.first!)

					mapView.addAnnotation(drive.last!)
				} else {

					mapView.addAnnotations(drive)
				}
			}

			recalculateMapRect()

			zoomOnAllPins(animated: false)

			addNecessaryLinePoints()
		} else {
			self.data = data
			mapView.removeAnnotations(mapView.annotations)

			for drive in self.data {
				if !self.editMode {
					mapView.addAnnotation(drive.first!)

					mapView.addAnnotation(drive.last!)
				} else {

					mapView.addAnnotations(drive)
				}
			}

		}
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

		if self.data.count > 1 {
			return MKAnnotationView.init()
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
		}

		let av = (annotationView as! MKPinAnnotationView)

		if (annotation as! MapPoint).title!.contains("$") {
			av.pinTintColor = UIColor.purple
		}
		else if (annotation as! MapPoint).isStart && !self.editMode {
			av.pinTintColor = UIColor.init(red: 69/255.0, green: 155/255.0, blue: 2/255.0, alpha: 1)
		} else {
			av.pinTintColor = .red
		}

		av.canShowCallout = true

		if #available(iOS 13.0, *) {
			if self.editMode {
				let button = UIButton.init(type: .close)
				av.rightCalloutAccessoryView = button
			}
		}

		return annotationView
	}

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		guard !(view.annotation is MKUserLocation) else { return }
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		if self.data.count > 1 {
			mapView.mapType = .satellite
			mapView.mapType = .standard
		}
	}


	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if self.editMode {
			let mapPoint = view.annotation as! MapPoint
			//print("mapPoint \(mapPoint)")
			controller?.mapPointWasPressed(view.annotation as! MapPoint)

			// We support only first line.
			let index = self.data[0].firstIndex(of: mapPoint)
			self.data[0].remove(at: index!)
			mapView.removeAnnotation(mapPoint)

			addNecessaryLinePoints()
		}
	}

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay.isKind(of: MKPolyline.self) {
			// draw the track
			let polyLine = overlay
			let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
			if self.data.count == 1 {
				polyLineRenderer.strokeColor = UIColor.black.withAlphaComponent(0.75)
				polyLineRenderer.lineWidth = 5.0
			} else {
				polyLineRenderer.strokeColor = UIColor.red.withAlphaComponent(0.4)
				polyLineRenderer.lineWidth = 2.0
			}

			return polyLineRenderer
		}

    	return MKPolylineRenderer()
	}
}

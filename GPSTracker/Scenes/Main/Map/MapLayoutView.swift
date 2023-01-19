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
    func deleteAMapPoint(_ point: MapPoint)
    func moveAMapPoint(_ point: MapPoint, newCoordinate: CLLocationCoordinate2D)
    func splitAMapPoint(_ coordinate: CLLocationCoordinate2D)
    func deleteIntervalBetween(_ point1: MapPoint, point2: MapPoint)
}

protocol MapLayoutViewDataLogic: AnyObject {
	func updateData(data: [[MapPoint]], editMode: Bool)
}

class MapLayoutView: UIView, MapLayoutViewDataLogic, UIGestureRecognizerDelegate, MKMapViewDelegate {

	weak var controller: MapLayoutViewLogic?
	weak var superParentView: UIView!

	@IBOutlet var baseView: UIView!
	@IBOutlet var mapView: MKMapView!

    @IBOutlet weak var centerDot: UIView!
    
    @IBOutlet weak var editBarView: UIView!
    @IBOutlet weak var p1p2Button: UIButton!
    @IBOutlet weak var deleteIntervalButton: UIButton!
    @IBOutlet weak var splitIntervalButton: UIButton!
    @IBOutlet weak var movePointButton: UIButton!
    
    var data = [[MapPoint]]()
	var editMode: Bool = false
    var shouldRedrawLines = false

	var calculatedMaxPinWidth: CGFloat = 0
	var calculatedMaxPinHeight: CGFloat = 0
	var currentMapOffset: CGFloat = 0

	var allPinsMapRect: MKMapRect!
	var selectedPinMapRect: MKMapRect!

	var zoomOnUserWasDone: Bool = false
	var disableMapAdjusting: Bool = false
    
    var selectedMapPoint: MapPoint?
    
    var selectedP1Point: MapPoint?
    var selectedP2Point: MapPoint?

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
        NotificationCenter.default.removeObserver(self, name: .fontSizeWasChanged, object: nil)
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
        centerDot.translatesAutoresizingMaskIntoConstraints = false
        editBarView.translatesAutoresizingMaskIntoConstraints = false
        p1p2Button.translatesAutoresizingMaskIntoConstraints = false
        deleteIntervalButton.translatesAutoresizingMaskIntoConstraints = false
        splitIntervalButton.translatesAutoresizingMaskIntoConstraints = false
        movePointButton.translatesAutoresizingMaskIntoConstraints = false

        
		baseView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		baseView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

		mapView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		mapView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

		mapView.delegate = self
        
        centerDot.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        centerDot.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
        centerDot.widthAnchor.constraint(equalToConstant: 22).isActive = true
        centerDot.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        centerDot.layer.cornerRadius = 11
        centerDot.layer.borderColor = UIColor.white.cgColor
        centerDot.layer.borderWidth = 3
        centerDot.backgroundColor = .blue
        centerDot.clipsToBounds = true
        centerDot.alpha = 0
        
        editBarView.backgroundColor = .white
        editBarView.leftAnchor.constraint(equalTo: mapView.leftAnchor).isActive = true
        editBarView.rightAnchor.constraint(equalTo: mapView.rightAnchor).isActive = true
        editBarView.topAnchor.constraint(equalTo: mapView.topAnchor).isActive = true
        editBarView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let space1 = UILayoutGuide.init()
        editBarView.addLayoutGuide(space1)
        let space2 = UILayoutGuide.init()
        editBarView.addLayoutGuide(space2)
        let space3 = UILayoutGuide.init()
        editBarView.addLayoutGuide(space3)
        
        let space1Constraint = space1.widthAnchor.constraint(equalToConstant: 1)
        space1Constraint.priority = .defaultLow
        space1Constraint.isActive = true
        let space2Constraint = space2.widthAnchor.constraint(equalTo: space1.widthAnchor)
        space2Constraint.priority = .defaultLow
        space2Constraint.isActive = true
        let space3Constraint = space3.widthAnchor.constraint(equalTo: space1.widthAnchor)
        space3Constraint.priority = .defaultLow
        space3Constraint.isActive = true
        
       
        p1p2Button.leftAnchor.constraint(equalTo: editBarView.leftAnchor, constant: 20).isActive = true
        p1p2Button.topAnchor.constraint(equalTo: editBarView.topAnchor, constant: 5).isActive = true
        p1p2Button.bottomAnchor.constraint(equalTo: editBarView.bottomAnchor, constant: -5).isActive = true
        
        space1.leftAnchor.constraint(equalTo: p1p2Button.rightAnchor).isActive = true
        
        deleteIntervalButton.leftAnchor.constraint(equalTo: space1.rightAnchor).isActive = true
        deleteIntervalButton.topAnchor.constraint(equalTo: editBarView.topAnchor, constant: 5).isActive = true
        deleteIntervalButton.bottomAnchor.constraint(equalTo: editBarView.bottomAnchor, constant: -5).isActive = true
        
        space2.leftAnchor.constraint(equalTo: deleteIntervalButton.rightAnchor).isActive = true
        
        splitIntervalButton.leftAnchor.constraint(equalTo: space2.rightAnchor).isActive = true
        splitIntervalButton.topAnchor.constraint(equalTo: editBarView.topAnchor, constant: 5).isActive = true
        splitIntervalButton.bottomAnchor.constraint(equalTo: editBarView.bottomAnchor, constant: -5).isActive = true
        
        space3.leftAnchor.constraint(equalTo: splitIntervalButton.rightAnchor).isActive = true
        
        movePointButton.leftAnchor.constraint(equalTo: space3.rightAnchor).isActive = true
        movePointButton.topAnchor.constraint(equalTo: editBarView.topAnchor, constant: 5).isActive = true
        movePointButton.bottomAnchor.constraint(equalTo: editBarView.bottomAnchor, constant: -5).isActive = true
        movePointButton.rightAnchor.constraint(equalTo: editBarView.rightAnchor, constant: -20).isActive = true
        
        p1p2Button.setTitle("map_select_interval".localized(), for: .normal)
        deleteIntervalButton.setTitle("map_delete_interval".localized(), for: .normal)
        splitIntervalButton.setTitle("map_split_interval".localized(), for: .normal)
        movePointButton.setTitle("map_move_point".localized(), for: .normal)
        
        p1p2Button.addTarget(self, action: #selector(p1p2ButtonPressed), for: .touchUpInside)
        deleteIntervalButton.addTarget(self, action: #selector(deleteIntervalButtonPressed), for: .touchUpInside)
        splitIntervalButton.addTarget(self, action: #selector(splitIntervalButtonPressed), for: .touchUpInside)
        movePointButton.addTarget(self, action: #selector(movePointButtonPressed), for: .touchUpInside)
        
        deleteIntervalButton.isEnabled = false
        splitIntervalButton.isEnabled = false
        movePointButton.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(fontSizeWasChanged),
            name: .fontSizeWasChanged, object: nil)
        
        updateFonts()
  	}

	// MARK: Functions
    
    internal func updateFonts() {
        p1p2Button.titleLabel?.font = Font(.medium, size: .size15).font
        deleteIntervalButton.titleLabel?.font = Font(.medium, size: .size15).font
        splitIntervalButton.titleLabel?.font = Font(.medium, size: .size15).font
        movePointButton.titleLabel?.font = Font(.medium, size: .size15).font
    }
    
    @objc private func p1p2ButtonPressed() {
        p1p2Button.isSelected = !p1p2Button.isSelected
        self.splitIntervalButton.isEnabled = !p1p2Button.isSelected
        
        self.updateData(data: self.data, editMode: self.editMode)
    }
    
    @objc private func deleteIntervalButtonPressed() {
        if let selectedP1Point = selectedP1Point, let selectedP2Point = selectedP2Point {
            shouldRedrawLines = true
            self.controller?.deleteIntervalBetween(selectedP1Point, point2: selectedP2Point)
        }
        selectedP1Point = nil
        selectedP2Point = nil
        p1p2Button.isSelected = false
        deleteIntervalButton.isEnabled = false
    }
    
    @objc private func splitIntervalButtonPressed() {
        shouldRedrawLines = true
        self.controller?.splitAMapPoint(self.mapView.centerCoordinate)
    }
    
    @objc private func movePointButtonPressed() {
        if let selectedMapPoint = selectedMapPoint {
            shouldRedrawLines = true
            self.controller?.moveAMapPoint(selectedMapPoint, newCoordinate: self.mapView.centerCoordinate)
        }
    }
    
    
    private func disableEditBarFunctions() {
        selectedP1Point = nil
        selectedP2Point = nil
        p1p2Button.isSelected = false
        deleteIntervalButton.isEnabled = false
        splitIntervalButton.isEnabled = false
        movePointButton.isEnabled = false
    }
    
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
        self.editBarView.alpha = self.editMode == true ? 1 : 0
        self.centerDot.alpha = self.editMode == true ? 1 : 0
        self.splitIntervalButton.isEnabled = self.editMode

        if self.editMode == false {
            disableEditBarFunctions()
        }
        
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
        
        if shouldRedrawLines {
            shouldRedrawLines = false
            addNecessaryLinePoints()
        }
	}
    
	// MARK: MKMapViewDelegate

	@objc(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:) func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
		} else if (annotation as! MapPoint) == selectedP1Point || (annotation as! MapPoint) == selectedP2Point {
            av.pinTintColor = .blue
        } else if (annotation as! MapPoint).isStart && !self.editMode {
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
        
        if self.editMode == true {
            let mapPoint = view.annotation as! MapPoint
            
            if p1p2Button.isSelected {
                if selectedP1Point == nil {            // Set P1
                    selectedP1Point = mapPoint
                    mapView.removeAnnotation(selectedP1Point!)
                    mapView.addAnnotation(selectedP1Point!)
                } else if selectedP1Point != nil && selectedP2Point == nil {      // Set P2
                    selectedP2Point = mapPoint
                    mapView.removeAnnotation(selectedP2Point!)
                    mapView.addAnnotation(selectedP2Point!)
                    deleteIntervalButton.isEnabled = true
                } else if selectedP2Point != nil {      // Disable P2 and Set P1
                    selectedP1Point = mapPoint
                    selectedP2Point = nil
                    deleteIntervalButton.isEnabled = false
                    self.updateData(data: self.data, editMode: self.editMode)
                }
            } else {
                selectedMapPoint = mapPoint
                movePointButton.isEnabled = true
            }
        }
	}
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard !(view.annotation is MKUserLocation) else { return }
        
        if self.editMode == true {
            movePointButton.isEnabled = false
            selectedMapPoint = nil
        }
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
			controller?.deleteAMapPoint(view.annotation as! MapPoint)

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
    
    // MARK: Notifications

    @objc private func fontSizeWasChanged() {
        updateFonts()
    }
}

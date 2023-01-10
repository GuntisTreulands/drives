//
//  MapViewController.swift
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



protocol MapDisplayLogic: AnyObject {
	func presentMap(viewModel: Map.FetchPoints.ViewModel)
}

class MapViewController: UIViewController, MapDisplayLogic, MapLayoutViewLogic {

	var interactor: MapBusinessLogic?
	var router: (NSObjectProtocol & MapRoutingLogic & MapDataPassing)?
	var layoutView: MapLayoutView!
	var editModeEnabled: Bool = false

	// MARK: Object lifecycle

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	// MARK: View lifecycle

	deinit {
    	NotificationCenter.default.removeObserver(self, name: .languageWasChanged, object: nil)
    	NotificationCenter.default.removeObserver(self, name: .fontSizeWasChanged, object: nil)
    	NotificationCenter.default.removeObserver(self, name: .settingsUpdated, object: nil)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
    	NotificationCenter.default.addObserver(self, selector: #selector(languageWasChanged),
    		name: .languageWasChanged, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(fontSizeWasChanged),
    		name: .fontSizeWasChanged, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(settingsUpdated),
    		name: .settingsUpdated, object: nil)

		setUpView()

		self.getData()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
    	self.navigationController!.navigationBar.shadowImage = UIImage()
		self.navigationController!.navigationBar.isTranslucent = true
    	self.view.backgroundColor = .white
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		DataBaseWorker.calculateStartAndEndAddressForDrives()
	}


	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	//MARK: Set up

	private func setup() {
		let viewController = self
		let interactor = MapInteractor()
		let presenter = MapPresenter()
		let router = MapRouter()
		viewController.interactor = interactor
		viewController.router = router
		interactor.presenter = presenter
		presenter.viewController = viewController
		router.viewController = viewController
		router.dataStore = interactor

		setUpTopRightButton()
	}

	private func setUpView() {
		layoutView = MapLayoutView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
		self.view.addSubview(layoutView)
		layoutView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        layoutView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        layoutView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        layoutView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
		layoutView.controller = self
	}

	private func setUpTopRightButton() {
		if editModeEnabled {
			self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(editButtonPressed))
		} else {
			self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
		}
	}

	// MARK: Functions

	func getData() {
		let request = Map.FetchPoints.Request()
		interactor?.fetchPoints(request: request)
	}

	@objc func editButtonPressed() {
        editModeEnabled.toggle()

		setUpTopRightButton()

		getData()
	}

	// MARK: MapDisplayLogic

	func presentMap(viewModel: Map.FetchPoints.ViewModel) {

		if viewModel.mapPoints.count > 1 {
			self.navigationItem.rightBarButtonItem = nil
		}

		self.layoutView.updateData(data: viewModel.mapPoints, editMode: editModeEnabled)
		self.title = viewModel.title
	}


	// MARK: MapLayoutViewLogic

	func mapPointWasPressed(_ point: MapPoint) {
		self.interactor?.deleteAPoint(request: Map.DeleteAPoint.Request.init(point: point))
	}

	// MARK: Notifications

	@objc private func languageWasChanged() {
		getData()
	}

	@objc private func fontSizeWasChanged() {

	}

	@objc private func settingsUpdated() {

	}

}

//
//  AppSettingsWorker.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import UserNotifications
import CoreTelephony
import UserNotifications


enum SettingsToggleResult<Value> {
	case firstTime
	case secondTime
}


extension Notification.Name {
    static let applicationDidBecomeActiveFromAppSettings = Notification.Name("applicationDidBecomeActiveFromAppSettings")

    static let languageWasChanged = Notification.Name("languageWasChanged")

    static let settingsUpdated = Notification.Name("settingsUpdated")

    static let fontSizeWasChanged = Notification.Name("fontSizeWasChanged")
}

protocol AppSettingsWorkerLogic {
	func setUpGlobalFontColorAndSize()

	func getCurrentLanguage() -> AppSettingsWorker.Language
	func setCurrentLanguage(_ language: AppSettingsWorker.Language)

	func notifDriveEndSwitchWasPressed(_ handler: @escaping () -> Void)
	func getNotifDriveEndIsEnabled() -> Bool
	func setNotifDriveEndIsEnabled(enabled: Bool)

	func notifWarningSwitchWasPressed(_ handler: @escaping () -> Void)
	func getNotifWarningIsEnabled() -> Bool
	func setNotifWarningIsEnabled(enabled: Bool)

	func userPressedButtonToGetGPSAccess(_ handler: @escaping (SettingsToggleResult<Any>) -> Void)
	func getGPSIsEnabled() -> Bool
	func getCurrentLocation() -> CLLocation?
	func setLocationManagerInAnActiveState(_ active: Bool)
	func startMonitoringRegionForLocation(_ location: CLLocation)
	func stopMonitoringAnyRegions()

	func userPressedButtonToGetMotionAccess(_ handler: @escaping (SettingsToggleResult<Any>) -> Void)
	func getMotionIsEnabled() -> Bool
}

class AppSettingsWorker: NSObject, AppSettingsWorkerLogic, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

	enum Language: String {
		case latvian = "lv"
		case russian = "ru"
		case english = "en"
	}

	static let shared = AppSettingsWorker()

	private let activityManager = CMMotionActivityManager()

	private let locationManager = CLLocationManager()

	var openDate = Date()

	var settingsSwitchHandler: ((SettingsToggleResult<Any>) -> Void)?
	var notificationsAuthorisationStatus: UNAuthorizationStatus = .notDetermined
	var languageBundle: Bundle!


	//--- Used to get specific translation.
	var ruLanguageBundle = Bundle(path: Bundle.main.path(forResource: "ru", ofType: "lproj")!)!
	var lvLanguageBundle = Bundle(path: Bundle.main.path(forResource: "lv", ofType: "lproj")!)!
	var enLanguageBundle = Bundle(path: Bundle.main.path(forResource: "en", ofType: "lproj")!)!
	//===

	private override init() {
		super.init()

		locationManager.delegate = self
		setLocationManagerInAnActiveState(false)
		locationManager.pausesLocationUpdatesAutomatically = false
		locationManager.allowsBackgroundLocationUpdates = true
		locationManager.activityType = .automotiveNavigation

		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse
			|| CLLocationManager.authorizationStatus() == .authorizedAlways {
			locationManager.requestAlwaysAuthorization()
			locationManager.startUpdatingLocation()
		}


		locationManager.startMonitoringVisits()

    	NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
		
		refreshCurrentNotificationsStatus {}

		Font.recalculateFontIncreaseSize()
		
		self.setUpBundle()

		setUpGlobalFontColorAndSize()

		UNUserNotificationCenter.current().delegate = self

		if CMMotionActivityManager.authorizationStatus() != .notDetermined {
			startMotionTracking()
		}


		_ = Timer.scheduledTimer(timeInterval: 60*2, target: self, selector: #selector(safetyInformOfClosedApp), userInfo: nil, repeats: true)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
   			self.safetyInformOfClosedApp()
   			self.setLocationManagerInAnActiveState(true)
		}



	}

	func startMotionTracking() {

		if CMMotionActivityManager.authorizationStatus() == .authorized
			|| CMMotionActivityManager.authorizationStatus() == .notDetermined
		{
			activityManager.startActivityUpdates(to: OperationQueue.main) { (motion) in
				if let motion = motion {
					ActivityWorker.shared.actOnAReceivedMotion(motion)
				}
			}
		} else {
			activityManager.stopActivityUpdates()
		}
	}

	func setUpGlobalFontColorAndSize() {
		UINavigationBar.appearance().tintColor = UIColor(named: "TitleColor")!
		UINavigationBar.appearance().titleTextAttributes =
			[NSAttributedString.Key.foregroundColor: UIColor(named: "TitleColor")!,
			NSAttributedString.Key.font: Font(.normal, size: .size1).font]
	}

	// MARK: Notifications

	@objc private func applicationDidBecomeActive() {
		refreshCurrentNotificationsStatus {
			DispatchQueue.main.asyncAfter(deadline: .now()) {
				NotificationCenter.default.post(name: .applicationDidBecomeActiveFromAppSettings, object: nil)
				DataBaseWorker.calculateDistanceAndTimeForDrives()
				DataBaseWorker.calculateStartAndEndAddressForDrives()
			}
		}
	}

	// MARK: Language

	func getCurrentLanguage() -> Language {
		// 1. Use previously selected/detected language.
		if let language = UserDefaults.standard.string(forKey: "Language") {
			return Language(rawValue: language)!
		}

		// 2. Check prefered phone language. If it is russian, then select russian
		let preferredLanguage = Locale.preferredLanguages[0] as String
		if preferredLanguage.lowercased().contains("ru") { return Language.russian }

		// 3. Check prefered phone language. If it is latvian, then select latvian
		if preferredLanguage.lowercased().contains("lv") { return Language.latvian }

		// 4. Check sim card country. If it is latvian, then select latvian
//		let telephony = CTTelephonyNetworkInfo()
		let carrier = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value
		print("carrier \(String(describing: carrier))")
		if let carrier = carrier, carrier.mobileCountryCode == "247" {
			return Language.latvian
		}

		// 5. If all other check fails - go to default, english.
		return Language.english
	}

	func setCurrentLanguage(_ language: Language) {
		UserDefaults.standard.set(language.rawValue, forKey: "Language")
		UserDefaults.standard.synchronize()
		setUpBundle()
		NotificationCenter.default.post(name: .languageWasChanged, object: nil)
	}

	private func setUpBundle() {
        if let path = Bundle.main.path(forResource: self.getCurrentLanguage().rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            languageBundle = bundle
        }
        // Default will work.
        else if let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
            let bundle = Bundle(path: path) {
            languageBundle = bundle
        }
	}

	// MARK: Notif Drive End

	func notifDriveEndSwitchWasPressed(_ handler: @escaping () -> Void) {

		// If status is not determined - request auth.
		// Otherwise, if status is accepted -> turn off |  If declined, then open settings

		if notificationsAuthorisationStatus == .notDetermined {
			UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
				[weak self] granted, error in

				// First time, getting access and then set to true if authorized.
				self?.refreshCurrentNotificationsStatus {
					if self?.notificationsAuthorisationStatus == .authorized { self?.setNotifDriveEndIsEnabled(enabled: true) }
					DispatchQueue.main.asyncAfter(deadline: .now()) { handler() }
				}
			}
		} else {
			if notificationsAuthorisationStatus == .authorized {
				var notifEnabled = getNotifDriveEndIsEnabled()
				notifEnabled.toggle()
				setNotifDriveEndIsEnabled(enabled: notifEnabled)
			}
			DispatchQueue.main.asyncAfter(deadline: .now()) { handler() }
		}
  	}

	func getNotifDriveEndIsEnabled() -> Bool {
		if notificationsAuthorisationStatus == .denied { return false }
		return UserDefaults.standard.bool(forKey: "Notif_Drive_End")
	}

	func setNotifDriveEndIsEnabled(enabled: Bool) {
		UserDefaults.standard.set(enabled, forKey: "Notif_Drive_End")
		UserDefaults.standard.synchronize()
	}

	// MARK: Notif Warning

	func notifWarningSwitchWasPressed(_ handler: @escaping () -> Void) {

		// If status is not determined - request auth.
		// Otherwise, if status is accepted -> turn off |  If declined, then open settings

		if notificationsAuthorisationStatus == .notDetermined {
			UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
				[weak self] granted, error in

				// First time, getting access and then set to true if authorized.
				self?.refreshCurrentNotificationsStatus {
					if self?.notificationsAuthorisationStatus == .authorized { self?.setNotifWarningIsEnabled(enabled: true) }
					DispatchQueue.main.asyncAfter(deadline: .now()) { handler() }
				}
			}
		} else {
			if notificationsAuthorisationStatus == .authorized {
				var notifEnabled = getNotifWarningIsEnabled()
				notifEnabled.toggle()
				setNotifWarningIsEnabled(enabled: notifEnabled)
			}

			DispatchQueue.main.asyncAfter(deadline: .now()) { handler() }
		}
  	}

	func getNotifWarningIsEnabled() -> Bool {
		if notificationsAuthorisationStatus == .denied { return false }
		return UserDefaults.standard.bool(forKey: "Notif_Warning")
	}

	func setNotifWarningIsEnabled(enabled: Bool) {
		UserDefaults.standard.set(enabled, forKey: "Notif_Warning")
		UserDefaults.standard.synchronize()
	}

  	// MARK: GPS
  	// Pressed from Intro and from Settings
  	func userPressedButtonToGetGPSAccess(_ handler: @escaping (SettingsToggleResult<Any>) -> Void) {

  		if CLLocationManager.authorizationStatus() == .notDetermined
		{
			locationManager.requestAlwaysAuthorization()
			settingsSwitchHandler = handler;

			return;
		}

		handler(.secondTime)
  	}

	func getGPSIsEnabled() -> Bool {
		if !CLLocationManager.locationServicesEnabled() {
			return false
		}

		if CLLocationManager.authorizationStatus() == .denied
			|| CLLocationManager.authorizationStatus() == .notDetermined {
			return false
		}

		return true
	}

	func getCurrentLocation() -> CLLocation? {
		return locationManager.location
	}


	func setLocationManagerInAnActiveState(_ active: Bool) {
		if active {
			locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//			locationManager.startMonitoringSignificantLocationChanges()
		} else {
			locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
//			locationManager.stopMonitoringSignificantLocationChanges()
		}
	}

	func startMonitoringRegionForLocation(_ location: CLLocation) {
		let parkedGeoFence = CLCircularRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), radius: 100, identifier: "parkedGeofence")
		parkedGeoFence.notifyOnEntry = true
		parkedGeoFence.notifyOnExit = true
		locationManager.startMonitoring(for: parkedGeoFence)
	}

	func stopMonitoringAnyRegions() {
		for region in locationManager.monitoredRegions {
			locationManager.stopMonitoring(for: region)
		}
	}

	// MARK: Motion

	// Pressed from Intro and from Settings
  	func userPressedButtonToGetMotionAccess(_ handler: @escaping (SettingsToggleResult<Any>) -> Void) {

  		if CMMotionActivityManager.authorizationStatus() == .notDetermined
		{
			handler(.firstTime)

			startMotionTracking()

			return;
		}

		handler(.secondTime)
  	}

	func getMotionIsEnabled() -> Bool {
		if CMMotionActivityManager.authorizationStatus() == .authorized {
			return true

		}
		return false
	}

	// MARK: Private

	private func refreshCurrentNotificationsStatus(_ handler: @escaping () -> Void) {
		UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
			self?.notificationsAuthorisationStatus = settings.authorizationStatus
			handler()
		}
	}

	@objc private func safetyInformOfClosedApp() {
		print("timer! \(Date())")

		if AppSettingsWorker.shared.getNotifWarningIsEnabled() {

			print("safetyInformOfClosedApp")

			UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["GPS_DRIVE_WARN"])
			UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["GPS_DRIVE_WARN"])


			let content = UNMutableNotificationContent()
			content.title = "debug_app_closed_title".localized()
			content.body = "debug_launch_app_before_next_drive".localized()
			content.sound = UNNotificationSound.default
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*2+60, repeats: false)
			let request = UNNotificationRequest(identifier: "GPS_DRIVE_WARN", content: content, trigger: trigger)
			UNUserNotificationCenter.current().add(request)
		}




		if Date().timeIntervalSince1970 - openDate.timeIntervalSince1970 > 60 * 10 {

			if !ActivityWorker.shared.isDrivingCurrently {

				if locationManager.desiredAccuracy != kCLLocationAccuracyThreeKilometers {
					print("Stopping active GPS, because not driving.")
					setLocationManagerInAnActiveState(false)

					let content = UNMutableNotificationContent()
					content.title = "debug_info_title".localized()
					content.body = "debug_stopping_active_gps".localized()
					content.sound = UNNotificationSound.default
					let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
					let request = UNNotificationRequest(identifier: "Info", content: content, trigger: trigger)
					UNUserNotificationCenter.current().add(request)
				}
			}
		}
	}

	// MARK: CLLocationManagerDelegate

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

		if let tmpGpsSwitchHandler = settingsSwitchHandler {
			tmpGpsSwitchHandler(.firstTime)
			settingsSwitchHandler = nil
		}

		if status == .authorizedWhenInUse || status == .authorizedAlways {
			locationManager.startUpdatingLocation()
		} else {
			locationManager.stopUpdatingLocation()
		}
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
	{
		if let tmpGpsSwitchHandler = settingsSwitchHandler {
			tmpGpsSwitchHandler(.firstTime)

			settingsSwitchHandler = nil
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

//		print("did Update Locations \(Date())")

		if let lastLocation = locations.last {
			ActivityWorker.shared.tryToAddAPointFromALocation(lastLocation)
		}


	}

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

//		if region.identifier == "geo_fence_home_car"
//		{
//			let content = UNMutableNotificationContent()
//			content.title = "CAR Region Geofence"
//			content.body = "Device is within car home parking location region."
//			content.sound = UNNotificationSound.default
//			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//			let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
//			UNUserNotificationCenter.current().add(request)
//		}
//		else if region.identifier == "geo_fence_gate"
//		{
//			let content = UNMutableNotificationContent()
//			content.title = "GATE Region Geofence"
//			content.body = "Device is within gate location region."
//			content.sound = UNNotificationSound.default
//			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//			let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
//			UNUserNotificationCenter.current().add(request)
//		}
//		else if region.identifier == "geo_fence_home"
//		{
//			let content = UNMutableNotificationContent()
//			content.title = "Home Region Geofence"
//			content.body = "Device just entered home region."
//			content.sound = UNNotificationSound.default
//			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//			let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
//			UNUserNotificationCenter.current().add(request)
//		}
	}

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {

//		if region.identifier == "geo_fence_home"
//		{
//			let content = UNMutableNotificationContent()
//			content.title = "Home Region Geofence"
//			content.body = "Device just left home region."
//			content.sound = UNNotificationSound.default
//			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//			let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
//			UNUserNotificationCenter.current().add(request)
//		}
	}

	func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
//		let content = UNMutableNotificationContent()
//			content.title = "Visit"
//			content.body = "Device just visited some place. (\(visit.description))"
//			content.sound = UNNotificationSound.default
//			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//			let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
//			UNUserNotificationCenter.current().add(request)
	}

	// MARK: UNUserNotificationCenterDelegate

	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

	}

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    }

//  @available(iOS 12.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {

    }
}

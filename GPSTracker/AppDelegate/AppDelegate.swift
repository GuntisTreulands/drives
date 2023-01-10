//
//  AppDelegate.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit
import CoreData
import Sentry
import UserNotifications
import UserNotificationsUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
//	var appSettings = AppSettingsWorker.shared

	func application(_ application: UIApplication, didFinishLaunchingWithOptions
		launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

		SentrySDK.start { options in
			options.dsn = "https://da766b8be7b3499580d043df9176bcdb@o115860.ingest.sentry.io/6235431"
			options.debug = true // Enabled debug when first installing is always helpful

			// Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
			// We recommend adjusting this value in production.
			options.tracesSampleRate = 0.8
		}

		// To initiate it.
		_ = AppSettingsWorker.shared
		_ = DataBaseManager.shared

		//ScenesManager.shared.resetState() // For debug, to start over.
		window?.backgroundColor = .white
		ScenesManager.shared.window = window
		ScenesManager.shared.setRootViewController(animated: false)

		

		if(UIApplication.shared.applicationState == .background) {
			let content = UNMutableNotificationContent()
			content.title = "debug_info_title".localized()
			content.body = "debug_app_was_opened_in_bg".localized()
			content.sound = UNNotificationSound.default
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
			let request = UNNotificationRequest(identifier: "App opened", content: content, trigger: trigger)
			UNUserNotificationCenter.current().add(request)
		}

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		
		Font.recalculateFontIncreaseSize()

		DataBaseWorker.invalidateAnyEntriesWithNoAddress()
		DataBaseWorker.calculateStartAndEndAddressForDrives()
		DataBaseWorker.calculateDistanceAndTimeForDrives()
		DataBaseWorker.calculateFilteredPointsForDrives()

		DataDownloader.shared.activateProcess()
		
		UNUserNotificationCenter.current().removeAllDeliveredNotifications()
	}

	func applicationWillTerminate(_ application: UIApplication) {
		let crumb = Breadcrumb()
		crumb.level = SentryLevel.info
		crumb.category = "problem"
		crumb.message = "applicationWillTerminate"
		SentrySDK.addBreadcrumb(crumb: crumb)
	}

	func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
		let crumb = Breadcrumb()
		crumb.level = SentryLevel.info
		crumb.category = "problem"
		crumb.message = "applicationDidReceiveMemoryWarning"
		SentrySDK.addBreadcrumb(crumb: crumb)
	}
 
	// MARK: Functions

	func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

	   completionHandler(.noData)
   }
}

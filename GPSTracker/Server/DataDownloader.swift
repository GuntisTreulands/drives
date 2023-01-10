//
//  DataDownloader.swift
//
//
//  Created by Guntis on 28/12/2019.
//  Copyright © 2019 . All rights reserved.
//

import Foundation
import CoreData
import UIKit


protocol DataDownloaderLogic {
	func activateProcess()
}

class DataDownloader: NSObject, DataDownloaderLogic {

	static let shared = DataDownloader()

	public var carDataDownloader: CarDataDownloader!

	private override init() {
		super.init()

		carDataDownloader = CarDataDownloader()
//		carDataDownloader.resetLastDownloadTime()
	}

	public var downloaderIsActive: Bool = false {
		didSet {
			DispatchQueue.main.asyncAfter(deadline: .now()) {
				NotificationCenter.default.post(name: .dataDownloaderStateChange, object: nil)
			}
		}
	}

	// MARK: DataDownloaderLogic

	func activateProcess() {

		if DataDownloader.shared.downloaderIsActive
		{
			print("Downloader is still active. Stopping.")
			return;
		}

		print("activating process!! Please wait!");


		if CarDataDownloader.isAllowedToDownload() {
			print("CarDataDownloader.isAllowedToDownload() == true! ");

			print("self.pricesDownloader.work | start ");
			self.carDataDownloader.work
			{
				print("self.pricesDownloader.work | end ");
				// Problem.. No internet? Server problem? No point in continueing...
				if(CarDataDownloader.downloadingState != .downloaded)
				{
					print("PricesDownloader.downloadingState != .downloaded (actually \(CarDataDownloader.downloadingState)) | Report to Sentry | Stopping.");
					// Report to Sentry
				} else {
					print("self.companiesDownloader.work | start ");

				}
			}
		} else {
			print("CarDataDownloader.isAllowedToDownload() == false! ");
		}
	}
}

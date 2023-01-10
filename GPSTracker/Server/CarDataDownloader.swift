//
//  CarDataDownload.swift
//
//
//  Created by Guntis on 09/02/2020.
//  Copyright © 2020 . All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol CarDataDownloaderLogic {
	static func isAllowedToDownload() -> Bool
	static func updateLastSuccessTime()
	static func resetLastSuccessTime()
	func work(completionHandler: @escaping () -> Void)
}

class CarDataDownloader: CarDataDownloaderLogic {

	static var downloadingState: DownloaderState {
		if DataDownloader.shared.downloaderIsActive {
			return .downloading
		}

		if lastDownloadResult == .none {
			return .downloading
		}
		else
		{
			switch lastDownloadResult {
				case .none:
					return .downloaded
				case .success:
					return .downloaded
				case .timeout:
					return .timeout
				case .serverError:
					return .serverError
				case .parsingError:
					return
						.parsingError
			}
		}
	}

	static var lastDownloadResult: DownloaderLastResult = .none

	class func isAllowedToDownload() -> Bool {

//		return true

		let lastDownloadTimestamp = UserDefaults.standard.double(forKey: "CarDataDownloaderTimestamp")

		if lastDownloadTimestamp + 60 * 60 * 24 <= Date().timeIntervalSince1970 {
			return true
		}

		if lastDownloadTimestamp == 0 {
			return true
		}

		return false
	}

	class func updateLastSuccessTime() {
		UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "CarDataDownloaderTimestamp")
		UserDefaults.standard.synchronize()
	}

	class func resetLastSuccessTime() {
		UserDefaults.standard.set(0, forKey: "CarDataDownloaderTimestamp")
		UserDefaults.standard.synchronize()
	}


	func work(completionHandler: @escaping () -> Void) {

		if !CarDataDownloader.isAllowedToDownload() {
			print("CarDataDownloader not allowed")
			completionHandler()
			return
		}

		if DataDownloader.shared.downloaderIsActive {
			completionHandler()
			return
		}

		DataDownloader.shared.downloaderIsActive = true

		DispatchQueue.background(background: {
			// do something in background

			let string = PrivateGatesHelperWorker.myCarDataServerUrlString
//			let string = "https://api.npoint.io/3547e169b48658ed9d65" // Demo data

			//This is how my demo payload will look.
			// costs: simply contains for each month I had a car - total cost for car for that month
			// valueDrop: simply contains for each month aprox price drop (In reality I calculate car price drop once a year, but then I divide that value by 12, to have it ~ for each month.)

			//{"costs":[1469.82,172.48,73.43,190.6....],"valueDrop":[125,125,125,125,...]}


			print("Car data downloading url \(string)")

			let sessionConfig = URLSessionConfiguration.default
			sessionConfig.timeoutIntervalForRequest = 10.0
			sessionConfig.timeoutIntervalForResource = 60.0

			let session = URLSession(configuration: sessionConfig)

			var request = URLRequest(url: URL(string: string)!)
			request.httpMethod = "GET"


			session.dataTask(with: request) { data, response, error in

				if let httpResponse = response as? HTTPURLResponse {
					print("httpResponse.statusCode \(httpResponse.statusCode)")
				}

				// Check if data was received successfully
				if error == nil && data != nil {
					print("CarDataDownloader - Success")
					CarDataDownloader.lastDownloadResult = .success
					CarDataDownloader.updateLastSuccessTime()

					do {
						let jsonDecoder = JSONDecoder()
						let responseModel = try jsonDecoder.decode(MyCarDataModel.self, from: data!)

						print("responseModel \(responseModel)")

						if let costsArray = responseModel.costs, let valueDropArray = responseModel.valueDrop {

							DispatchQueue.main.asyncAfter(deadline: .now()) {

								// Okay now that we have parsed.. We need to:
								// Empty our database
								// Write in new values
								// Quick and dirty way
								let task = {

									let context = DataBaseManager.shared.mainManagedObjectContext()
									let fetchRequestCarCosts: NSFetchRequest<CarCostsEntity> = CarCostsEntity.fetchRequest()
									var carCosts = [CarCostsEntity]()
									do { carCosts = try context.fetch(fetchRequestCarCosts) } catch { }

									let fetchRequestValueDrop: NSFetchRequest<ValueDropEntity> = ValueDropEntity.fetchRequest()
									var valueDrop = [ValueDropEntity]()
									do { valueDrop = try context.fetch(fetchRequestValueDrop) } catch { }

									// First delete old values
									for cost in carCosts { context.delete(cost) }
									for value in valueDrop { context.delete(value) }

									// Add to DB new values
									for (index, cost) in costsArray.enumerated() {
										let newCost = CarCostsEntity.init(context: context)
										newCost.sortId = Int16(index)
										newCost.value = cost
									}
									// Add to DB new values
									for (index, valueDrop) in valueDropArray.enumerated() {
										let newValueDrop = ValueDropEntity.init(context: context)
										newValueDrop.sortId = Int16(index)
										newValueDrop.value = valueDrop
									}

									DataBaseManager.shared.saveContext()
								}

								DataBaseManager.shared.addATask(action: task)
							}
						}
					} catch {
						print("JSONSerialization error:", error)
					}

				} else {
					print("CarDataDownloader - Received error OR no data. \(error ?? "" as! Error)")

					if let error = error {

						CarDataDownloader.resetLastSuccessTime()

						print("(error as NSError).code \((error as NSError).code)")

						if (error as NSError).code == -1009 { // No internet connection
							CarDataDownloader.lastDownloadResult = .serverError
						} else if (error as NSError).code == -1001 { // Bad connection - timeout
							CarDataDownloader.lastDownloadResult = .timeout
						} else {
							CarDataDownloader.lastDownloadResult = .serverError
						}
					} else {
						CarDataDownloader.lastDownloadResult = .serverError
					}

					if let httpResponse = response as? HTTPURLResponse {
						print("CarDataDownloader - httpResponse.statusCode \(httpResponse.statusCode)")
					}
				}

				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					// when background job finished, do something in main thread
					DataDownloader.shared.downloaderIsActive = false

					completionHandler()
				}

			}.resume()

		}, completion:{
		})
	}
}

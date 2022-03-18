//
//  AppLanguageRouter.swift
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

@objc protocol AppLanguageRoutingLogic {
}

protocol AppLanguageDataPassing {
  	var dataStore: AppLanguageDataStore? { get }
}

class AppLanguageRouter: NSObject, AppLanguageRoutingLogic, AppLanguageDataPassing {
  	weak var viewController: AppLanguageViewController?
  	var dataStore: AppLanguageDataStore?
}

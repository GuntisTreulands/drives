//
//  AppLanguagePresenter.swift
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

protocol AppLanguagePresentationLogic {
  	func presentLanguageList(response: AppLanguage.GetLanguage.Response)
}

class AppLanguagePresenter: AppLanguagePresentationLogic {
  	weak var viewController: AppLanguageDisplayLogic?

  	// MARK: AppLanguagePresentationLogic

  	func presentLanguageList(response: AppLanguage.GetLanguage.Response) {
  		let currentlyActiveLanguage = response.activeLanguage

  		let array =  [
			AppLanguage.GetLanguage.ViewModel.DisplayedLanguageCellItem(language: .latvian, currentlyActive: currentlyActiveLanguage == AppSettingsWorker.Language.latvian, languageName: "lv_language_name", languageNameInOriginalLanguage: "Latviski"),
			AppLanguage.GetLanguage.ViewModel.DisplayedLanguageCellItem(language: .english, currentlyActive: currentlyActiveLanguage == AppSettingsWorker.Language.english, languageName: "en_language_name", languageNameInOriginalLanguage: "English"),
			AppLanguage.GetLanguage.ViewModel.DisplayedLanguageCellItem(language: .russian, currentlyActive: currentlyActiveLanguage == AppSettingsWorker.Language.russian, languageName: "ru_language_name", languageNameInOriginalLanguage: "Русский"),
			]
    	let viewModel = AppLanguage.GetLanguage.ViewModel(displayedLanguageCellItems: array)
    	viewController?.presentLanguageList(viewModel: viewModel)
  	}
}

//
//  StringLocalizationExtension.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import Foundation

public extension String {

    func localized() -> String {
    	return AppSettingsWorker.shared.languageBundle.localizedString(forKey: self, value: nil, table: nil)
    }

    func localizedToRU() -> String {
		return AppSettingsWorker.shared.ruLanguageBundle.localizedString(forKey: self, value: nil, table: nil)
    }

    func localizedToEN() -> String {
		return AppSettingsWorker.shared.enLanguageBundle.localizedString(forKey: self, value: nil, table: nil)
    }

    func localizedToLV() -> String {
		return AppSettingsWorker.shared.lvLanguageBundle.localizedString(forKey: self, value: nil, table: nil)
    }
}

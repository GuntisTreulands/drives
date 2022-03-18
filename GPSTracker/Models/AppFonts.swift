//
//  AppFonts.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

struct Font {

	static var increaseFontSize: Int = -100 {
		didSet {
			// For first time setting and only if it changes..
			if oldValue != -100 && oldValue != increaseFontSize {
//				print("change of font size!")
				NotificationCenter.default.post(name: .fontSizeWasChanged, object: nil)
			}
		}
	}

	static func recalculateFontIncreaseSize() {
		// Default should be 28. (From my testing.)
//		print("font size before increase \(Font.increaseFontSize)")
		Font.increaseFontSize = min(10, Int(UIFont.preferredFont(forTextStyle: .title1).pointSize) - 28)
//		print("font size after increase \(Font.increaseFontSize)")
	}

    enum FontType: String {
        case normal = "HelveticaNeue"
        case medium = "HelveticaNeue-Medium"
        case bold   = "HelveticaNeue-Bold"
    }
    enum FontSize: Int {
    	case size0 = 33
        case size1 = 25
        case size2 = 21
        case size3 = 19
        case size4 = 17
        case size5 = 15
        case size6 = 14
        case size7 = 13
    }

    var type: FontType
    var size: FontSize
    init(_ type: FontType, size: FontSize) {
        self.type = type
        self.size = size
    }

    var font: UIFont {
        var instanceFont: UIFont!
		guard let aFont =  UIFont(name: type.rawValue, size: CGFloat(size.rawValue + Font.increaseFontSize)) else {
			fatalError("""
			font is not installed, make sure it is added in Info.plist"
			"and logged with Utility.logAllAvailableFonts()
			""")
		}
		instanceFont = aFont

        return instanceFont
	}
}

//
//  DoubleRoundExtension.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

extension Double {
    func rounded(rule: NSDecimalNumber.RoundingMode, scale: Int) -> Double {
        var result: Decimal = 0
        var decimalSelf = NSNumber(value: self).decimalValue
        NSDecimalRound(&result, &decimalSelf, scale, rule)
        return (result as NSNumber).doubleValue
    }
}

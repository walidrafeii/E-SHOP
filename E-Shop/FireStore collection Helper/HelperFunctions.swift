//
//  HelperFunctions.swift
//  E-Shop
//
//  Created by Walid Rafei on 8/30/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import Foundation

func convertToCurrency(_ number: Double) -> String {
    let currencyFormater = NumberFormatter()
    currencyFormater.usesGroupingSeparator = true
    currencyFormater.numberStyle = .currency
    currencyFormater.locale = Locale.current
    
    return currencyFormater.string(from: NSNumber(value: number))!
}

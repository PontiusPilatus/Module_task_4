//
//  File.swift
//  Carousel
//
//  Created by Бублик Каширин on 01/05/2019.
//

import Foundation


class Currency : NSObject {
    
    let userDefaults: UserDefaults
    
    var name: String
    var sign: String
    var balance: Decimal
    var rates: [String: Double]
    
    init(name: String, sign: String, balance: Decimal, rates: [String: Double], userDefaults: UserDefaults = .standard) {
        self.name = name
        self.sign = sign
        self.balance = balance
        self.rates = rates
        
        self.userDefaults = userDefaults
    }
    
    func updateRates(newRates: [String: Double]) {
        self.rates = newRates
    }
    
    static func == (lft: Currency, rht: Currency) -> Bool {
        if lft.name == rht.name {
            return true
        }
        return false
    }
    
    func balanceToString() -> String {
        return "\(NSString(format:"%.2f",(balance as NSDecimalNumber).doubleValue))"
    }
}

//
//  CurrencyRepository.swift
//  Carousel
//
//  Created by Бублик Каширин on 02/05/2019.
//

import Foundation


class CurrencyRepository : NSObject, ICurrencyRepository {
    // MARK: - Operators overloads
    
    subscript(index:Int) -> Currency? {
        get {
            if index >= _currenciesState.count {
                return nil
            }
            return _currenciesState[index]
        }
    }

    // MARK: - Fields
    
    var userDefaults: UserDefaults
    
    private var _currenciesState = [Currency]()
    
    private var _activeCurrenciesNames = ["EUR", "GBP", "USD"]
    
    var count : Int {
        get {
            return _currenciesState.count
        }
    }
    
    
    // MARK: - Constructors
    
    init (userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Persistence
    
    func saveDump(currencyName: String, balance: Decimal) {
        let sBalance = "\(balance)"
        userDefaults.set(sBalance, forKey: currencyName)
    }
    
    func loadDump(currencyName: String) -> Decimal {
        guard let sBalance = userDefaults.string(forKey: currencyName) else {
            return Decimal(-1)
        }
        
        guard let balance = Decimal(string: sBalance) else {
            return Decimal(-1)
        }
        
        return balance
    }
    
    func restoreData() {
        _currenciesState.removeAll()
        let usdBalance = userDefaults.string(forKey: "USD") ?? "not decimal"
        let gbpBalance = userDefaults.string(forKey: "GBP") ?? "not decimal"
        let eurBalance = userDefaults.string(forKey: "EUR") ?? "not decimal"
        
        _currenciesState.append(Currency(name: "USD", sign: "$",
                                         balance: Decimal(string:usdBalance) ?? NSNumber(floatLiteral: 100.00).decimalValue,
                                         rates: ["USD" : 1, "EUR": 0, "GBP": 0]))
        _currenciesState.append(Currency(name: "GBP", sign: "£",
                                         balance: Decimal(string:gbpBalance) ?? NSNumber(floatLiteral: 100.00).decimalValue,
                                         rates: ["USD" : 0, "EUR": 0, "GBP": 1]))
        _currenciesState.append(Currency(name: "EUR", sign: "€",
                                         balance: Decimal(string:eurBalance) ?? NSNumber(floatLiteral: 100.00).decimalValue,
                                         rates: ["USD" : 0, "EUR": 1, "GBP": 0]))
    }
    
    func restoreToDefault() {
        userDefaults.removeObject(forKey: "USD")
        userDefaults.removeObject(forKey: "GBP")
        userDefaults.removeObject(forKey: "EUR")
    }
    // MARK: - Currency Instances Managment
    
    func getCurrency(currencyName: String) -> Currency? {
        for currency in _currenciesState {
            if currency.name == currencyName {
                return currency
            }
        }
        return nil
    }
    
    func getCurrency(currencyId: Int) -> Currency? {
        if currencyId >= _currenciesState.count {
            return nil
        }
        return _currenciesState[currencyId]
    }
    
    func defaults() {
        _currenciesState.append(Currency(name: "USD", sign: "$",
                                   balance: NSNumber(floatLiteral: 100.00).decimalValue,
                                   rates: ["USD" : 1, "EUR": 0, "GBP": 0]))
        _currenciesState.append(Currency(name: "GBP", sign: "£",
                                   balance: NSNumber(floatLiteral: 100.00).decimalValue,
                                   rates: ["USD" : 0.74, "EUR": 0, "GBP": 0]))
        _currenciesState.append(Currency(name: "EUR", sign: "€",
                                   balance: NSNumber(floatLiteral: 100.00).decimalValue,
                                   rates: ["USD" : 0, "EUR": 1, "GBP": 0]))
    }
    
    func getData() -> [Currency] {
        return _currenciesState
    }
    
    func getIndex(currency: Currency) -> Int {
        for i in 0..<_currenciesState.count {
            if _currenciesState[i] == currency {
                return i
            }
        }
        return -1
    }
    
    // Active ccurrencies managment
    
    func getActiveCurrenciesNames() -> [String] {
        return _activeCurrenciesNames
    }
    
    func addActiveCurrencyName(newName: String) {
        _activeCurrenciesNames.append(newName)
    }
}

//
//  ICurrencyRepository.swift
//  Carousel
//
//  Created by Бублик Каширин on 02/05/2019.
//

import Foundation

protocol ICurrencyRepository {
    
    func saveDump(currencyName: String, balance: Decimal)
    
    func loadDump(currencyName: String) -> Decimal
    
    func restoreData()
        
    func getCurrency(currencyName: String) -> Currency?
    
    func getCurrency(currencyId: Int) -> Currency?
    
    func defaults()
    
    func getData() -> [Currency]
    
    func getIndex(currency: Currency) -> Int
    
    subscript(index:Int) -> Currency? { get }
    
    var count: Int { get };
}

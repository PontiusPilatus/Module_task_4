//
//  BankViewControllerProtocol.swift
//  Carousel
//
//  Created by Бублик Каширин on 09/05/2019.
//

import Foundation

protocol BankViewProtocol : class {
    // 110% костыль
    var topCarousel: iCarousel { get }
    var bottomCarousel: iCarousel { get }
    
    var topCurrencyName: String { get }
    var botCurrencyName: String { get }
    
    var sign:                   String!  { get set }
    var targetSign:             String!  { get set }
    var balance:                Decimal! { get set }
    var rate:                   Double!  { get set }
    var numberOfActiveItems:    Int!     { get set }
    
    // Update
    func updateRatesLabels(firstToSecondRate: Double,
                            secondToFirstRate: Double,
                            firstSign: String,
                            secondSign: String)
    
    func updateUI()
    
    // Show
    
    func showInfoPopup(message: String)
    
    func showTransactionResult(result: String)
    
    // To Default
    func resetSigns()
    
    // Setters
    func set(defaultCurrencyName: String)
    func set(targetSign: String)
    func set(balance: Decimal)
    func set(sign: String)
    func set(name: String)
    func set(rate: Double)
    func set(numberOfActiveItems: Int)
    func set(botSlaveValue: String)
    func set(topSlaveValue: String)
}

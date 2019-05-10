//
//  BankInteractorOutput.swift
//  Carousel
//
//  Created by Бублик Каширин on 09/05/2019.
//

import Foundation

/*
 * Protocol that defines the commands sent from the Interactor to the Presenter.
 */
protocol BankInteractorOutput : class {
    // Top currency
    var topCurrency: Currency! { get set }
    // Bot currency
    var botCurrency: Currency! { get set }
    
    func transactionStatus(result: String)
    func updateLabelsWithRates(currencies: [Currency])
    
    // Give Events
    func set(defaultCurrencyName: String)
    func set(sign: String)
    func set(targetSign: String)
    func set(balance: Decimal)
    func set(rate: Double)
    func set(numberOfActiveItems: Int)
    func set(topCurrency: Currency)
    func set(botCurrency: Currency)
    func set(name: String)
}

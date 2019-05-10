//
//  BankInteractorProtocol.swift
//  Carousel
//
//  Created by Бублик Каширин on 09/05/2019.
//

import Foundation

protocol BankInteractorProtocol {
    func performTransaction(topCurrencyName: String,
                            botCurrencyName: String,
                            topCurrencyAmountString: String,
                            botCurrencyAmountString: String,
                            topSign: String,
                            botSign: String)
    
    func updateRates()
    
    // MARK: Getters
    func getSign(index: Int)
    func getName(index: Int)
    func getTargetSign(name: String)
    func getBalance(index: Int)
    func getRate(from: Int, to: String)
    func getDefaultCurrencyName()
    func getNumberOfActiveItems()
    func getCurrency(topName: String)
    func getCurrency(botName: String)
}

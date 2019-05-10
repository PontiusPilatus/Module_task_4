//
//  BankPresenterProtocol.swift
//  Carousel
//
//  Created by Бублик Каширин on 09/05/2019.
//

import Foundation

/*
 * Protocol that defines the commands sent from the View to the Presenter.
 */
protocol BankModuleInterface : class {
    
    func updateUI()
    
    func setDefaultCurrencies()
    
    func updateRates()
    
    // Requested Actions
//    func performTransaction(topCurrencyName: String,
//                            botCurrencyName: String,
//                            topCurrencyAmountString: String,
//                            botCurrencyAmountString: String,
//                            topSign: String,
//                            botSign: String)
    func transactionButtonClicked()
    
    func performAction(showApproximateAmount: Bool,
                       resetToDefault: Bool,
                       amount: String?,
                       position: String,
                       topCurrencyName: String,
                       botCurrencyName: String)
    
    
    // Need Events
    func needSign(index: Int)
    func needName(index: Int)
    func needTargetSign(name: String)
    func needBalance(index: Int)
    func needRate(from: Int, to: String)
    func needUpdateUI()
    func needNumberOfActiveItems()
}

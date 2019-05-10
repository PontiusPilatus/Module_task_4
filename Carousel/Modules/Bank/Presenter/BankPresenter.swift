//
//  BankPresenter.swift
//  Carousel
//
//  Created by Бублик Каширин on 09/05/2019.
//

import Foundation
import UIKit

/*
 * The Presenter is also responsible for connecting
 * the other objects inside a VIPER module.
 */
class BankPresenter: BankModuleInterface, BankInteractorOutput {

    // Reference to the View (weak to avoid retain cycle).
    weak var view: BankViewProtocol!
    // Reference to the Interactor's interface.
    var bankInteractor: BankInteractorProtocol!
    // Reference to the Router
    var bankWireframe: BankWireframeProtocol!
    
    // Top currency
    var topCurrency: Currency!
    // Bot currency
    var botCurrency: Currency!
    
    required init (view: BankViewProtocol) {
        self.view = view
    }
    
    func updateUI() {
        self.view.updateUI()
    }
    
    // MARK: BankInteractorOutput

    func transactionStatus(result: String) {
        self.view.showTransactionResult(result: result)
    }

    
    func updateLabelsWithRates(currencies: [Currency]) {
        let top = self.view.topCurrencyName
        let bot = self.view.botCurrencyName
        
        var topCurrency: Currency!
        var botCurrency: Currency!
        
        for item in currencies {
            if item.name == top {
                topCurrency = item
            }
            if item.name == bot {
                botCurrency = item
            }
        }
        
        self.view.updateRatesLabels(firstToSecondRate: topCurrency.rates[bot]!,
                                    secondToFirstRate: botCurrency.rates[top]!,
                                    firstSign: topCurrency.sign,
                                    secondSign: botCurrency.sign)
    }
    
    // MARK: BankModuleInterface
    
    func setDefaultCurrencies() {
        self.bankInteractor.getDefaultCurrencyName()
    }
    
    // Actions
    func transactionButtonClicked() {
        guard let topView = view.topCarousel.currentItemView as? CurrencyView else {
            view.showInfoPopup(message: "Error occured. Transaction wasn't performed")
            return
        }
        guard let botView = view.bottomCarousel.currentItemView as? CurrencyView else {
            view.showInfoPopup(message: "Error occured. Transaction wasn't performed")
            return
        }
        
        // Checks if data is present
        guard let topCurrencyName = topView.name.text else {
            view.showInfoPopup(message: "Can't recognize top currency")
            return
        }
        guard let botCurrencyName = botView.name.text else {
            view.showInfoPopup(message: "Can't recognize bot currency")
            return
        }
        
        guard let topCurrencyAmountString = topView.amount.text else {
            view.showInfoPopup(message: "Can't recognize top currency amount")
            return
        }
        
        guard let botCurrencyAmountString = botView.amount.text else {
            view.showInfoPopup(message: "Can't recognize bot currency amount")
            return
        }
        
        guard let topSign = topView.sign.text else {
            view.showInfoPopup(message: "Can't recognize top currency sign")
            return
        }
        
        guard let botSign = botView.sign.text else {
            view.showInfoPopup(message: "Can't recognize bot currency sign")
            return
        }
        
        bankInteractor.performTransaction(topCurrencyName: topCurrencyName,
                                                  botCurrencyName: botCurrencyName,
                                                  topCurrencyAmountString: topCurrencyAmountString,
                                                  botCurrencyAmountString: botCurrencyAmountString,
                                                  topSign: topSign, botSign: botSign)
    }
    
    func performAction(showApproximateAmount: Bool,
                       resetToDefault: Bool,
                       amount: String?,
                       position: String,
                       topCurrencyName: String,
                       botCurrencyName: String) {
        
        if resetToDefault {
            
            view.resetSigns()
            view.updateUI()
            
            return
        }
        if !showApproximateAmount {
            return
        }
        bankInteractor.getCurrency(topName: topCurrencyName)
        bankInteractor.getCurrency(botName: botCurrencyName)
        
        let amount = Double(amount!.replacingOccurrences(of: ",", with: "."))!
        
        // Sets signs to each card
        if position == "top" {
            view.set(botSlaveValue: "\(NSString(format: "%.2f", amount * topCurrency!.rates[botCurrencyName]!))")
        }
        else {
            view.set(topSlaveValue: "\(NSString(format: "%.2f", amount * botCurrency!.rates[topCurrencyName]!))")
        }
    }
    
    func updateRates() {
        self.bankInteractor.updateRates()
    }
    
    // MARK: Need
    func needSign(index: Int) {
        bankInteractor.getSign(index: index)
    }
    
    func needTargetSign(name: String) {
        bankInteractor.getTargetSign(name: name)
    }
    
    func needBalance(index: Int) {
        bankInteractor.getBalance(index: index)
    }
    
    func needRate(from: Int, to: String) {
        bankInteractor.getRate(from: from, to: to)
    }
    
    func needNumberOfActiveItems() {
        bankInteractor.getNumberOfActiveItems()
    }
    
    func needName(index: Int) {
        bankInteractor.getName(index: index)
    }
    
    func needUpdateUI() {
        view.updateUI()
    }

    
    // MARK: Set
    func set(sign: String) {
        view.set(sign: sign)
    }
    
    func set(targetSign: String) {
        view.set(targetSign: targetSign)
    }
    
    func set(balance: Decimal) {
        view.set(balance: balance)
    }
    
    func set(rate: Double) {
        view.set(rate: rate)
    }
    
    func set(numberOfActiveItems: Int) {
        view.set(numberOfActiveItems: numberOfActiveItems)
    }
    
    func set(defaultCurrencyName: String) {
        self.view.set(defaultCurrencyName: defaultCurrencyName)
    }
    
    func set(topCurrency: Currency) {
        self.topCurrency = topCurrency
    }
    
    func set(botCurrency: Currency) {
        self.botCurrency = botCurrency
    }
    
    func set(name: String) {
        view.set(name: name)
    }
    
}



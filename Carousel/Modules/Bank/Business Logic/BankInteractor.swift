//
//  BankInteractor.swift
//  Carousel
//
//  Created by Бублик Каширин on 09/05/2019.
//

import UIKit

/*
 * The Interactor responsible for implementing
 * the business logic of the module.
 */
class BankInteractor : BankInteractorProtocol {


    let urlString = "https://api.exchangeratesapi.io/latest"

    var dispatchGroup = DispatchGroup()
    var repeatedAction: Timer = Timer()
    
    let currencyRepository: CurrencyRepository = CurrencyRepository()
    weak var bankPresenter: BankInteractorOutput!
    
    
    required init (presenter: BankInteractorOutput) {
        self.bankPresenter = presenter
        currencyRepository.restoreData()
        repeatedAction = Timer.scheduledTimer(timeInterval: 30,
                                              target: self,
                                              selector: #selector(self.fetchRates),
                                              userInfo: nil,
                                              repeats: true)
        
    }
    
    // MARK: - Transaction
    
    /// Performs checking and exchanging
    ///
    /// - Parameters:
    ///   - topCurrencyName: currency name
    ///   - botCurrencyName: currency name
    ///   - topCurrencyAmountString: delta amount
    ///   - botCurrencyAmountString: delta amount
    ///   - topSign: operator
    ///   - botSign: operator
    func performTransaction(topCurrencyName: String,
                            botCurrencyName: String,
                            topCurrencyAmountString: String,
                            botCurrencyAmountString: String,
                            topSign: String,
                            botSign: String) {

        // Check if ccurrencies are equal
        if (topCurrencyName == botCurrencyName) {
            self.bankPresenter?.transactionStatus(result: "Can't exchange \(topCurrencyName) to \(botCurrencyName)")
            return
        }
        
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal

        guard let topCurrency = self.currencyRepository.getCurrency(currencyName: topCurrencyName) else {
            self.bankPresenter?.transactionStatus(result: "Can't recognize top currency")
            return
        }
        guard let botCurrency = self.currencyRepository.getCurrency(currencyName: botCurrencyName) else {
            self.bankPresenter?.transactionStatus(result: "Can't recognize bottom currency")
            return
        }
        
        if (topSign == "-") {
            // Replace ',' with '.' for double convertor
            let fmtTopCurrencyAmountString = topCurrencyAmountString.replacingOccurrences(of: ",", with: ".")
            guard let topCurrencyAmount = formatter.number(from: fmtTopCurrencyAmountString)?.decimalValue else {
                self.bankPresenter?.transactionStatus(result: "Can't recognize \(topCurrency.name) amount")
                return
            }

            let result = _exchangeMoney(sourceCurrency: topCurrency,
                                        targetCurrency: botCurrency,
                                        exchangeAmount: topCurrencyAmount)
            if result != "Done" {
                self.bankPresenter?.transactionStatus(result: result)
                return
            }
        }
        
        if (botSign == "-") {
            // Replace ',' with '.' for double convertor
            let fmtBotCurrencyAmountString = botCurrencyAmountString.replacingOccurrences(of: ",", with: ".")
            guard let botCurrencyAmount = formatter.number(from: fmtBotCurrencyAmountString)?.decimalValue else {
                self.bankPresenter?.transactionStatus(result: "Can't recognize \(botCurrency.name) amount")
                return
            }

            let result = _exchangeMoney(sourceCurrency: botCurrency,
                                        targetCurrency: topCurrency,
                                        exchangeAmount: botCurrencyAmount)
            if result != "Done" {
                self.bankPresenter?.transactionStatus(result: result)
                return
            }
        }
        
        // Save values to storage
        currencyRepository.saveDump(currencyName: topCurrencyName, balance: topCurrency.balance)
        currencyRepository.saveDump(currencyName: botCurrencyName, balance: botCurrency.balance)
        
        // Info about account message
        var message = ""
        
        for item in currencyRepository.getData() {
            message += "\(item.name):\t\(NSString(format:"%.2f",(item.balance as NSDecimalNumber).doubleValue))\n"
        }
        
        self.bankPresenter?.transactionStatus(result: message)
    }
    
    // MARK: - Rates
    
    func updateRates() {
        fetchRates()
    }
    /// async fetch rate
    @objc func fetchRates()  {
        
        guard let url = URL(string: urlString) else {
            return
        }
        let request  = URLRequest(url: url)
        // task to background
        DispatchQueue.global(qos: .background).async {
            URLSession.shared.dataTask(with: request) {
                (data, response, err) in
                guard let data = data else { return }
                do {
                    let rates = try JSONDecoder().decode(Rates.self, from: data)
                    // return to main thread
                    DispatchQueue.main.async {
                        self.updateRates(rates: rates)
                        self.bankPresenter.updateLabelsWithRates(currencies: self.currencyRepository.getData())
                    }
                } catch let jsErr {
                    print("Error: ", jsErr)
                    
                }
            }.resume()
        }
    }
    

    // MARK: - Data

    
    func getDefaultCurrencyName() {
        self.bankPresenter.set(defaultCurrencyName: currencyRepository[0]!.name)
    }

    // MARK: - Private functions
    
    /// Performs accurate exchange of given currencies
    ///
    /// - Parameters:
    ///   - sourceCurrency: currency to be subtracted from
    ///   - targetCurrency: currency to be added to
    ///   - exchangeAmount: quantity of money to be exchanged
    /// - Returns: the status of the transaction
    private func _exchangeMoney(sourceCurrency: Currency,
                                targetCurrency: Currency,
                                exchangeAmount: Decimal) -> String {
        if (sourceCurrency.balance >= exchangeAmount) {
            guard let rate = sourceCurrency.rates[targetCurrency.name] else {
                return "Can't get rate for \(sourceCurrency.name) to \(targetCurrency.name)"
            }
            sourceCurrency.balance -= exchangeAmount
            // не теряем и центика
            targetCurrency.balance += exchangeAmount * NSNumber(floatLiteral: rate).decimalValue
            
            return "Done"
        } else {
            return "You need \(exchangeAmount)\(sourceCurrency.sign) but you have " +
            "\(sourceCurrency.balanceToString())\(sourceCurrency.sign)"
        }
    }
    
    /// update rates depending on EUR base
    ///
    /// - Parameter rates: response from server
    private func updateRates(rates: Rates) -> Void {
        var ratesClone = rates
        ratesClone.rates[rates.base] = 1
        
        for currency in currencyRepository.getData() {
            var newRates:[String:Double] = [:]
            for activeCurrency in currencyRepository.getActiveCurrenciesNames() {
                newRates[activeCurrency] = ratesClone.rates[activeCurrency]! / ratesClone.rates[currency.name]!
            }
            currency.updateRates(newRates: newRates)
        }
    }
    
    // MARK: Getters
    func getBalance(index: Int) {
        bankPresenter.set(balance: currencyRepository.getCurrency(currencyId: index)!.balance)
    }
    func getName(index: Int) {
        bankPresenter.set(name: currencyRepository.getCurrency(currencyId: index)!.name)
    }
    func getRate(from: Int, to: String) {
        bankPresenter.set(rate: currencyRepository.getCurrency(currencyId: from)!.rates[to]!)
    }
    func getSign(index: Int) {
        bankPresenter.set(sign: currencyRepository.getCurrency(currencyId: index)!.sign)
    }
    func getTargetSign(name: String) {
        bankPresenter.set(targetSign: currencyRepository.getCurrency(currencyName: name)!.sign)
    }
    
    func getNumberOfActiveItems() {
        bankPresenter.set(numberOfActiveItems: currencyRepository.getActiveCurrenciesNames().count)
    }
    
    func getCurrency(topName: String) {
        bankPresenter.set(topCurrency: currencyRepository.getCurrency(currencyName: topName)!)
    }
    
    func getCurrency(botName: String) {
        bankPresenter.set(botCurrency: currencyRepository.getCurrency(currencyName: botName)!)
    }
}

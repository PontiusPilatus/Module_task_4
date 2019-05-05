//
//  MainTableViewController.swift
//  Carousel
//
//  Created by Бублик Каширин on 01/05/2019.
//
import UIKit
import CoreData

class MainTableViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var top: iCarousel!
    @IBOutlet weak var bottom: iCarousel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Fields
    // Carousels
    var topCurrency: String = ""
    var bottomCurrency: String = ""
    
    let currencyRepository: CurrencyRepository = CurrencyRepository()
    var _rates: Rates? = nil
    
    var dispatchGroup = DispatchGroup()
    var repeatedAction: Timer = Timer()
    
    // MARK: - UI
    
    override func loadView() {
        
        currencyRepository.restoreData()
        updateRatesAndUI()
        topCurrency = currencyRepository[0]!.name
        bottomCurrency = currencyRepository[0]!.name
        
        super.loadView()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set type for carousels
        top.type = .linear
        bottom.type = .linear
        self.hideKeyboardWhenTappedAround()
        
        repeatedAction = Timer.scheduledTimer(timeInterval: 30,
                                              target: self,
                                              selector: #selector(self.updateRatesAndUI),
                                              userInfo: nil,
                                              repeats: true)
        
        // notify when keyboard appears to get rect bounds
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
    }
    
    /// reset signs label
    func resetSigns() {
        (top.currentItemView as! CurrencyView).sign.text = ""
        (bottom.currentItemView as! CurrencyView).sign.text = ""
    }
    
    /// Updates UI
    func updateUI() {
        self.top.reloadData()
        self.bottom.reloadData()
    }
    /// Shows pop-up
    ///
    /// - Parameter message: message to display
    func showSummary(message: String) {
        let alert = UIAlertController(title: "Current balance", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Understandable", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Actions
    
    /// Make a transaction
    ///
    /// - Parameter sender: sender
    @IBAction func transaction(_ sender: Any) {
        
        let topView = top.currentItemView as! CurrencyView
        let botView = bottom.currentItemView as! CurrencyView

        // Checks if data is present
        guard let topCurrencyName = topView.name.text else {
            showSummary(message: "Can't recognize top currency")
            return
        }
        guard let botCurrencyName = botView.name.text else {
            showSummary(message: "Can't recognize bot currency")
            return
        }
        
        guard var topCurrencyAmountString = topView.amount.text else {
            showSummary(message: "Can't recognize top currency amount")
            return
        }
        
        guard var botCurrencyAmountString = botView.amount.text else {
            showSummary(message: "Can't recognize bot currency amount")
            return
        }
        // Replace ',' with '.' for double convertor
        topCurrencyAmountString = topCurrencyAmountString.replacingOccurrences(of: ",", with: ".")
        botCurrencyAmountString = botCurrencyAmountString.replacingOccurrences(of: ",", with: ".")
        
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        
        let topCurrencyAmount = formatter.number(from: topCurrencyAmountString)!.decimalValue
        
        let botCurrencyAmount = formatter.number(from: botCurrencyAmountString)!.decimalValue
        
        var topCurrency = self.currencyRepository[0]!
        var botCurrency = self.currencyRepository[0]!
        // Searching for currencies by their names
        for currency in self.currencyRepository.getData() {
            if (currency.name == topCurrencyName) {
                topCurrency = currency
            }
            if (currency.name == botCurrencyName) {
                botCurrency = currency
            }
        }
        // Make exchange
        if (topCurrency.name == botCurrency.name) {
            showSummary(message: "Can't exchange \(topCurrencyName) to \(botCurrencyName)")
            return
        }
        
        if (topView.sign.text == "-") {
            if (topCurrency.balance >= topCurrencyAmount) {
                guard let rate = topCurrency.rates[botCurrencyName] else {
                    showSummary(message: "Can't get rate for \(topCurrencyName) to \(botCurrencyName)")
                    return
                }
                topCurrency.balance -= topCurrencyAmount
                // не теряем и центика
                botCurrency.balance += topCurrencyAmount * NSNumber(floatLiteral: rate).decimalValue
            } else {
                showSummary(message: "You need \(topCurrencyAmount)\(topCurrency.sign) but you have \(topCurrency.balanceToString())\(topCurrency.sign)")
            }
        }
        
        if (botView.sign.text == "-") {
            if (botCurrency.balance >= botCurrencyAmount) {
                guard let rate = botCurrency.rates[topCurrencyName] else {
                    showSummary(message: "Can't get rate for \(botCurrencyName) to \(topCurrencyName)")
                    return
                }
                botCurrency.balance -= botCurrencyAmount
                // не теряем и центика
                topCurrency.balance += botCurrencyAmount * NSNumber(floatLiteral: rate).decimalValue
            } else {
                showSummary(message: "You need \(botCurrencyAmount)\(botCurrency.sign) but you have \(botCurrency.balanceToString())\(botCurrency.sign)")
            }
        }
        
        // Save values to storage
        currencyRepository.saveDump(currencyName: topCurrencyName, balance: topCurrency.balance)
        currencyRepository.saveDump(currencyName: botCurrencyName, balance: botCurrency.balance)
        
        // Show info about account
        let message = "You now have:\n" +
            "\(self.currencyRepository[0]!.name):\t\(NSString(format:"%.2f",(self.currencyRepository[0]!.balance as NSDecimalNumber).doubleValue))\n" +
            "\(self.currencyRepository[1]!.name):\t\(NSString(format:"%.2f",(self.currencyRepository[1]!.balance as NSDecimalNumber).doubleValue))\n" +
            "\(self.currencyRepository[2]!.name):\t\(NSString(format:"%.2f",(self.currencyRepository[2]!.balance as NSDecimalNumber).doubleValue))"

        showSummary(message: message)
        
        self.resetSigns()
        self.updateUI()
    }
    

    
    // MARK: - Rates stuff
    
    /// asyn fetch rate
    func fetchRates()  {
        let urlString = "https://api.exchangeratesapi.io/latest"
                
        guard let url = URL(string: urlString) else {
            return
        }
        
        let request  = URLRequest(url: url)
        
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: request) {
            (data, response, err) in
            guard let data = data else { return }
            do {
                let rates = try JSONDecoder().decode(Rates.self, from: data)
                self._rates = rates
                self.dispatchGroup.leave()
            } catch let jsErr {
                print("Error: ", jsErr)
                self.dispatchGroup.leave()
            }
        }.resume()
        
    }
    
    /// update rates depending on EUR base
    func updateRates() {
        
        guard var rates = self._rates else { return }
        
        rates.rates[rates.base] = 1
        
        for currency in self.currencyRepository.getData() {
            var newRates:[String:Double] = [:]
            for activeCurrency in currencyRepository.getActiveCurrenciesNames() {
                newRates[activeCurrency] = rates.rates[activeCurrency]! / rates.rates[currency.name]!
            }
            currency.updateRates(newRates: newRates)
        }
    }
    
    /// Update Rates and display them
    @objc func updateRatesAndUI() {
        fetchRates()
        
        dispatchGroup.notify(queue: .main) {
            self.updateRates()
            
            let topView = self.top.currentItemView as! CurrencyView
            let botView = self.bottom.currentItemView as! CurrencyView
            
            let topCurrencyName = topView.name.text!
            let botCurrencyName = botView.name.text!
            
            let topCurrency = self.currencyRepository.getCurrency(currencyName: topCurrencyName)!
            let botCurrency = self.currencyRepository.getCurrency(currencyName: botCurrencyName)!
            
            topView.setRate(rate: topCurrency.rates[botCurrencyName]!,
                            sign: topCurrency.sign, targetSign: botCurrency.sign)
            
            botView.setRate(rate: botCurrency.rates[botCurrencyName]!,
                            sign: botCurrency.sign, targetSign: topCurrency.sign)
            
        }
    }
}

// MARK: - Carousel behaviour

extension MainTableViewController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 3
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        /// Creating view on each card
        let width = UIScreen.main.bounds.width - 20
        let view = Bundle.main.loadNibNamed("CurrencyLayout", owner: self, options: nil)?.first as! CurrencyView
        
        view.bounds = CGRect(x: 0, y: 0, width: width, height: width * 9/16)
        self.view.layer.cornerRadius = 4
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = .init(width: 5, height: 5)
        view.layer.shadowRadius = 1
        
        var targetCurrencyName: String = ""
        var targetCurrencyIndex: Int = 0
        
        // Searching for rate to display
        if (carousel == top) {
            targetCurrencyName = bottomCurrency
            for i in 0 ..< self.currencyRepository.count {
                if self.currencyRepository[i]!.name == targetCurrencyName {
                    targetCurrencyIndex = i
                    break
                }
            }
        } else {
            targetCurrencyName = topCurrency
            for i in 0 ..< self.currencyRepository.count {
                if self.currencyRepository[i]!.name == targetCurrencyName {
                    targetCurrencyIndex = i
                    break
                }
            }
        }
        
        view.setState(name: currencyRepository[index]!.name,
                      sign: currencyRepository[index]!.sign,
                      balance: currencyRepository[index]!.balance,
                      rate: currencyRepository[index]!.rates[targetCurrencyName]!,
                      targetSign: currencyRepository[targetCurrencyIndex]!.sign)
        
        view.amount.delegate = self
        
        return view
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        // Edit space between cards
        if option == .spacing {
            return value * 1.015
        }
        return value
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        var changes = false
        if top == carousel {
            let view = top.currentItemView as! CurrencyView
            if topCurrency != view.name.text! {
                topCurrency = view.name.text!
                changes = true
            }
        }
        if bottom == carousel {
            let view = bottom.currentItemView as! CurrencyView
            if bottomCurrency != view.name.text! {
                bottomCurrency = view.name.text!
                changes = true
            }
        }
        
        if changes {
            self.updateUI()
        }
    }
}

// MARK: - TextField behaviour

extension MainTableViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text! == "" {
            textField.text! = "0.00"
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let sourceString = textField.text else {
            return false
        }
        // Make amount empty
        if string.isEmpty {
            if sourceString.count == 1{
                resetSigns()
                if (top.currentItemView as! CurrencyView).amount == textField {
                    (bottom.currentItemView as! CurrencyView).amount.text = "0.00"
                }
                if (bottom.currentItemView as! CurrencyView).amount == textField {
                    (top.currentItemView as! CurrencyView).amount.text = "0.00"
                }
                return true
            }
            let targetAmount = String(sourceString.dropLast())
            let status = validateAmount(amount: targetAmount)
            if status {
                showAmount(amount: targetAmount, textField: textField)
            }
            return status
        }
        // Denie ,, posibility
        if sourceString.last == "," && string == "," {
            return false
        }
        // Denie 00000 posibility
        if sourceString == "0" && string != "," {
            return false
        }
        // Denie pasting string if source is not empty
        if string.count > 1 && sourceString.count != 0 {
            return false
        }
        // Validate paste string
        if sourceString.count == 0 && string.count > 1 {
            let status = validateAmount(amount: string)
            if status {
                showAmount(amount: string, textField: textField)
            }
            return status
        }
        
        if sourceString.count == 0 && string == "," {
            return false
        }
        
        var validationString: String = ""
        if string == "," {
            validationString = sourceString
        } else {
            validationString = sourceString + string
        }
        let status = validateAmount(amount: validationString)
        if status {
            showAmount(amount: validationString, textField: textField)
        }
        return status
    }
    
    
    /// Checks that string is a vaild number
    ///
    /// - Parameter amount: user input amount
    /// - Returns: if string is valid amount
    func validateAmount(amount: String) -> Bool {
        var separators = false
        
        for char in amount {
            if char == "," {
                if separators {
                    return false
                }
                separators = true
            } else if !char.isNumber {
                return false
            }
        }
        
        if !separators {
            return true
        }
        
        let blownAmount = amount.components(separatedBy: ",")
        if (blownAmount.count == 1) { return true }
        if (blownAmount.count > 1 && blownAmount[1].count <= 2) {
            return true
        }
        return false
    }
    
    /// Displays how much amount will grow
    ///
    /// - Parameters:
    ///   - amount: amount in string
    ///   - textField: source textfield
    func showAmount(amount: String, textField: UITextField) {
        let topview = top.currentItemView as! CurrencyView
        let botview = bottom.currentItemView as! CurrencyView
        
        var topCurrency: Currency? = nil
        var botCurrency: Currency? = nil
        
        let fmtAmount = amount.replacingOccurrences(of: ",", with: ".")
        
        // Searching for currencies
        for currency in currencyRepository.getData() {
            if currency.name == topview.name.text! {
                topCurrency = currency
            }
            if currency.name == botview.name.text! {
                botCurrency = currency
            }
        }
        // Sets signs to each card
        if topview.amount == textField {
            
            let topAmount = Double(fmtAmount)!
            topview.sign.text = "-"
            botview.sign.text = "+"
            botview.amount.text = "\(NSString(format: "%.2f", topAmount * topCurrency!.rates[botCurrency!.name]!))"
        }
        else {
            let botAmount = Double(fmtAmount)!
            botview.sign.text = "-"
            topview.sign.text = "+"
            topview.amount.text = "\(NSString(format: "%.2f", botAmount * botCurrency!.rates[topCurrency!.name]!))"
        }
    }
}

// MARK: - Keyboard behaviour

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension MainTableViewController {
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            // get keyboard height and move up view if the textfield is in bottom carousel
            if (bottom.currentItemView as! CurrencyView).amount.isFirstResponder {
                let keyboardHeight = Double(keyboardRectangle.height)
                self.scrollView.setContentOffset(CGPoint(x: 0, y: keyboardHeight/2), animated: true)
            }
        }
    }
}

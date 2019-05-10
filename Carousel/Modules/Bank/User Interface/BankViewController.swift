//
//  MainTableViewController.swift
//  Carousel
//
//  Created by Бублик Каширин on 01/05/2019.
//
import UIKit
import CoreData

class BankViewController: UIViewController, BankViewProtocol {
  
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var top: iCarousel!
    @IBOutlet weak var bottom: iCarousel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Fields
    
    // Carousels
    var topCarousel: iCarousel {
        get {
            return top
        }
    }
    var bottomCarousel: iCarousel {
        get {
            return bottom
        }
    }
    var topCurrencyName: String = ""
    var botCurrencyName: String = ""
    
    // Presenter
    var bankPresenter: BankModuleInterface!

    
    // Carousel Fields
    var sign: String!
    var targetSign: String!
    var name: String!
    var balance: Decimal!
    var rate: Double!
    var numberOfActiveItems: Int!
    
    
    // MARK: - UI
    
    override func loadView() {
        
        bankPresenter.setDefaultCurrencies()
        bankPresenter.updateRates()
        
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set type for carousels
        top.type = .linear
        bottom.type = .linear
        self.hideKeyboardWhenTappedAround()
        
        // notify when keyboard appears to get rect bounds
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
    }
    
    // Setters
    func set(defaultCurrencyName: String) {
        topCurrencyName = defaultCurrencyName
        botCurrencyName = defaultCurrencyName
    }
    
    func set(sign: String) {
        self.sign = sign
    }
    
    func set(targetSign: String) {
        self.targetSign = targetSign
    }
    
    func set(balance: Decimal) {
        self.balance = balance
    }
    
    func set(name: String) {
        self.name = name
    }
    
    func set(rate: Double) {
        self.rate = rate
    }
    
    func set(botSlaveValue: String) {
        (top.currentItemView as! CurrencyView).sign.text = "-"
        let botview = bottom.currentItemView as! CurrencyView
        botview.sign.text = "+"
        botview.amount.text = botSlaveValue
    }
    
    func set(topSlaveValue: String) {
        (bottom.currentItemView as! CurrencyView).sign.text = "-"
        let topview = top.currentItemView as! CurrencyView
        topview.sign.text = "+"
        topview.amount.text = topSlaveValue
    }
    
    func set(numberOfActiveItems: Int) {
        self.numberOfActiveItems = numberOfActiveItems
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
    func showInfoPopup(message: String) {
        let alert = UIAlertController(title: "Current balance", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Understandable", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Transaction
    
    /// Make a transaction
    ///
    /// - Parameter sender: sender
    @IBAction func transaction(_ sender: Any) {
        bankPresenter.transactionButtonClicked()
    }
    
    func showTransactionResult(result: String) {
        self.showInfoPopup(message: result)
        self.resetSigns()
        self.updateUI()
    }
    
    // MARK: - Rates stuff
    
    func updateRatesLabels(firstToSecondRate: Double,
                           secondToFirstRate: Double,
                           firstSign: String,
                           secondSign: String) {
        
        let topView = self.top.currentItemView as! CurrencyView
        let botView = self.bottom.currentItemView as! CurrencyView
        
        topView.setRate(rate: firstToSecondRate,
                        sign: firstSign, targetSign: secondSign)
        
        botView.setRate(rate: secondToFirstRate,
                        sign: secondSign, targetSign: firstSign)
    }

}

// MARK: - Carousel behaviour

extension BankViewController: iCarouselDataSource, iCarouselDelegate {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        bankPresenter.needNumberOfActiveItems()
        return numberOfActiveItems
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
        
        // Searching for rate to display
        if (carousel == top) {
            targetCurrencyName = botCurrencyName
        } else {
            targetCurrencyName = topCurrencyName
        }
        
        // request parameters
        bankPresenter.needName(index: index)
        bankPresenter.needSign(index: index)
        bankPresenter.needTargetSign(name: targetCurrencyName)
        bankPresenter.needBalance(index: index)
        bankPresenter.needRate(from: index, to: targetCurrencyName)
        
        view.setState(name: name,
                      sign: sign,
                      balance: balance,
                      rate: rate,
                      targetSign: targetSign)
        
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
            if topCurrencyName != view.name.text! {
                topCurrencyName = view.name.text!
                changes = true
            }
        }
        if bottom == carousel {
            let view = bottom.currentItemView as! CurrencyView
            if botCurrencyName != view.name.text! {
                botCurrencyName = view.name.text!
                changes = true
            }
        }
        
        if changes {
            self.bankPresenter.needUpdateUI()
        }
    }
}

// MARK: - TextField behaviour

extension BankViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text! == "" {
            textField.resetToDefault()
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let sourceString = textField.text else {
            return false
        }
        let result = textField.tryInput(sourceString: sourceString,
                                        string: string)
        var position: String!
        
        if (textField == (top.currentItemView as! CurrencyView).amount) {
            position = "top"
        } else {
            position = "bottom"
        }
        
        bankPresenter.performAction(showApproximateAmount: result.needToShowAmount,
                                    resetToDefault: result.resetTodefault,
                                    amount: result.validatedString,
                                    position: position,
                                    topCurrencyName: topCurrencyName,
                                    botCurrencyName: botCurrencyName)
        
        return result.status
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

extension BankViewController {
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

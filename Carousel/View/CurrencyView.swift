//
//  CurrencyView.swift
//  Carousel
//
//  Created by Бублик Каширин on 01/05/2019.
//

import UIKit

class CurrencyView: UIView {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var amount: CustomTextField!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var sign: UILabel!
    
    func setState(name: String, sign: String, balance: Decimal, rate: Double, targetSign: String) {
        
        let fmtBalance = NSString(format:"%.2f",(balance as NSDecimalNumber).doubleValue)
        let fmtRate = NSString(format:"%.2f", rate)
        self.name.text = name
        
        self.balance.text = "You have: \(fmtBalance)\(sign)"
        self.rate.text = "\(sign)1 = \(fmtRate)\(targetSign)"
        
        self.amount.text = "0.00"
        
    }
    
    func setRate(rate: Double, sign: String, targetSign: String) {
        let fmtRate = NSString(format:"%.2f", rate)
        self.rate.text = "\(sign)1 = \(fmtRate)\(targetSign)"
    }
}

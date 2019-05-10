//
//  CurrencyInputField.swift
//  Carousel
//
//  Created by Бублик Каширин on 10/05/2019.
//

import Foundation

extension UITextField: CurrencyInputFieldProtocol {
    
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
    
    func resetToDefault() {
        self.text = "0.00"
    }
    
    func tryInput(sourceString: String, string: String) -> (status:Bool, needToShowAmount: Bool,
        resetTodefault: Bool, validatedString: String?) {
        
            var validationString: String? = nil
        
        // Make amount empty
        if string.isEmpty {
            if sourceString.count == 1 {
                return (true, false, true, nil)
            }
            validationString = String(sourceString.dropLast())
            let status = validateAmount(amount: validationString!)
            if status {
                return (status, true, false, validationString)
            }
            return (status, false, false, nil)
        }
        // Denie ,, posibility
        if sourceString.isEmpty && string == "," {
            return (false, false, false, nil)
        }
        // Denie *,, posibility
        if sourceString.last == "," && string == "," {
            return (false, false, false, nil)
        }
        // Denie 00000 posibility
        if sourceString == "0" && string != "," {
            return (false, false, false, nil)
        }
        // Denie pasting string if source is not empty
        if string.count > 1 && sourceString.count != 0 {
            return (false, false, false, nil)
        }
        // Validate paste string
        if sourceString.count == 0 && string.count > 1 {
            validationString = string
            let status = validateAmount(amount: string)
            if status {
                return (status, true, false, validationString)
            }
            return (status, false, false, nil)
        }
        
        if sourceString.count == 0 && string == "," {
            return (false, false, false, nil)
        }
        
        validationString = ""
        if string == "," {
            validationString = sourceString
        } else {
            validationString = sourceString + string
        }
        let status = validateAmount(amount: validationString!)
        if status {
            return (status, true, false, validationString)
        }
        return (status, false, false, nil)
    }
}

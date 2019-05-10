//
//  CurrencyInputFieldProtocol.swift
//  Carousel
//
//  Created by Бублик Каширин on 10/05/2019.
//

import Foundation

protocol CurrencyInputFieldProtocol {
    func validateAmount(amount: String) -> Bool
    func resetToDefault()
    
    func tryInput(sourceString: String, string: String) -> (status:Bool, needToShowAmount: Bool,
        resetTodefault: Bool, validatedString: String?)
}

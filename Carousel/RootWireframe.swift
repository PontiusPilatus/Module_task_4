//
//  RootWireframe.swift
//  Carousel
//
//  Created by Бублик Каширин on 09/05/2019.
//

import Foundation

class RootWireframe : NSObject {
    
    let _bankWireframe : BankWireframe?
    
    override init() {
        self._bankWireframe = BankWireframe.shared
    }
    
    func application(didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?, window: UIWindow) -> Bool{
        self._bankWireframe?.window = window
        self._bankWireframe?.presentBankScreenView()
        return true
    }
}

//
//  BankWireframe.swift
//  Carousel
//
//  Created by Бублик Каширин on 09/05/2019.
//

import Foundation

class BankWireframe : BankWireframeProtocol {
    
    var bankView: BankViewController!
    var navBankView: UIViewController!
    var window: UIWindow?
    
    static let shared = BankWireframe()
    
    private init() {}
    
    /// creates navbar and bankview
    func presentBankScreenView() {
        let navController = UIStoryboard.init(name: "Bank", bundle: nil)
            .instantiateViewController(withIdentifier: "NavBankViewController")
        if let bankViewController_ = navController.children.first as? BankViewController {
            self.navBankView = navController
            self.bankView = bankViewController_
            
            // Presenter
            let presenter = BankPresenter(view: bankView)
            // Interactor
            let interactor = BankInteractor(presenter: presenter)
            
            // bindings view & presenter
            self.bankView.bankPresenter = presenter
            presenter.bankInteractor = interactor
            
            
            self.window?.rootViewController = navController
            self.window?.makeKeyAndVisible()
        }
    }
}

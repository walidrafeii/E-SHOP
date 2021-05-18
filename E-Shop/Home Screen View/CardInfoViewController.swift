//
//  CardInfoViewController.swift
//  E-Shop
//
//  Created by Walid Rafei on 9/3/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import UIKit
import Stripe

protocol CardInfoViewControllerDelegate {
    
    func didClickDone( _ token: STPToken)
    func didClickCancel()
}

class CardInfoViewController: UIViewController {

    //MARK: IB OUTLETS
    
    @IBOutlet weak var doneButtonOutlet: UIButton!
    
    //MARK: vars
    let paymentCardTextField = STPPaymentCardTextField()
    
    var delegate: CardInfoViewControllerDelegate?
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(paymentCardTextField)
        paymentCardTextField.delegate = self
        
        paymentCardTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: paymentCardTextField, attribute: .top , relatedBy: .equal, toItem: doneButtonOutlet, attribute: .bottom, multiplier: 1, constant: 30))
        
        view.addConstraint(NSLayoutConstraint(item: paymentCardTextField, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -20))
        
        view.addConstraint(NSLayoutConstraint(item: paymentCardTextField, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20))
    }
    
    //MARK: IB ACTIONS
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        delegate?.didClickCancel()
        dismissView()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        processCard()
    }
    
    //MARK: Helper Functions
    
    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func processCard() {
        
        let cardParams = STPCardParams()
        cardParams.number = paymentCardTextField.cardNumber
        cardParams.expMonth = UInt(paymentCardTextField.expirationMonth)
        cardParams.expYear = UInt(paymentCardTextField.expirationYear)
        cardParams.cvc = paymentCardTextField.cvc
        
        STPAPIClient.shared.createToken(withCard: cardParams) { (token, error) in
            if error == nil {
                print("the token is", token!)
                self.delegate?.didClickDone(token!)
                self.dismissView()
            } else {
                print("error processing card token", error!.localizedDescription)
            }
        }
    }

}

extension CardInfoViewController: STPPaymentCardTextFieldDelegate {
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        doneButtonOutlet.isEnabled = textField.isValid
        
    }
}

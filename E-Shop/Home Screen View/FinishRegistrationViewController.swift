//
//  FinishRegistrationViewController.swift
//  E-Shop
//
//  Created by Walid Rafei on 9/2/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import UIKit
import JGProgressHUD

class FinishRegistrationViewController: UIViewController {

    
    //MARK: IB OUTLETS
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var DoneButtonOutlet: UIButton!
    
    //MARK: vars
    let hud = JGProgressHUD(style: .dark)
    
    //MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        surNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        addressTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    //MARK: IB ACTIONS
    @IBAction func doneButtonPressed(_ sender: Any) {
        finishOnboarding()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("text field did change")
        updateDoneButtonStatus()
    }
    
    //MARK: Helper
    private func updateDoneButtonStatus() {
        if nameTextField.text != "" && surNameTextField.text != "" && addressTextField.text != "" {
            DoneButtonOutlet.backgroundColor = .red
            DoneButtonOutlet.isEnabled = true
        }
        else {
            DoneButtonOutlet.backgroundColor = .lightGray
            DoneButtonOutlet.isEnabled = false
        }
    }
    
    private func finishOnboarding() {
        let withValues = [kFIRSTNAME: nameTextField.text!, kLASTNAME: surNameTextField.text!, kONBOARD: true, kFULLADDRESS: addressTextField.text!, kFULLNAME: (nameTextField.text! + " " + surNameTextField.text!)] as [String: Any]
        
        updateCurrentUserInFireStore(withValues: withValues) { (error) in
            if error == nil {
                self.hud.textLabel.text = "Updated"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
                
                self.dismiss(animated: true, completion: nil)
            } else {
                print("error updating user in firestore \(error!.localizedDescription)")
                
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }

}

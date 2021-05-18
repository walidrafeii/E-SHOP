//
//  EditProfileViewController.swift
//  E-Shop
//
//  Created by Walid Rafei on 9/2/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import UIKit
import JGProgressHUD

//MARK: IB OUTLETS


class EditProfileViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    //MARK: vars
    let hud = JGProgressHUD(style: .dark)
    
    //MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserInfo()
    }

    //MARK: IB ACTIONS
    @IBAction func saveBarButtonPressed(_ sender: Any) {
        dismissKeyBoard()
        
        if textFieldsHaveText() {
            
            let withValues = [kFIRSTNAME: nameTextField.text!, kLASTNAME: surNameTextField.text!, kFULLNAME: (nameTextField.text! + " " + surNameTextField.text!), kFULLADDRESS: addressTextField.text!]
            
            updateCurrentUserInFireStore(withValues: withValues) { (error) in
                if error == nil {
                    self.hud.textLabel.text = "Updated"
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                } else {
                    print("error updating user info", error!.localizedDescription)
                    self.hud.textLabel.text = error!.localizedDescription
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                }
            }
        } else {
            hud.textLabel.text = "All fields are required!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        logOutUser()
    }
    
    //MARK: update UI
    private func loadUserInfo() {
        if Muser.currentUser() != nil {
            let currentUser = Muser.currentUser()!
            
            nameTextField.text = currentUser.firstName
            surNameTextField.text = currentUser.lastName
            addressTextField.text = currentUser.fullAddress
        }
    }
    
    //MARK: Helper Functions
    private func dismissKeyBoard() {
        self.view.endEditing(false)
    }
    
    private func textFieldsHaveText() -> Bool {
        return (nameTextField.text != "" && surNameTextField.text != "" && addressTextField.text != "")
    }
    
    private func logOutUser() {
        Muser.logOutCurrentUser { (error) in
            if error == nil {
                print("logged out")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("error logging out", error!.localizedDescription)
            }
        }
    }
    
}

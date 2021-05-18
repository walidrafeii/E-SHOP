//
//  WelcomeViewController.swift
//  E-Shop
//
//  Created by Walid Rafei on 9/2/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView

class WelcomeViewController: UIViewController {
    
    //MARK: IB OUTLETS
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextFIeld: UITextField!
    @IBOutlet weak var resendButton: UIButton!
    
    //MARK: variables
    
    let hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    
    //MARK: VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 30, y: self.view.frame.height/2 - 30,width: 60, height: 60), type: .ballPulse, color: #colorLiteral(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1.0) , padding: nil)
    }
    
    //MARK: IBACTIONS
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismissView()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if(textFieldsHaveText()) {
            //register the user
            loginUser()
        } else {
            hud.textLabel.text = "All fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        if(textFieldsHaveText()) {
            //register the user
            registerUser()
        } else {
            hud.textLabel.text = "All fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func fogotPasswordButtonPressed(_ sender: Any) {
        if emailTextField.text != "" {
            resetThePassword()
        } else {
            hud.textLabel.text = "Please insert email!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        Muser.resendVerificationEmail(email: emailTextField.text!) { (error) in
            print("error resending email", error?.localizedDescription)
        }
    }
    
    //MARK: Login User
    
    private func loginUser() {
        
        showLoadingIndicator()
        
        Muser.loginUserWith(email: emailTextField.text!, password: passwordTextFIeld.text!) { (error, isEmailVerified) in
            if error == nil {
                if isEmailVerified {
                    self.dismissView()
                    print("Email is Verified")
                } else {
                    self.hud.textLabel.text = "please verify your email"
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                    self.resendButton.isHidden = false
                }
            } else {
                print("error logging in the user", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
                
            }
            
            self.hideLoadingIndicator()
        }
    }
    //MARK: Register User
    private func registerUser() {
        showLoadingIndicator()
        Muser.RegisterUserWith(email: emailTextField.text!, password: passwordTextFIeld.text!) { (error) in
            if error == nil {
                self.hud.textLabel.text = "verification Email Sent!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            } else {
                print("error registering", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            
            self.hideLoadingIndicator()
        }
    }
    
    //MARK: Helpers
    
    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func textFieldsHaveText() -> Bool {
        return (emailTextField.text != "" && passwordTextFIeld.text != "")
    }
    
    //MARK: Activity Indicator
    private func showLoadingIndicator() {
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator?.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
    
    private func resetThePassword() {
        Muser.resetPasswordFor(email: emailTextField.text!) { (error) in
            if error == nil {
                self.hud.textLabel.text = "Reset password email sent!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            } else {
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
}

//
//  ProfileTableViewController.swift
//  E-Shop
//
//  Created by Walid Rafei on 9/2/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    //MARK: variables
    var editBarButtonOutlet: UIBarButtonItem!
    
    //MARK: IBOUTLETS

    @IBOutlet weak var finishRegistrationButtonOutlet: UIButton!
    @IBOutlet weak var purchaseHistoryButtonOutlet: UIButton!
    
    //MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLoginStatus()
        checkOnBoardingStatus()
        //check logged in status
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // we only have 3 cells purchase hitory, finish reg, and terms and corditions
        return 3
    }
    
    //MARK: Table view Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:  true)
    }
    
    //MARK: Helpers
    
    private func checkOnBoardingStatus() {
        if Muser.currentUser() != nil {
            
            if Muser.currentUser()!.onBoard {
                finishRegistrationButtonOutlet.setTitle("Account is Active", for: .normal)
                finishRegistrationButtonOutlet.isEnabled = false
            } else {
                finishRegistrationButtonOutlet.setTitle("Finish registration", for: .normal)
                finishRegistrationButtonOutlet.isEnabled = true
                finishRegistrationButtonOutlet.tintColor = .red

            }
            purchaseHistoryButtonOutlet.isEnabled = true
        } else {
            finishRegistrationButtonOutlet.setTitle("Logged out", for: .normal)
            finishRegistrationButtonOutlet.isEnabled = false
            purchaseHistoryButtonOutlet.isEnabled = false
        }
    }
    
    private func checkLoginStatus() {
        if Muser.currentUser() == nil {
            createRightBarButton(title: "Login")
        } else {
            createRightBarButton(title: "Edit")
        }
    }
    
    private func createRightBarButton(title: String) {
        editBarButtonOutlet = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(rightBarButtonItemPressed))
        
        self.navigationItem.rightBarButtonItem = editBarButtonOutlet
    }
    
    //MARK: IB Actions
    
    @objc func rightBarButtonItemPressed() {
        if editBarButtonOutlet.title == "Login" {
            //show login view
            showLoginView()
        } else {
            // go to profile
            goToEditProfile()
        }
    }
    
    private func showLoginView() {
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        self.present(loginView, animated: true, completion: nil)
    }
    
    private func goToEditProfile() {
        performSegue(withIdentifier: "profileToEditSeg", sender: self)
    }

}

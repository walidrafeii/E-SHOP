//
//  SearchViewController.swift
//  E-Shop
//
//  Created by Walid Rafei on 9/2/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import EmptyDataSet_Swift

class SearchViewController: UIViewController {

    //MARK: IB OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var seachOptionView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButtonOutlet: UIButton!
    
    //MARK: vars
    var searchResults: [Item] = []
    var activityIndicator: NVActivityIndicatorView?
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()

        searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60),
                                                    type: .ballPulse, color: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), padding: nil)
        
    }
    
    //MARK: IB ACTIONS
    @IBAction func showSearchBarButtonPressed(_ sender: Any) {
        
        dismissKeyBoard()
        showSearchField()
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        
        if searchTextField.text != "" {
            //search
            searchInFirebase(forName: searchTextField.text!)
            
            
            emptyTextField()
            animateSearchOptionsIn()
            dismissKeyBoard()
        }
    }
    
    //Mark: search Database
    private func searchInFirebase(forName: String) {
        
        showLoadingIndicator()
        searchAlgolia(searchString: forName) { (itemIds) in
            downloadItems(itemIds) { (allItems) in
                
                self.searchResults = allItems
                self.tableView.reloadData()
                
                self.hideLoadingIndicator()
            }
        }
    }
    
    //MARK: Helper Functions
    
    // empty text field when click on search
    private func emptyTextField() {
        searchTextField.text = ""
    }
    
    private func dismissKeyBoard() {
        self.view.endEditing(false)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        searchButtonOutlet.isEnabled = textField.text != ""
        
        if searchButtonOutlet.isEnabled {
            searchButtonOutlet.backgroundColor = .red
        } else {
            disableSearchButton()
        }
    }
    
    private func disableSearchButton() {
        searchButtonOutlet.isEnabled = false
        searchButtonOutlet.backgroundColor = .lightGray
    }
    
    private func showSearchField() {
        disableSearchButton()
        emptyTextField()
        animateSearchOptionsIn()
    }
    
    //MARK: Animations
    private func animateSearchOptionsIn() {
        UIView.animate(withDuration: 0.5) {
            self.seachOptionView.isHidden = !self.seachOptionView.isHidden
        }
    }
    
    //MARK: Activity indicator
    private func showLoadingIndicator() {
        
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
    
    private func showItemView(withItem: Item) {
        
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        itemVC.item = withItem
        
        self.navigationController?.pushViewController(itemVC, animated: true)
    }

}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        cell.generateCellItems(searchResults[indexPath.row])
        return cell
    }
    
    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem: searchResults[indexPath.row])
    }
    
    
}

extension SearchViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No items to Display!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData" )
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Please check back later")
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        return UIImage(named: "searchUser")
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        return NSAttributedString(string: "Start searching...")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        showSearchField()
    }
}

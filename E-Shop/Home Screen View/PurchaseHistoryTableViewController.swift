//
//  PurchaseHistoryTableViewController.swift
//  E-Shop
//
//  Created by Walid Rafei on 9/2/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class PurchaseHistoryTableViewController: UITableViewController {

    //MARK: Vars
    var itemArray: [Item] = []
    
    //MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //to remove lines in table view
        tableView.tableFooterView = UIView()
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadItems()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell

        cell.generateCellItems(itemArray[indexPath.row])
        return cell
    }
    
    //MARK: Load Items
    
    private func loadItems() {
        downloadItems(Muser.currentUser()!.purchasedItemIds) { (allItems) in
            self.itemArray = allItems
            print("we have \(allItems.count) purchased items")
            self.tableView.reloadData()
        }
    }

}

extension PurchaseHistoryTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No items to Display!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData" )
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Please check back later")
    }
}

//
//  BasketViewController.swift
//  E-Shop
//
//  Created by Walid Rafei on 9/2/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import UIKit
import JGProgressHUD
import Stripe

class BasketViewController: UIViewController {

    //MARK: IBOUTLETS
    
    @IBOutlet weak var footerVIew: UIView!
    @IBOutlet weak var basketTotalPriceLabel: UILabel!
    @IBOutlet weak var checkOutButtonoutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalItemsLabel: UILabel!
    
    //MARK: vars
    var basket: Basket?
    var allItems: [Item] = []
    var purchasedItemIds : [String] = []
    var totalPrice = 0
    
    let hud = JGProgressHUD(style: .dark)
    
    
    //MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = footerVIew
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Muser.currentUser() != nil {
            loadBasketFromFireStore()
        } else {
            self.updateTotalLabels(true)
        }
    }

    //MARK: IB Actions
    @IBAction func checkoutButtonPressed(_ sender: Any) {
        
        if Muser.currentUser()!.onBoard {
            
            //show action sheeet
            showPaymentOptions()
        } else {
            self.showNotification(text: "Please complete your profile", isError: true)
        }
    }
    
    //MARK: Download Basket
    private func loadBasketFromFireStore() {
        downloadBasketFromFireStore(Muser.currentId()) { (basket) in
            self.basket = basket
            self.getBasketItems()
        }
    }
    
    private func getBasketItems() {
        if basket != nil {
            downloadItems(basket!.itemIds) { (allItems) in
                self.allItems = allItems
                self.updateTotalLabels(false)
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: Helper Functions
    
    private func updateTotalLabels(_ isEmpty: Bool) {
        if isEmpty {
            totalItemsLabel.text = "0"
            basketTotalPriceLabel.text = returnBasketTotalPrice()
        }
        else {
            totalItemsLabel.text = "\(allItems.count)"
            basketTotalPriceLabel.text = returnBasketTotalPrice()
        }
        
        checkoutButtonStatusUpdate()
        
    }
    
    private func returnBasketTotalPrice() ->String {
        var totalPrice = 0.0
        for item in allItems {
            totalPrice += item.price
        }
        
        return "Total price: " + convertToCurrency(totalPrice)
    }
    
    private func emptyTheBasket() {
        purchasedItemIds.removeAll()
        allItems.removeAll()
        tableView.reloadData() // refresh page to show empty page
        
        basket!.itemIds = [] // empty the basket
        
        updateBasketInFireStore(basket!, withValues: [kITEMIDS: basket!.itemIds]) { (error) in
            if error != nil {
                print("Error updating basket", error!.localizedDescription)
            }
            self.getBasketItems()
        }
    }
    
    private func addItemsToPurchaseHistory(_ itemIds: [String]) {
        if Muser.currentUser() != nil {
            let newItemIds = Muser.currentUser()!.purchasedItemIds + itemIds
            updateCurrentUserInFireStore(withValues: [kPURCHASEDITEMS: newItemIds]) { (error) in
                if error != nil {
                    print ("error adding purchased items", error!.localizedDescription)
                }
            }
        }
    }
    
    //MARK: Navigation
    
    private func showItemView(withItem: Item) {
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        itemVC.item = withItem
        self.navigationController?.pushViewController(itemVC, animated: true)
        
    }
    
    //MARK: Control CheckoutButton
    private func checkoutButtonStatusUpdate() {
        checkOutButtonoutlet.isEnabled = allItems.count > 0
        
        if checkOutButtonoutlet.isEnabled {
            checkOutButtonoutlet.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        } else {
            disableCheckoutButton()
        }
    }
    
    private func disableCheckoutButton() {
        checkOutButtonoutlet.isEnabled = false
        checkOutButtonoutlet.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
    
    private func removeItemFromBasket(itemId: String) {
        
        for i in 0..<basket!.itemIds.count {
            if itemId == basket!.itemIds[i] {
                basket!.itemIds.remove(at: i)
                
                return
            }
        }
    }
    
    private func finishPayment(token: STPToken) {
        
        //var itemsToBuy : [PayPalItem] = []
        
        self.totalPrice = 0
        
        for item in allItems {
            /* FOR PAYPAL*/
            //let tempItem = PayPalItem(name: item.name, withQuantity: 1, withPrice: NSDecimalNumber(value: item.price), withCurrency: "USD", withSku: nil)
            
            purchasedItemIds.append(item.id)
            self.totalPrice += Int(item.price)
            
            
            /* FOR PAYPAL*/
            //itemsToBuy.append(tempItem)
        }
        
        self.totalPrice = self.totalPrice * 100
        StripeClient.sharedClient.createAndConfirmPayment(token, amount: totalPrice) { (error) in
            if error == nil {
                self.emptyTheBasket()
                self.addItemsToPurchaseHistory(self.purchasedItemIds)
                // show notification
                self.showNotification(text: "payment Successful", isError: false)
                
            } else {
                self.showNotification(text: error!.localizedDescription, isError: true)
                print("error", error!.localizedDescription)
            }
        }
        
        
    }
    
    private func showNotification(text:String, isError: Bool) {
        
        if isError {
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
        } else {
            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        }
        
        self.hud.textLabel.text = text
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 2.0)
    }
    
    private func showPaymentOptions() {
        let alertController = UIAlertController(title: "Payment Options", message: "Choose preferred payment option", preferredStyle: .actionSheet)
        let cardAction = UIAlertAction(title: "Pay with Card", style: .default) { (action) in
            //show card number view
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "cardInfoVC") as! CardInfoViewController
            
            vc.delegate = self
            self.present(vc, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // add apple pay button
        
        alertController.addAction(cardAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension BasketViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        cell.generateCellItems(allItems[indexPath.row])
        return cell
    }
    
    //MARK: UITableView Delegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = allItems[indexPath.row]
            allItems.remove(at: indexPath.row)
            tableView.reloadData()
            
            removeItemFromBasket(itemId: itemToDelete.id)
            updateBasketInFireStore(basket!, withValues: [kITEMIDS: basket!.itemIds]) { (error) in
                if error != nil {
                    print("error updating the basket", error!.localizedDescription)
                }
                self.getBasketItems()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem: allItems[indexPath.row])
    }
    
}

extension BasketViewController: CardInfoViewControllerDelegate {
    func didClickDone(_ token: STPToken) {
        
        finishPayment(token: token)
    }
    
    func didClickCancel() {
        showNotification(text: "PaymentCancelled", isError: true)
    }
    
    
}

//
//  AddItemViewController.swift
//  E-Shop
//
//  Created by Walid Rafei on 8/29/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import UIKit
import Gallery
import JGProgressHUD
import NVActivityIndicatorView

class AddItemViewController: UIViewController {

    //MARK: IB outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descrptionTextView: UITextView!
    
    //Mark: vars
    var category: Category!
    var itemImages: [UIImage?] = []
    var gallery: GalleryController!
    let hud = JGProgressHUD(style: .dark)
    
    var activityIndicator: NVActivityIndicatorView?
    
    //Mark: view Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(category.id)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60),
                                                    type: .ballPulse, color: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), padding: nil)
    }
    
    //MARK: IB Actions
    @IBAction func doneBarItemClicked(_ sender: Any) {
        dismissKeyBoard()
        if checkValidFields() {
            saveToFireBase()
        } else {
            print("Error all fields are required")
            self.hud.textLabel.text = "All fields are required!"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        itemImages = []
        showImageGallery()
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismissKeyBoard()
    }
    
    //MARK: Helper Functions
    
    // Dismiss Keyboard on Tap Gesture
    private func dismissKeyBoard() {
        self.view.endEditing(false)
    }
    
    private func checkValidFields() -> Bool {
        return ((titleTextField.text != "") && (priceTextField.text != "") && (descrptionTextView.text != ""))
    }
    
    private func popTheView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Save Item
    private func saveToFireBase() {
        
        showLoadingIndicator()
        
        let item = Item()
        item.id = UUID().uuidString
        item.name = titleTextField.text!
        item.price = Double(priceTextField.text!)
        item.categoryId = category.id
        item.description = descrptionTextView.text
        
        if (itemImages.count > 0 ) {
            uploadImages(images: itemImages, itemID: item.id) { (imageLinkArray) in
                item.imageLinks = imageLinkArray
                saveItemToFireStore(item)
                saveItemToAlgolia(item: item)
                
                self.hideLoadingIndicator()
                self.popTheView()
            }
        } else {
            saveItemToFireStore(item)
            saveItemToAlgolia(item: item)
            popTheView()
        }
    }
    
    //MARK: Activity Indicator
    
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
    
    //Mark: show Gallery
    private func showImageGallery() {
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 10
        
        self.present(self.gallery, animated: true, completion: nil)
    }
}

extension AddItemViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            Image.resolve(images: images) { (resolvedImages) in
                self.itemImages = resolvedImages
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

//
//  Categories.swift
//  E-Shop
//
//  Created by Walid Rafei on 8/29/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import Foundation
import UIKit

class Category {
    // Each Category will have the following variables
    var id: String
    var name: String
    var image: UIImage? //  ? optional
    var imageName: String? // ? optional
    
    init(CurrentName: String, CurrentImageName: String){
        id = ""
        name = CurrentName
        imageName = CurrentImageName
        image = UIImage(named: CurrentImageName)
    }
    
    init (dictionary: NSDictionary) {
        id = dictionary[kOBJECTID] as! String
        name = dictionary[kNAME] as! String
        image = UIImage(named: dictionary[kIMAGENAME] as? String ?? "")
    }
}

//MARK: retrieve all Categories from firebase after populated this step is done after we call createCategorySet() once

func downloadCategoriesFromFirebase(completion: @escaping (_ categoryArray: [Category]) -> Void) {
    var categoryArray: [Category] = []
    FirebaseReference(.Category).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completion(categoryArray)
            return
        }
        
        if !snapshot.isEmpty {
            for categoryDict in snapshot.documents {
                print("created new category")
                categoryArray.append(Category(dictionary: categoryDict.data() as NSDictionary))
            }
        }
        completion(categoryArray)
    }
}

//MARK: save category function

func saveCategoryToFirebase(_ category: Category) {
    let id = UUID().uuidString
    category.id = id
    
    FirebaseReference(.Category).document(id).setData(categoryDictionaryFrom(category) as! [String : Any])
}

//MARK: Helpers

func categoryDictionaryFrom(_ category: Category) -> NSDictionary {
    return NSDictionary(objects: [category.id, category.name, category.imageName],
                        forKeys: [kOBJECTID as NSCopying, kNAME as NSCopying, kIMAGENAME as NSCopying ])
}

//MARK : this is to be used only once

////create each category name
//func createCategorySet() {
//    let womenClothing = Category(CurrentName: "Women's Clothing & Accessories", CurrentImageName: "womenCloth")
//    let footWear = Category(CurrentName: "FootWear", CurrentImageName: "footWear")
//    let electronics = Category(CurrentName: "Electronics", CurrentImageName: "Electronics")
//    let menClothing = Category(CurrentName: "Men's Clothing & Accessories", CurrentImageName: "menCloth")
//    let health = Category(CurrentName: "Health & Beauty", CurrentImageName: "health")
//    let baby = Category(CurrentName: "Babies", CurrentImageName: "baby")
//    let home = Category(CurrentName: "Home & Kitchen", CurrentImageName: "home")
//    let car = Category(CurrentName: "Automobiles & MotorCycles", CurrentImageName: "car")
//    let luggage = Category(CurrentName: "Travel", CurrentImageName: "travel")
//    let sports = Category(CurrentName: "Sports ", CurrentImageName: "sports")
//    let jewelery = Category(CurrentName: "Jewelery", CurrentImageName: "jewelery")
//    let pet = Category(CurrentName: "Pet Products", CurrentImageName: "pets")
//    let industry = Category(CurrentName: "Industry & Business", CurrentImageName: "industry")
//    let garden = Category(CurrentName: "Garden Supplies", CurrentImageName: "garden")
//    let camera = Category(CurrentName: "Cameras & Optics", CurrentImageName: "camera")
//
//    let arrayOfCategories = [womenClothing, footWear, electronics, menClothing, health, baby, home, car, luggage, sports, jewelery, pet, industry, garden, camera]
//
//    for category in arrayOfCategories {
//        saveCategoryToFirebase(category)
//    }
//}

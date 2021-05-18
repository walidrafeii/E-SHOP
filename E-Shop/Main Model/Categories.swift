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
        id = dictionary["objectId"] as! String
        name = dictionary["name"] as! String
        image = UIImage(named: dictionary["imageName"] as? String ?? "")
    }
}

//MARK: save category function

func saveCategoryToFirebase(_ Category: Category) {
    
}

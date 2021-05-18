//
//  Item.swift
//  E-Shop
//
//  Created by Walid Rafei on 8/29/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchClient

class Item {
    var id: String!
    var categoryId: String!
    var name: String!
    var description: String!
    var price: Double!
    var imageLinks: [String]!
    
    init() {
        
    }
    
    init(_dictionary: NSDictionary) {
        id = _dictionary[kOBJECTID] as? String
        categoryId = _dictionary[kCATEGORYID] as? String
        name = _dictionary[kNAME] as? String
        description = _dictionary[kDESCRIPTION] as? String
        price = _dictionary[kPRICE] as? Double
        imageLinks = _dictionary[kIMAGELINKS] as? [String]
    }
    
}

//MARK: save items func

func saveItemToFireStore(_ item: Item) {
    FirebaseReference(.Items).document(item.id).setData(itemDictionaryFrom(item) as! [String: Any])
}

//MARK: Helper Functions

func itemDictionaryFrom(_ item: Item) -> NSDictionary {
    return NSDictionary(objects: [item.id, item.categoryId, item.name, item.description, item.price, item.imageLinks],
                        forKeys: [kOBJECTID as NSCopying, kCATEGORYID as NSCopying, kNAME as NSCopying, kDESCRIPTION as NSCopying, kPRICE as NSCopying, kIMAGELINKS as NSCopying])
}

//MARK: Download Function
func downloadItemsFromFireBase(_ withCategoryId: String, completion: @escaping (_ itemArray: [Item]) -> Void) {
    var itemArray : [Item] = []
    FirebaseReference(.Items).whereField(kCATEGORYID, isEqualTo: withCategoryId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completion(itemArray)
            return
        }
        
        if !snapshot.isEmpty {
            for itemDictionary in snapshot.documents {
                itemArray.append(Item(_dictionary: itemDictionary.data() as NSDictionary))
                
            }
        }
        completion(itemArray)
    }
}

func downloadItems(_ withIds: [String], completion: @escaping (_ itemArray: [Item]) -> Void) {
    var count = 0
    var itemArray: [Item] = []
    
    if withIds.count > 0 {
        for itemId in withIds {
            FirebaseReference(.Items).document(itemId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else {
                    completion(itemArray)
                    return
                }
                
                if snapshot.exists {
                    itemArray.append(Item(_dictionary: snapshot.data()! as NSDictionary))
                    count += 1
                } else {
                    completion(itemArray)
                }
                
                if count == withIds.count {
                    completion(itemArray)
                }
            }
        }
    } else {
        completion(itemArray)
    }
}

//MARK: Algolia funcs
func saveItemToAlgolia(item: Item) {
    
    let index = AlgoliaService.shared.index
    
    let itemToSave = itemDictionaryFrom(item) as! [String : Any]
    
    index.addObject(itemToSave, withID: item.id, requestOptions: nil) { (content, error) in
        
        if error != nil {
            print("error saving to algolia", error!.localizedDescription)
        } else {
            print("added to algolia")
        }
    }
}

func searchAlgolia(searchString: String, completion: @escaping(_ itemArray: [String]) -> Void) {
    
    let index = AlgoliaService.shared.index
    var resultIds: [String] = []
    
    let query = Query(query: searchString)
    
    query.attributesToRetrieve = ["name", "description"]
    
    index.search(query) { (content, error) in
        if error == nil  {
            let cont = content!["hits"] as! [[String : Any]]
            
            resultIds = []
            
            for result in cont {
                resultIds.append(result["objectID"] as! String)
            }
            
            completion(resultIds)
        } else {
            print("error algolia search", error!.localizedDescription)
            completion(resultIds)
        }
    }
}

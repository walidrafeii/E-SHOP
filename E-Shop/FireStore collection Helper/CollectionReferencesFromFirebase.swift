//
//  CollectionReferencesFromFirebase.swift
//  E-Shop
//
//  Created by Walid Rafei on 8/29/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import Foundation
import FirebaseFirestore

// access FireStore where each category has a folder to be accessed
enum FireStoreCollectionReference: String {
    case User
    case Category
    case Items
    case Basket
}

func FirebaseReference(_ collectionReference: FireStoreCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}

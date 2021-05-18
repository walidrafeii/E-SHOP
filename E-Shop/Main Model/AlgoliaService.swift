//
//  AlgoliaService.swift
//  E-Shop
//
//  Created by Walid Rafei on 9/3/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import Foundation
import InstantSearchClient

class AlgoliaService {
    
    static let shared = AlgoliaService()
    
    let client = Client(appID: KALGOLIA_APP_ID, apiKey: KALGOLIA_ADMIN_KEY)
    let index = Client(appID: KALGOLIA_APP_ID, apiKey: KALGOLIA_ADMIN_KEY).index(withName: "E-shop")
    
    private init() {}
    
}

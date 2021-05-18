//
//  ImageCollectionViewCell.swift
//  E-Shop
//
//  Created by Walid Rafei on 9/2/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func setupImageWith(itemImage: UIImage) {
        imageView.image = itemImage
    }
    
}

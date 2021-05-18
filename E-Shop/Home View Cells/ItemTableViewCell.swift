//
//  ItemTableViewCell.swift
//  E-Shop
//
//  Created by Walid Rafei on 8/30/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func generateCellItems(_ item: Item) {
        nameLabel.text = item.name
        descriptionLabel.text = item.description
        priceLabel.text = convertToCurrency(item.price)
        priceLabel.adjustsFontSizeToFitWidth = true
        if item.imageLinks != nil && item.imageLinks.count > 0 {
            downloadImages(imageUrls: [item.imageLinks.first!]) { (images) in
                self.itemImageView.image = images.first as? UIImage
            }
        }
        
    }
}

//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Вадим Игнатенко on 13.10.22.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lacationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
    
}

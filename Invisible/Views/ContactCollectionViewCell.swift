//
//  ContactCollectionViewCell.swift
//  Invisible
//
//  Created by thomas on 5/24/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class ContactCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    imageView.hidden = true
    nameLabel.hidden = true
  }
}

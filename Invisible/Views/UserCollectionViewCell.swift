//
//  UserCollectionViewCell.swift
//  Invisible
//
//  Created by thomas on 5/22/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    userImageView.hidden = true
    userNameLabel.hidden = true
  }
  
}

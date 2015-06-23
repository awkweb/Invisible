//
//  ContactCollectionViewCellContentView.swift
//  Invisible
//
//  Created by thomas on 6/2/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class ContactCollectionViewCellContentView: UIView {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var displayNameLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let colorList = [UIColor.green(), UIColor.blue(), UIColor.red()]
    backgroundColor = colorList[0]
  }
  
}

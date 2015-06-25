//
//  ProfileTableViewCell.swift
//  Invisible
//
//  Created by thomas on 6/25/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    titleLabel.textColor = UIColor.grayD()
    detailLabel.textColor = UIColor.gray()
  }
  
}

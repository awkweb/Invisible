//
//  ContactCollectionViewCell.swift
//  Invisible
//
//  Created by thomas on 6/2/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class ContactCollectionViewCell: UICollectionViewCell {
  
  var contactCollectionViewCellContentView: ContactCollectionViewCellContentView!
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  private func initialize() {
    let nibViews = NSBundle.mainBundle().loadNibNamed("ContactCollectionViewCellContentView", owner: self, options: nil)
    contactCollectionViewCellContentView = nibViews[0] as! ContactCollectionViewCellContentView
    contactCollectionViewCellContentView.frame.size = frame.size
    addSubview(contactCollectionViewCellContentView)
  }
  
  override var selected : Bool {
    didSet {
      contactCollectionViewCellContentView.displayNameLabel.backgroundColor = selected ? UIColor.red() : UIColor.clearColor()
    }
  }
  
}

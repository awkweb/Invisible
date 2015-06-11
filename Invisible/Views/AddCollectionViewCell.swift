//
//  AddCollectionViewCell.swift
//  Invisible
//
//  Created by thomas on 6/3/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class AddCollectionViewCell: UICollectionViewCell {
  
  var addCollectionViewCellContentView: AddCollectionViewCellContentView!
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  private func initialize() {
    let nibViews = NSBundle.mainBundle().loadNibNamed("AddCollectionViewCellContentView", owner: self, options: nil)
    addCollectionViewCellContentView = nibViews[0] as! AddCollectionViewCellContentView
    addCollectionViewCellContentView.frame.size = frame.size
    addSubview(addCollectionViewCellContentView)
  }
    
}

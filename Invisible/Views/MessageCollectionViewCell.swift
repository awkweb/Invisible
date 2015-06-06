//
//  MessageCollectionViewCell.swift
//  Invisible
//
//  Created by thomas on 6/5/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell {
 
  var messageCollectionViewCellContentView: MessageCollectionViewCellContentView!
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  func initialize() {
    let nibViews = NSBundle.mainBundle().loadNibNamed("MessageCollectionViewCellContentView", owner: self, options: nil)
    messageCollectionViewCellContentView = nibViews[0] as! MessageCollectionViewCellContentView
    messageCollectionViewCellContentView.frame.size = frame.size
    addSubview(messageCollectionViewCellContentView)
  }
  
}

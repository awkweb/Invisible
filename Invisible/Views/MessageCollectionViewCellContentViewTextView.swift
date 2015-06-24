//
//  MessageCollectionViewCellContentViewTextView.swift
//  Invisible
//
//  Created by thomas on 6/11/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class MessageCollectionViewCellContentViewTextView: UITextView {

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureTextView()
  }
  
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    configureTextView()
  }
  
  private func configureTextView() {    
    let cornerRadius: CGFloat = 18.0
    layer.cornerRadius = cornerRadius
        
    backgroundColor = UIColor.grayL()
    
    scrollIndicatorInsets = UIEdgeInsetsZero
    textContainerInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    contentInset = UIEdgeInsetsZero
    
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false
    scrollEnabled = false
    scrollsToTop = false
    userInteractionEnabled = true
    editable = false
    selectable = true
    
    font = UIFont.systemFontOfSize(16.0)
    textColor = UIColor.grayD()
    textAlignment = .Natural
    
    contentMode = .Redraw
    dataDetectorTypes = .None
  }

}

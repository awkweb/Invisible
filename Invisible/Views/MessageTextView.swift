//
//  MessageTextView.swift
//  Invisible
//
//  Created by thomas on 5/30/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class MessageTextView: UITextView {
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureTextField()
  }
  
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    configureTextField()
  }
  
  private func configureTextField() {
    setTranslatesAutoresizingMaskIntoConstraints(false)
    
    let cornerRadius: CGFloat = 6.0
    
    backgroundColor = UIColor.whiteColor()
    layer.borderWidth = 0.5
    layer.borderColor = UIColor.lightGrayColor().CGColor
    layer.cornerRadius = cornerRadius
    
    scrollIndicatorInsets = UIEdgeInsets(top: cornerRadius, left: 0.0, bottom: cornerRadius, right: 0.0)
    textContainerInset = UIEdgeInsets(top: 4.0, left: 2.0, bottom: 4.0, right: 2.0)
    contentInset = UIEdgeInsets(top: 1.0, left: 0.0, bottom: 1.0, right: 0.0)
    
    scrollEnabled = true
    scrollsToTop = false
    userInteractionEnabled = true
    
    font = UIFont.systemFontOfSize(16.0)
    textColor = UIColor.blackColor()
    textAlignment = .Natural
    
    contentMode = .Redraw
    dataDetectorTypes = .None
    keyboardAppearance = .Default
    keyboardType = .Default
    returnKeyType = .Default
    
    text = nil
    
    //    _placeHolder = nil;
    //    _placeHolderTextColor = [UIColor lightGrayColor];
    //
  }
  
}

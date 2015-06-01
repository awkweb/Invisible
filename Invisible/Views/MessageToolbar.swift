//
//  MessageToolbar.swift
//  Invisible
//
//  Created by thomas on 5/30/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

@objc protocol MessageToolbarDelegate {
  func sendButtonPressed(sender: UIButton)
}

class MessageToolbar: UIToolbar {
  
  var messageToolbarContentView: MessageToolbarContentView!
  var messageToolbarDelegate: MessageToolbarDelegate!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  func initialize() {
    let nibViews = NSBundle.mainBundle().loadNibNamed("MessageToolbarContentView", owner: self, options: nil)
    messageToolbarContentView = nibViews[0] as! MessageToolbarContentView
    messageToolbarContentView.frame.size.width = self.frame.size.width
    messageToolbarContentView.sendButton.addTarget(messageToolbarDelegate, action: "sendButtonPressed:", forControlEvents: .TouchUpInside)
    addSubview(messageToolbarContentView)
  }

}

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
  
  var messageContentView: MessageToolbarContentView!
  var messageToolbarDelegate: MessageToolbarDelegate!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  private func initialize() {
    let nibViews = NSBundle.mainBundle().loadNibNamed("MessageToolbarContentView", owner: self, options: nil)
    messageContentView = nibViews[0] as! MessageToolbarContentView
    messageContentView.frame.size.width = frame.size.width
    messageContentView.sendButton.addTarget(messageToolbarDelegate, action: "sendButtonPressed:", forControlEvents: .TouchUpInside)
    addSubview(messageContentView)
  }

}

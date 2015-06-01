//
//  MessageToolbar.swift
//  Invisible
//
//  Created by thomas on 5/30/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

@objc protocol MessageToolbarDelegate {
  func sendBarButtonItemPressed(sender: UIBarButtonItem)
}

class MessageToolbar: UIToolbar {
  
  var messageTextView: MessageTextView!
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
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    
    messageTextView = MessageTextView(frame: CGRect(x: 0, y: 0, width: screenWidth * 0.75, height: 30))
    let messageTextViewBarButtonItem = UIBarButtonItem(customView: messageTextView)
    let sendBarButtonItem = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: messageToolbarDelegate, action: "sendBarButtonItemPressed:")
    
    items = [messageTextViewBarButtonItem, sendBarButtonItem]
  }

}

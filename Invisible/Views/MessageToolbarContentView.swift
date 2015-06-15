//
//  MessageToolbarContentView.swift
//  Invisible
//
//  Created by thomas on 6/1/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class MessageToolbarContentView: UIView {
  
  @IBOutlet weak var messageTextView: MessageTextView!
  @IBOutlet weak var placeholderLabel: UILabel!
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var characterCounterLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    placeholderLabel.textColor = UIColor.gray()
    placeholderLabel.text = "Type a message..."
    characterCounterLabel.textColor = UIColor.gray()
    sendButton.setTitleColor(UIColor.blue(), forState: .Normal)
    sendButton.setTitleColor(UIColor.gray(), forState: .Disabled)
  }

}

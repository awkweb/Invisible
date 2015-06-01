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
  @IBOutlet weak var sendButton: UIButton!
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }

}

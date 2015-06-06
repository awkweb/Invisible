//
//  MessageCollectionViewCellContentView.swift
//  Invisible
//
//  Created by thomas on 6/5/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class MessageCollectionViewCellContentView: UIView {

  @IBOutlet weak var dateTimeLabel: UILabel!
  @IBOutlet weak var messageTextView: UITextView!
  
  override func awakeFromNib() {
    messageTextView.editable = false
  }
  
}

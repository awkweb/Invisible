//
//  MessageCollectionViewCellContentView.swift
//  Invisible
//
//  Created by thomas on 6/11/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class MessageCollectionViewCellContentView: UIView {
  
  @IBOutlet weak var dateTimeLabel: UILabel!
  @IBOutlet weak var senderDisplayNameLabel: UILabel!
  @IBOutlet weak var senderImageView: UIImageView!
  @IBOutlet weak var messageTextView: MessageCollectionViewCellContentViewTextView!
  @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var noMessageHistoryLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    dateTimeLabel.textColor = UIColor.gray()
    senderDisplayNameLabel.textColor = UIColor.gray()
    senderImageView.layer.masksToBounds = true
    senderImageView.layer.cornerRadius = senderImageView.frame.size.width / 2
    messageTextViewWidthConstraint.constant = UIScreen.mainScreen().bounds.size.width - messageTextView.frame.origin.x - 8
    noMessageHistoryLabel.textColor = UIColor.gray()
  }
  
}

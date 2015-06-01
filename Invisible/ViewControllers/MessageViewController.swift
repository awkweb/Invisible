//
//  MessageViewController.swift
//  Invisible
//
//  Created by thomas on 5/10/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
  @IBOutlet weak var messageToolbar: MessageToolbar!
  @IBOutlet weak var messageToolbarBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var messageToolbarHeightConstraint: NSLayoutConstraint!
  var oldContentSize: CGFloat!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    addNotificationCenterObservers()
    messageToolbar.messageToolbarContentView.messageTextView.becomeFirstResponder()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    oldContentSize = 28.0
  }
  
  func addNotificationCenterObservers() {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue = NSOperationQueue.mainQueue()
    
    notificationCenter.addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: mainQueue) {
      notification in
      if let keyboardHeight = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
        self.messageToolbarBottomConstraint.constant = keyboardHeight
        UIView.animateWithDuration(0.25) {
          self.view.layoutIfNeeded()
        }
      }
    }
    
    notificationCenter.addObserverForName(UITextViewTextDidChangeNotification, object: messageToolbar.messageToolbarContentView.messageTextView, queue: mainQueue) {
      notification in
      if let contentSize = notification.object?.contentSize {
        let newContentSize = contentSize.height
        let dy = newContentSize - self.oldContentSize
        self.oldContentSize = newContentSize
        self.adjustMessageToolbarForMessageTextViewContentSizeChange(dy)
        if count(self.messageToolbar.messageToolbarContentView.messageTextView.text) > 110 {
          self.messageToolbar.messageToolbarContentView.sendButton.enabled = false
        } else {
          self.messageToolbar.messageToolbarContentView.sendButton.enabled = true
        }
      }
    }
    
  }
  
  func adjustMessageToolbarForMessageTextViewContentSizeChange(dy: CGFloat) {
    let contentSizeIsIncreasing = (dy > 0)
    let toolbarOriginY = CGRectGetMinY(messageToolbar.frame)
    let newToolbarOriginY = toolbarOriginY - dy
    adjustMessageToolbarHeightConstraintByDelta(dy)
    
    if dy < 0 {
      scrollMessageTextViewToBottomAnimated(false)
    }
    scrollMessageTextViewToBottomAnimated(true)
  }
  
  func adjustMessageToolbarHeightConstraintByDelta(dy: CGFloat) {
    let proposedHeight = messageToolbarHeightConstraint.constant + dy
    let finalHeight = max(proposedHeight, 44.0)
    if messageToolbarHeightConstraint.constant != finalHeight {
      messageToolbarHeightConstraint.constant = finalHeight
      view.setNeedsUpdateConstraints()
      view.layoutIfNeeded()
    }
  }
  
  func scrollMessageTextViewToBottomAnimated(animated: Bool) {
    let textView = messageToolbar.messageToolbarContentView.messageTextView
    let contentOffsetToShowLastLine = CGPoint(x: 0.0, y: textView.contentSize.height - CGRectGetHeight(textView.bounds))
    if !animated {
      textView.contentOffset = contentOffsetToShowLastLine
      return
    }
    UIView.animateWithDuration(0.01) {
      textView.contentOffset = contentOffsetToShowLastLine
    }
  }
  
}

extension MessageViewController: MessageToolbarDelegate {
  
  func sendButtonPressed(sender: UIButton) {
    println("Hello :)")
  }
  
}

extension MessageViewController: UITextViewDelegate {
  
}

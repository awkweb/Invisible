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
  let topContentAdditionalInset: CGFloat = 0.0
  
  var pushCharacterLimit = 110
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    addNotificationCenterObservers()
    messageToolbar.messageContentView.messageTextView.becomeFirstResponder()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    oldContentSize = 28.0
    messageToolbar.messageContentView.messageTextView.delegate = self
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
    
    notificationCenter.addObserverForName(UITextViewTextDidChangeNotification, object: messageToolbar.messageContentView.messageTextView, queue: mainQueue) {
      notification in
      if let contentSize = notification.object?.contentSize {
        let newContentSize = contentSize.height
        let dy = newContentSize - self.oldContentSize
        self.oldContentSize = newContentSize
        self.adjustMessageToolbarForMessageTextViewContentSizeChange(dy)
        self.messageToolbar.messageContentView.sendButton.enabled = count(self.messageToolbar.messageContentView.messageTextView.text) < self.pushCharacterLimit
      }
    }
    
  }
  
  func adjustMessageToolbarForMessageTextViewContentSizeChange(dy: CGFloat) {
    let contentSizeIsIncreasing = (dy > 0)
    
    if messageToolbarHasReachedMaximumHeight() {
      let contentOffsetIsPositive = (messageToolbar.messageContentView.messageTextView.contentOffset.y > 0)
      if contentSizeIsIncreasing || contentOffsetIsPositive {
        scrollMessageTextViewToBottomAnimated(true)
        return
      }
    }
    
    let toolbarOriginY = CGRectGetMinY(messageToolbar.frame)
    let newToolbarOriginY = toolbarOriginY - dy
    
    if newToolbarOriginY <= topLayoutGuide.length + topContentAdditionalInset {
      var dy = toolbarOriginY - (topLayoutGuide.length + topContentAdditionalInset)
      scrollMessageTextViewToBottomAnimated(true)
    }
    
    adjustMessageToolbarHeightConstraintByDelta(dy)
    if dy < 0 {
      scrollMessageTextViewToBottomAnimated(false)
    } else if dy > 0 {
      scrollMessageTextViewToBottomAnimated(true)
    }
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
    let textView = messageToolbar.messageContentView.messageTextView
    let contentOffsetToShowLastLine = CGPoint(x: 0.0, y: textView.contentSize.height - CGRectGetHeight(textView.bounds))
    
    if !animated {
      textView.setContentOffset(contentOffsetToShowLastLine, animated: animated)
      return
    }
    UIView.animateWithDuration(0.01, delay: 0.01, options: .CurveLinear, animations: {
      println("uiview animation")
      textView.setContentOffset(contentOffsetToShowLastLine, animated: animated)
      }, completion: {
        bool in
        return bool
    })
  }
  
  func messageToolbarHasReachedMaximumHeight() -> Bool { // Differs - should be ==, not <=
    return CGRectGetMinY(messageToolbar.frame) <= (topLayoutGuide.length + topContentAdditionalInset)
  }
  
}

extension MessageViewController: MessageToolbarDelegate {
  
  func sendButtonPressed(sender: UIButton) {
    if count(self.messageToolbar.messageContentView.messageTextView.text) <= pushCharacterLimit {
      println("Hello :)")
    }
  }
  
}

extension MessageViewController: UITextViewDelegate {
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if textView == messageToolbar.messageContentView.messageTextView {
      if text == "\n" {
        sendButtonPressed(messageToolbar.messageContentView.sendButton)
        return false
      }
    }
    return true
  }
  
  func textViewDidChange(textView: UITextView) {
    messageToolbar.messageContentView.placeholderLabel.hidden = count(textView.text) != 0
  }
}

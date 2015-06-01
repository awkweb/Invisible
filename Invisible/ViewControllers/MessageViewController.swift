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
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    messageToolbar.messageTextView.becomeFirstResponder()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    messageToolbarBottomConstraint.constant = 0.0
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "test:", name: UITextViewTextDidChangeNotification, object: nil)
    NSNotificationCenter.defaultCenter().postNotificationName("UITextViewTextDidChangeNotification", object: nil)
  }
  
  func keyboardWillShow(sender: NSNotification) {
    if let userInfo = sender.userInfo {
      if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
        messageToolbarBottomConstraint.constant = keyboardHeight
        UIView.animateWithDuration(0.25) {
          self.view.layoutIfNeeded()
        }
      }
    }
  }
  
  func test(sender: NSNotification) {
    println("It worked.")
    println(sender.object?.contentSize.height)
  }
  
}

extension MessageViewController: MessageToolbarDelegate {
  
  func sendBarButtonItemPressed(sender: UIBarButtonItem) {
    println("Hello :)")
  }
  
}

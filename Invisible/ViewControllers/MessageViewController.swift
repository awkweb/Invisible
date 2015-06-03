//
//  MessageViewController.swift
//  Invisible
//
//  Created by thomas on 5/10/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
  @IBOutlet weak var contactCollectionView: ContactCollectionView!
  @IBOutlet weak var messageToolbar: MessageToolbar!
  @IBOutlet weak var messageToolbarBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var messageToolbarHeightConstraint: NSLayoutConstraint!
  
  var oldContentSize: CGFloat!
  let baseContentSize: CGFloat = 28.0
  let topContentAdditionalInset: CGFloat = 0.0
  
  var pushCharacterLimit = 110
  
  var contacts: [Contact] = []
  
  // MARK: View life cycle
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    addNotificationCenterObservers()
    messageToolbar.messageContentView.messageTextView.becomeFirstResponder()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    oldContentSize = baseContentSize
    messageToolbar.messageContentView.messageTextView.delegate = self
    contactCollectionView.dataSource = self
    contactCollectionView.delegate = self
    fetchContacts({
      fetchedContacts in
      self.contacts = fetchedContacts
      self.contactCollectionView.reloadData()
    })
  }
  
  // MARK: Notification center
  
  private func addNotificationCenterObservers() {
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
        println("posted \(contentSize)")
        let newContentSize = contentSize.height
        let dy = newContentSize - self.oldContentSize
        self.oldContentSize = newContentSize
        self.adjustMessageToolbarForMessageTextViewContentSizeChange(dy)
        UIView.animateWithDuration(0.5) {
          self.messageToolbar.messageContentView.sendButton.enabled = count(self.messageToolbar.messageContentView.messageTextView.text) <= self.pushCharacterLimit
          self.messageToolbar.messageContentView.characterCounterLabel.hidden = newContentSize <= self.baseContentSize
        }
      }
    }
    
  }
  
  // MARK: Message toolbar
  
  private func adjustMessageToolbarForMessageTextViewContentSizeChange(dy: CGFloat) {
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
  
  private func adjustMessageToolbarHeightConstraintByDelta(dy: CGFloat) {
    let proposedHeight = messageToolbarHeightConstraint.constant + dy
    let finalHeight = max(proposedHeight, 44.0)
    if messageToolbarHeightConstraint.constant != finalHeight {
      UIView.animateWithDuration(0.25) {
        self.messageToolbarHeightConstraint.constant = finalHeight
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
      }
    }
  }
  
  private func scrollMessageTextViewToBottomAnimated(animated: Bool) {
    let textView = messageToolbar.messageContentView.messageTextView
    let contentOffsetToShowLastLine = CGPoint(x: 0.0, y: textView.contentSize.height - CGRectGetHeight(textView.bounds))
    
    if !animated {
      textView.setContentOffset(contentOffsetToShowLastLine, animated: false)
      return
    }
    UIView.animateWithDuration(0.01, delay: 0.01, options: .CurveLinear, animations: {
      textView.setContentOffset(contentOffsetToShowLastLine, animated: false)
      }, completion: {
        bool in
        return bool
    })
  }
  
  func messageToolbarHasReachedMaximumHeight() -> Bool { // Differs - should be ==, not <=
    return CGRectGetMinY(messageToolbar.frame) <= (topLayoutGuide.length + topContentAdditionalInset)
  }
  
}

// MARK: Contact collection view data source

extension MessageViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 12
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let contactCell = collectionView.dequeueReusableCellWithReuseIdentifier("ContactCollectionViewCell", forIndexPath: indexPath) as! ContactCollectionViewCell
    
    if indexPath.row < contacts.count {
      let contact = contacts[indexPath.row]
      contact.getUser({
        user in
        
        contactCell.contactCollectionViewCellContentView.displayNameLabel.text = user.displayName
        
        user.getPhoto({
          image in
          contactCell.contactCollectionViewCellContentView.imageView.image = image
        })
      })
    } else if indexPath.row == contacts.count {
      contactCell.contactCollectionViewCellContentView.displayNameLabel.text = "Add"
    }
    return contactCell
  }
}

// MARK: Contact collection view data source

extension MessageViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == contacts.count {
      presentAddContactAlertController()
    }
  }
  
}

// MARK: Contact collection view delegate flow layout

extension MessageViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let collectionViewHeight = collectionView.frame.height
    let collectionViewWidth = collectionView.frame.width
    let cellHeight = collectionViewWidth / 4
    return CGSize(width: cellHeight, height: cellHeight)
  }
  
}

// MARK: Message toolbar delegate

extension MessageViewController: MessageToolbarDelegate {
  
  func sendButtonPressed(sender: UIButton) {
    if count(messageToolbar.messageContentView.messageTextView.text) <= pushCharacterLimit {
      messageToolbar.messageContentView.messageTextView.text = ""
      NSNotificationCenter.defaultCenter().postNotificationName("UITextViewTextDidChangeNotification", object: nil)
      messageToolbar.messageContentView.placeholderLabel.hidden = false // Put in completion handler
      println("Hello :)")
    }
  }
  
}

// MARK: Message text view delegate

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
    if textView == messageToolbar.messageContentView.messageTextView {
      messageToolbar.messageContentView.placeholderLabel.hidden = count(textView.text) != 0
      let characterCount = pushCharacterLimit - count(textView.text)
      messageToolbar.messageContentView.characterCounterLabel.text = "\(characterCount)"
    }
  }
}

// MARK: Utilities

extension MessageViewController {
  
  private func presentAddContactAlertController() {
    let alert = UIAlertController(title: "Add contact", message: "Please type an username.", preferredStyle: .Alert)
    
    alert.addTextFieldWithConfigurationHandler {
      textField in
      textField.placeholder = "username"
      textField.secureTextEntry = false
    }
    
    let textField = alert.textFields![0] as! UITextField
    
    let addAction = UIAlertAction(title: "Add", style: .Default) {
      action in
      
      let contact: () = fetchUserByUsername(textField.text, {
        user in
        
        let currentContacts = self.contacts.map {$0.userId}
        if !contains(currentContacts, user.id) {
          saveUserAsContact(user, {
            success in
            
            if success {
              fetchContacts({
                fetchedContacts in
                
                self.contacts = fetchedContacts
                self.contactCollectionView.reloadData() // reload only the new cell
              })
            }
          })
        }
      })
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
      action in
      println("Just performed the cancel action")
    }
    
    alert.addAction(addAction)
    alert.addAction(cancelAction)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
}

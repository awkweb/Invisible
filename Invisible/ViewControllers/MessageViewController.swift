//
//  MessageViewController.swift
//  Invisible
//
//  Created by thomas on 5/10/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit
import Parse

class MessageViewController: UIViewController {
  
  @IBOutlet weak var contactCollectionView: ContactCollectionView!
  @IBOutlet weak var messageToolbar: MessageToolbar!
  @IBOutlet weak var messageToolbarBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var messageToolbarHeightConstraint: NSLayoutConstraint!
  
  var oldContentSize: CGFloat!
  let baseContentSize: CGFloat = 28.0
  let topContentAdditionalInset: CGFloat = 0.0
  
  var pushCharacterLimit = 140
  
  var contacts: [Contact] = []
  var selectedContactUserIds: [String] = []
  
  // MARK: View life cycle
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    addNotificationCenterObservers()
    messageToolbar.messageContentView.messageTextView.becomeFirstResponder()
    let longPress = UILongPressGestureRecognizer(target: self, action: "performLongPressGestureRecognizer:")
    contactCollectionView.addGestureRecognizer(longPress)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    oldContentSize = baseContentSize
    messageToolbar.messageContentView.messageTextView.delegate = self
    contactCollectionView.dataSource = self
    contactCollectionView.delegate = self
    fetchContacts {
      self.contacts = $0
      self.contactCollectionView.reloadSections(NSIndexSet(index: 0))
    }
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
    
    notificationCenter.addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: mainQueue) {
      notification in
      self.messageToolbarBottomConstraint.constant = 0.0
      UIView.animateWithDuration(0.25) {
        self.view.layoutIfNeeded()
      }
    }
    
    notificationCenter.addObserverForName(UITextViewTextDidChangeNotification, object: messageToolbar.messageContentView.messageTextView, queue: mainQueue) {
      notification in
      if let contentSize = notification.object?.contentSize {
        let newContentSize = contentSize.height
        let dy = newContentSize - self.oldContentSize
        self.oldContentSize = newContentSize
        self.adjustMessageToolbarForMessageTextViewContentSizeChange(dy)
        self.adjustContactCollectionViewForMessageTextViewContentSizeChange(dy)
        self.updatePlaceholderLabelCharacterCounterLabelAndSendButton()
      }
    }
    
  }
  
  // MARK: Gesture recognizer
  
  func performLongPressGestureRecognizer(sender: UILongPressGestureRecognizer) {
    let longPress = sender
    let gestureState = sender.state
    let location = longPress.locationInView(contactCollectionView)
    let indexPath = contactCollectionView.indexPathForItemAtPoint(location)
    
    if gestureState == .Began && indexPath!.row != 0 && indexPath!.row <= contacts.count {
      presentDeleteContactAlertControllerForIndexPath(indexPath!)
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
      }, completion: {return $0})
  }
  
  private func messageToolbarHasReachedMaximumHeight() -> Bool { // TODO: Leave some room up top; differs - should be ==, not <=
    return CGRectGetMinY(messageToolbar.frame) <= (topLayoutGuide.length + topContentAdditionalInset)
  }
  
  private func updatePlaceholderLabelCharacterCounterLabelAndSendButton() {
    let contentView = messageToolbar.messageContentView
    contentView.placeholderLabel.hidden = count(contentView.messageTextView.text) != 0
    let characterCount = pushCharacterLimit - count(contentView.messageTextView.text)
    contentView.characterCounterLabel.text = "\(characterCount)"
    UIView.animateWithDuration(0.5) {
      contentView.sendButton.enabled = count(contentView.messageTextView.text) <= self.pushCharacterLimit && count(contentView.messageTextView.text) != 0 && !self.selectedContactUserIds.isEmpty
      contentView.characterCounterLabel.hidden = self.oldContentSize <= self.baseContentSize
    }
  }
  
  // MARK: Contact collection view
  
  func adjustContactCollectionViewForMessageTextViewContentSizeChange(dy: CGFloat) {
    let contentSizeIsIncreasing = (dy > 0)
    let collectionViewFrameHeight = contactCollectionView.frame.size.height
    if dy != 0 {
      println("\ncontentSize changed by \(dy)")
      println("collectionViewHeight now \(collectionViewFrameHeight)")
      println("collectionView frame \(contactCollectionView.frame)")
      println("messageToolbar min y \(messageToolbar.frame.minY)")
      println("messageToolbar y \(messageToolbar.frame.origin.y)")
    }
  }
  
}

// MARK: Message toolbar delegate

extension MessageViewController: MessageToolbarDelegate {
  
  func sendButtonPressed(sender: UIButton) {
    let textView = messageToolbar.messageContentView.messageTextView
    if count(textView.text) <= pushCharacterLimit && count(textView.text) != 0 && !selectedContactUserIds.isEmpty {
      PFCloud.callFunctionInBackground("sendPush",
        withParameters: [
          "from": "\(currentUser().displayName)",
          "to": selectedContactUserIds,
          "date_time": Helpers.dateToPrettyString(NSDate()),
          "message": textView.text,
          "senderId": "\(currentUser().id)"]) {
          success, error in
          if success != nil {
            textView.text = ""
            self.adjustMessageToolbarForMessageTextViewContentSizeChange(self.baseContentSize - self.oldContentSize)
            // TODO: self.adjustContactCollectionViewForMessageTextViewContentSizeChange(self.baseContentSize - self.oldContentSize)
            self.oldContentSize = self.baseContentSize
            self.updatePlaceholderLabelCharacterCounterLabelAndSendButton()
            // TODO: Deselect contacts
            println(success!)
          } else {
            println(error!)
          }
      }
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
  
}

// MARK: Contact collection view data source

extension MessageViewController: UICollectionViewDataSource {
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 2
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0: return 12
    default: return 1
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    switch indexPath.section {
    case 0:
      var addCell = collectionView.dequeueReusableCellWithReuseIdentifier("AddCollectionViewCell", forIndexPath: indexPath) as! AddCollectionViewCell
      var contactCell = collectionView.dequeueReusableCellWithReuseIdentifier("ContactCollectionViewCell", forIndexPath: indexPath) as! ContactCollectionViewCell
      let contactContentView = contactCell.contactCollectionViewCellContentView
      
      if indexPath.row == 0 {
        return addCell
      } else {
        if indexPath.row <= contacts.count {
          let contact = contacts[indexPath.row - 1]
          contact.getUser {
            contactContentView.displayNameLabel.text = $0.displayName
            $0.getPhoto {contactContentView.imageView.image = $0}
          }
          contactContentView.displayNameLabel.backgroundColor = contains(selectedContactUserIds, contact.userId) ?  UIColor.redColor() : UIColor.clearColor()
        }
        return contactCell
      }
    default:
      var messageCell = collectionView.dequeueReusableCellWithReuseIdentifier("MessageCollectionViewCell", forIndexPath: indexPath) as! MessageCollectionViewCell
      return messageCell
    }
  }
  
}

// MARK: Contact collection view data source

extension MessageViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.section {
    case 0:
      if indexPath.row == 0 {
        presentAddContactAlertController()
      } else if indexPath.row <= contacts.count {
        if !contains(selectedContactUserIds, contacts[indexPath.row - 1].userId) {
          selectContactForIndexPath(indexPath)
        } else {
          deselectContactForIndexPath(indexPath)
        }
        updatePlaceholderLabelCharacterCounterLabelAndSendButton()
      }
    default:
      break
    }
  }
  
}

// MARK: Contact collection view delegate flow layout

extension MessageViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let collectionViewHeight = collectionView.frame.size.height
    switch indexPath.section {
    case 0:
      if collectionViewHeight > 319.0 {
        let cellLength = screenWidth / 4
        return CGSize(width: cellLength, height: cellLength)
      } else {
        let cellLength = screenWidth / 6
        return CGSize(width: cellLength, height: cellLength)
      }
    default:
      return CGSize(width: screenWidth, height: 100)
    }
    
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    let leftRightInsetSize: CGFloat = 0.0 // -4.0 for 6 plus
    return UIEdgeInsets(top: 0.0, left: leftRightInsetSize, bottom: 0.0, right: leftRightInsetSize)
  }
  
}

// MARK: Utilities

extension MessageViewController {
  
  private func selectContactForIndexPath(indexPath: NSIndexPath) {
    selectedContactUserIds += [contacts[indexPath.row - 1].userId]
    contactCollectionView.reloadItemsAtIndexPaths([indexPath])
  }
  
  private func deselectContactForIndexPath(indexPath: NSIndexPath) {
    for c in 0..<selectedContactUserIds.count {
      if selectedContactUserIds[c] == contacts[indexPath.row - 1].userId {
        selectedContactUserIds.removeAtIndex(c)
        contactCollectionView.reloadItemsAtIndexPaths([indexPath])
        break
      }
    }
  }
  
  private func presentAddContactAlertController() {
    let alert = UIAlertController(title: "Add Contact", message: "Type an username", preferredStyle: .Alert)
    
    alert.addTextFieldWithConfigurationHandler {
      textField in
      textField.placeholder = "username"
      textField.secureTextEntry = false
      textField.textAlignment = .Center
    }
    
    let textField = alert.textFields![0] as! UITextField
    
    let addAction = UIAlertAction(title: "Add", style: .Default) {
      action in
      
      let contact: () = fetchUserByUsername(textField.text) {
        user in
        
        let currentContacts = self.contacts.map {$0.userId}
        if !contains(currentContacts, user.id) {
          saveUserAsContact(user) {
            success, error in

            if success {
              fetchContacts {
                self.contacts = $0
                let newContactIndexPath = NSIndexPath(forItem: self.contacts.count, inSection: 0)
                self.contactCollectionView.reloadItemsAtIndexPaths([newContactIndexPath])
              }
            } else {
              println(error!)
            }
          }
        }
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {$0}
    
    alert.addAction(addAction)
    alert.addAction(cancelAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  private func presentDeleteContactAlertControllerForIndexPath(indexPath: NSIndexPath) {
    let contact = contacts[indexPath.row - 1]
    var contactDisplayName: String!
    contact.getUser {
      contactDisplayName = $0.displayName
      let alert = UIAlertController(title: "Remove Contact", message: "Are you sure you want to remove \(contactDisplayName) from your contacts?", preferredStyle: .ActionSheet)
      
      let deleteAction = UIAlertAction(title: "Remove \(contactDisplayName)", style: .Destructive) {
        action in
        
        deleteContact(contact.id) {
          success, error in
          
          if success {
            fetchContacts {
              self.contacts = $0
              var reloadIndexPaths: [NSIndexPath] = []
              if indexPath.row == self.contacts.count + 1 {
                reloadIndexPaths += [NSIndexPath(forItem: indexPath.row, inSection: 0)]
              } else {
                for i in indexPath.row...self.contacts.count + 1 {
                  reloadIndexPaths += [NSIndexPath(forItem: i, inSection: 0)]
                }
              }
              self.contactCollectionView.reloadItemsAtIndexPaths(reloadIndexPaths)
            }
          } else {
            println(error!)
          }
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {$0}
      
      alert.addAction(deleteAction)
      alert.addAction(cancelAction)
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }
  
}

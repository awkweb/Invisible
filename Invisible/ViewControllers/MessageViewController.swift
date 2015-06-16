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
  
  var oldMessageTextViewContentSize: CGFloat!
  let baseMessageTextViewContentSize: CGFloat = 28.0
  
  var contactGridNumberItemsPerLineForSectionAtIndex: Int!
  var contactGridInteritemSpacingForSectionAtIndex: CGFloat!
  var contactGridLineSpacingForSectionAtIndex: CGFloat!
  var messageAspectRatioForItemsInSectionAtIndex: CGFloat!
  
  let messageCharacterLimit = 140
  var numberOfCharactersRemaining: Int!
  
  var contacts: [String] = []
  var selectedContactUserIds: [String] = []
  var conversation: Conversation?
  
  // MARK: View life cycle
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    addNotificationCenterObservers()
    messageToolbar.messageContentView.messageTextView.becomeFirstResponder()
    let longPress = UILongPressGestureRecognizer(target: self, action: "performLongPressGestureRecognizer:")
    contactCollectionView.addGestureRecognizer(longPress)
    initializeContactCollectionViewLayoutForScreenWidth(UIScreen.mainScreen().bounds.size.width)
    contacts = currentUser().contacts!
    oldMessageTextViewContentSize = baseMessageTextViewContentSize
    numberOfCharactersRemaining = messageCharacterLimit
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    messageToolbar.messageContentView.messageTextView.delegate = self
    contactCollectionView.dataSource = self
    contactCollectionView.delegate = self
  }
  
  // MARK: Notification center
  
  private func addNotificationCenterObservers() {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue = NSOperationQueue.mainQueue()
    
    notificationCenter.addObserverForName("handlePushNotification", object: nil, queue: mainQueue) {
      notification in
      if let conversationId = notification.userInfo?["conversationId"] as? String {
        fetchConversationFromId(conversationId) {
          conversation in
          self.selectedContactUserIds = conversation.participantIds.filter {$0 != currentUser().id}
          self.conversation = conversation
          self.contactCollectionView.reloadData()
          self.adjustContactCollectionViewLayoutForArray(self.selectedContactUserIds)
        }
      }
    }
    
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
      if let contentSizeHeight = notification.object?.contentSize.height {
        let isFromSendButtonPressed = notification.userInfo?["fromSendButtonPressed"] != nil
        let newMessageTextViewContentSize = isFromSendButtonPressed ? self.baseMessageTextViewContentSize : contentSizeHeight
        let dy = newMessageTextViewContentSize - self.oldMessageTextViewContentSize
        self.oldMessageTextViewContentSize = newMessageTextViewContentSize
        self.adjustMessageToolbarForMessageTextViewContentSizeChange(dy)
        self.updatePlaceholderLabelCharacterCounterLabelAndSendButton()
      }
    }
    
  }
  
  private func removeNotificationCenterObservers() {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.removeObserver("handlePushNotification")
    notificationCenter.removeObserver(UIKeyboardWillShowNotification)
    notificationCenter.removeObserver(UIKeyboardWillHideNotification)
    notificationCenter.removeObserver(UITextViewTextDidChangeNotification)
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
      scrollMessageTextViewToBottomAnimated(true)
      return
    }
    
    adjustMessageToolbarHeightConstraintByDelta(dy)
    if !contentSizeIsIncreasing {
      scrollMessageTextViewToBottomAnimated(false)
    } else if contentSizeIsIncreasing {
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
      }, completion: nil)
  }
  
  private func messageToolbarHasReachedMaximumHeight() -> Bool {
    return numberOfCharactersRemaining < 0
  }
  
  private func updatePlaceholderLabelCharacterCounterLabelAndSendButton() {
    let contentView = messageToolbar.messageContentView
    numberOfCharactersRemaining = messageCharacterLimit - count(contentView.messageTextView.text)
    contentView.characterCounterLabel.text = "\(numberOfCharactersRemaining)"
    UIView.animateWithDuration(0.5) {
      contentView.placeholderLabel.hidden = !contentView.messageTextView.text.isEmpty
      contentView.sendButton.enabled = !contentView.messageTextView.text.isEmpty && !self.selectedContactUserIds.isEmpty && self.numberOfCharactersRemaining >= 0
      contentView.characterCounterLabel.hidden = self.oldMessageTextViewContentSize <= self.baseMessageTextViewContentSize
    }
  }
  
  // MARK: Contact collection view
  
  private func initializeContactCollectionViewLayoutForScreenWidth(screenWidth: CGFloat) {
    switch screenWidth {
    case 320.0:
      contactGridNumberItemsPerLineForSectionAtIndex = 6
      contactGridInteritemSpacingForSectionAtIndex = 0
      contactGridLineSpacingForSectionAtIndex = 0
      messageAspectRatioForItemsInSectionAtIndex = 1.9
    default:
      contactGridNumberItemsPerLineForSectionAtIndex = 4
      contactGridInteritemSpacingForSectionAtIndex = 1
      contactGridLineSpacingForSectionAtIndex = 1
      messageAspectRatioForItemsInSectionAtIndex = 5
    }
  }
  
  private func adjustContactCollectionViewLayoutForArray(array: [String]) {
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    if screenWidth != 320 {
      contactGridNumberItemsPerLineForSectionAtIndex = array.isEmpty ? 4 : 6
      contactGridInteritemSpacingForSectionAtIndex = array.isEmpty ? 1 : 0
      contactGridLineSpacingForSectionAtIndex = array.isEmpty ? 1 : 0
      messageAspectRatioForItemsInSectionAtIndex = array.isEmpty ? 5 : 2.35
      contactCollectionView.performBatchUpdates({
        self.contactCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }, completion: nil)
    }
  }
  
}

// MARK: Message toolbar delegate

extension MessageViewController: MessageToolbarDelegate {
  
  func sendButtonPressed(sender: UIButton) {
    let textView = messageToolbar.messageContentView.messageTextView
    if !textView.text.isEmpty && !selectedContactUserIds.isEmpty {
      let conversationId = conversation != nil ? conversation!.id : "empty"
      let parameters: [NSObject : AnyObject] = [
        "conversation_id": conversationId,
        "sender_id": currentUser().id,
        "sender_name": currentUser().displayName,
        "message_text": textView.text,
        "date_time": Helpers.dateToPrettyString(NSDate()),
        "recipient_ids": selectedContactUserIds
      ]
      
      PFCloud.callFunctionInBackground("sendMessage", withParameters: parameters) {
        success, error in
        if success != nil {
          textView.text = nil
          self.deselectAllSelectedContacts()
          self.adjustContactCollectionViewLayoutForArray(self.selectedContactUserIds)
          self.conversation = nil
          self.contactCollectionView.reloadSections(NSIndexSet(index: 1))
          NSNotificationCenter.defaultCenter().postNotificationName("UITextViewTextDidChangeNotification", object: textView, userInfo: ["fromSendButtonPressed": true])
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
      if indexPath.row == 0 {
        let addCell = collectionView.dequeueReusableCellWithReuseIdentifier("AddCollectionViewCell", forIndexPath: indexPath) as! AddCollectionViewCell
        return addCell
      } else {
        let contactCell = collectionView.dequeueReusableCellWithReuseIdentifier("ContactCollectionViewCell", forIndexPath: indexPath) as! ContactCollectionViewCell
        if indexPath.row <= contacts.count {
          let userId = contacts[indexPath.row - 1]
          let contactContentView = contactCell.contactCollectionViewCellContentView
          fetchUserFromId(userId) {
            contactContentView.displayNameLabel.text = $0.displayName
            $0.getPhoto {contactContentView.imageView.image = $0}
          }
          contactContentView.displayNameLabel.backgroundColor = contains(selectedContactUserIds, userId) ?  UIColor.red() : UIColor.clearColor()
        }
        return contactCell
      }
    default:
      let messageCell = collectionView.dequeueReusableCellWithReuseIdentifier("MessageCollectionViewCell", forIndexPath: indexPath) as! MessageCollectionViewCell
      let messageContentView = messageCell.messageCollectionViewCellContentView
      if conversation != nil {
        messageContentView.dateTimeLabel.text = conversation!.messageTime
        messageContentView.messageTextView.text = conversation!.messageText
        fetchUserFromId(conversation!.senderId) {
          messageContentView.senderDisplayNameLabel.text = self.conversation!.senderId == currentUser().id ? "You" : $0.displayName
          $0.getPhoto {messageContentView.senderImageView.image = $0}
        }
        messageContentView.messageTextView.backgroundColor = conversation!.senderId == currentUser().id ? UIColor.blue() : UIColor.grayL()
        messageContentView.messageTextView.textColor = conversation!.senderId == currentUser().id ? UIColor.whiteColor() : UIColor.grayD()
      }
      messageContentView.dateTimeLabel.hidden = conversation == nil // Same type of thing for contactCell
      messageContentView.senderDisplayNameLabel.hidden = conversation == nil
      messageContentView.senderImageView.hidden = conversation == nil
      messageContentView.messageTextView.hidden = conversation == nil
      return messageCell
    }
  }
  
}

// MARK: Contact collection view delegate

extension MessageViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.section {
    case 0:
      if indexPath.row == 0 {
        if contacts.count < 11 {
          presentAddContactAlertController()
        } else {
          presentAlertControllerWithHeaderText("Your grid is full!", message: "Delete a contact before adding another.", actionMessage: "Okay")
        }
      } else if indexPath.row <= contacts.count {
        selectDeselectContactForIndexPath(indexPath)
        adjustContactCollectionViewLayoutForArray(selectedContactUserIds)
        if !selectedContactUserIds.isEmpty {
          let participantIds = selectedContactUserIds + [currentUser().id]
          fetchConversationForParticipantIds(participantIds) {
            conversation, error in
            self.conversation = conversation
            collectionView.reloadSections(NSIndexSet(index: 1))
          }
        } else {
          conversation = nil
          collectionView.reloadSections(NSIndexSet(index: 1))
        }
        updatePlaceholderLabelCharacterCounterLabelAndSendButton()
      }
    default:
      break
    }
  }
  
}

// MARK: Contact collection view delegate flow layout

extension MessageViewController: KRLCollectionViewDelegateGridLayout {
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberItemsPerLineForSectionAtIndex section: Int) -> Int {
    switch section {
    case 0: return contactGridNumberItemsPerLineForSectionAtIndex
    default: return 1
    }
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, aspectRatioForItemsInSectionAtIndex section: Int) -> CGFloat {
    switch section {
    case 0: return 1
    default: return messageAspectRatioForItemsInSectionAtIndex
    }
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interitemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return contactGridInteritemSpacingForSectionAtIndex
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, lineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return contactGridLineSpacingForSectionAtIndex
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsZero
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceLengthForHeaderInSection section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceLengthForFooterInSection section: Int) -> CGFloat {
    return 0.0
  }
  
}

// MARK: Utilities

extension MessageViewController {
  
  private func selectDeselectContactForIndexPath(indexPath: NSIndexPath) {
    if !contains(selectedContactUserIds, contacts[indexPath.row - 1]) {
      selectedContactUserIds.append(contacts[indexPath.row - 1])
      contactCollectionView.reloadItemsAtIndexPaths([indexPath])
    } else {
      for c in 0..<selectedContactUserIds.count {
        if selectedContactUserIds[c] == contacts[indexPath.row - 1] {
          selectedContactUserIds.removeAtIndex(c)
          contactCollectionView.reloadItemsAtIndexPaths([indexPath])
          break
        }
      }
    }
  }
  
  private func deselectAllSelectedContacts() {
    var selectedContactIndexPaths: [NSIndexPath] = []
    for i in 0..<contacts.count {
      if contains(selectedContactUserIds, contacts[i]) {
        selectedContactIndexPaths.append(NSIndexPath(forItem: i + 1, inSection: 0))
      }
    }
    selectedContactUserIds = []
    contactCollectionView.reloadItemsAtIndexPaths(selectedContactIndexPaths)
  }
  
  private func presentAddContactAlertController() {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue = NSOperationQueue.mainQueue()
    
    let alert = UIAlertController(title: "Add Contact", message: "Type an username", preferredStyle: .Alert)
    alert.addTextFieldWithConfigurationHandler {
      textField in
      textField.placeholder = "username"
      textField.secureTextEntry = false
      textField.textAlignment = .Center
      textField.returnKeyType = .Done
    }
    let textField = alert.textFields![0] as! UITextField
    
    let addAction = UIAlertAction(title: "Add", style: .Default) {
      action in
      let user: () = fetchUserIdFromUsername(textField.text) {
        saveUserToContactsForUserId($0) {
          success, error in
          if success {
            self.contacts = currentUser().contacts!
            let newContactIndexPath = NSIndexPath(forItem: currentUser().contacts!.count, inSection: 0)
            self.contactCollectionView.reloadItemsAtIndexPaths([newContactIndexPath])
          } else {println(error!)}
          notificationCenter.removeObserver(UITextFieldTextDidChangeNotification, name: nil, object: textField)
        }
      }
    }
    addAction.enabled = false
    
    notificationCenter.addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: mainQueue) {
      notification in
      addAction.enabled = !textField.text.isEmpty
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
      action in
      notificationCenter.removeObserver(UITextFieldTextDidChangeNotification, name: nil, object: textField)
    }
    
    alert.addAction(addAction)
    alert.addAction(cancelAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  private func presentDeleteContactAlertControllerForIndexPath(indexPath: NSIndexPath) {
    let userId = contacts[indexPath.row - 1]
    var userDisplayName: String!
    fetchUserFromId(userId) {
      userDisplayName = $0.displayName
      let alert = UIAlertController(title: "Remove Contact", message: "Are you sure you want to remove \(userDisplayName) from your contacts?", preferredStyle: .ActionSheet)
      let deleteAction = UIAlertAction(title: "Remove \(userDisplayName)", style: .Destructive) {
        action in
        deleteUserFromContactsForUserId(userId) {
          success, error in
          if success {
            self.contacts = currentUser().contacts!
            var reloadIndexPaths: [NSIndexPath] = []
            if indexPath.row == self.contacts.count + 1 {
              reloadIndexPaths += [NSIndexPath(forItem: indexPath.row, inSection: 0)]
            } else {
              for i in indexPath.row...self.contacts.count + 1 {
                reloadIndexPaths += [NSIndexPath(forItem: i, inSection: 0)]
              }
            }
            self.contactCollectionView.performBatchUpdates({
              self.contactCollectionView.reloadItemsAtIndexPaths(reloadIndexPaths)
            }, completion: nil)
          } else {
            println(error!)
          }
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
      
      alert.addAction(deleteAction)
      alert.addAction(cancelAction)
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  private func presentAlertControllerWithHeaderText(header: String, message: String, actionMessage: String) {
    let alert = UIAlertController(title: header, message: message, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: actionMessage, style: .Default, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
  }
  
}

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
    saveUserInstallation()
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
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    removeNotificationCenterObservers()
  }
  
  // MARK: Notification center
  
  private func addNotificationCenterObservers() {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue = NSOperationQueue.mainQueue()
    
    notificationCenter.addObserverForName("handlePushNotification", object: nil, queue: mainQueue) {
      notification in
      if let conversationId = notification.userInfo?["conversationId"] as? String {
        fetchConversationFromId(conversationId) {
          conversation, error in
          if let conversation = conversation as Conversation! {
            self.conversation = conversation
            self.deselectAllSelectedContacts()
            if !contains(self.contacts, self.conversation!.senderId) {
              self.presentAddContactAlertControllerForConversation(self.conversation!)
            } else {
              self.selectContactsForConversation(self.conversation!)
            }
          } else {
            println(error!)
          }
        }
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
    
    if gestureState == .Began && indexPath!.row != 0 && indexPath!.row <= contacts.count && !contains(selectedContactUserIds, contacts[indexPath!.row - 1]) {
      presentDeleteContactAlertControllerForIndexPath(indexPath!)
    }
  }
  
  // MARK: Message toolbar
  
  private func adjustMessageToolbarForMessageTextViewContentSizeChange(dy: CGFloat) {
    let contentSizeIsIncreasing = dy > 0
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
  
  private func updatePlaceholderLabelCharacterCounterLabelAndSendButton() {
    let contentView = messageToolbar.messageContentView
    let textView = contentView.messageTextView
    numberOfCharactersRemaining = messageCharacterLimit - count(textView.text)
    contentView.characterCounterLabel.text = "\(numberOfCharactersRemaining)"
    UIView.animateWithDuration(0.5) {
      contentView.placeholderLabel.hidden = !textView.text.isEmpty
      contentView.sendButton.enabled = !textView.text.isEmpty && !self.selectedContactUserIds.isEmpty && self.numberOfCharactersRemaining >= 0
      contentView.characterCounterLabel.hidden = (textView.contentSize.height / textView.font.lineHeight) < 2
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
      messageAspectRatioForItemsInSectionAtIndex =  2.35
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
        "date_time": NSDate(),
        "recipient_ids": selectedContactUserIds
      ]
      
      PFCloud.callFunctionInBackground("sendMessage", withParameters: parameters) {
        success, error in
        if let success = success as? Int {
          SoundPlayer().playSound(.Send)
          textView.text = nil
          self.deselectAllSelectedContacts()
          self.conversation = nil
          self.contactCollectionView.reloadSections(NSIndexSet(index: 1))
          NSNotificationCenter.defaultCenter().postNotificationName("UITextViewTextDidChangeNotification", object: textView, userInfo: ["fromSendButtonPressed": true])
        } else {
          if let error = error {
            self.presentAlertControllerWithHeaderText("Send message failed", message: nil, actionMessage: "Okay")
            println(error)
          }
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
    case 0: return contacts.count + 1
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
        let contactContentView = contactCell.contactCollectionViewCellContentView
        if indexPath.row <= contacts.count {
          let userId = contacts[indexPath.row - 1]
          fetchUserFromId(userId) {
            user, error in
            if let user = user {
              contactContentView.displayNameLabel.text = user.displayName
              user.getPhoto {contactContentView.imageView.image = $0}
            }
          }
        }
        return contactCell
      }
    default:
      let messageCell = collectionView.dequeueReusableCellWithReuseIdentifier("MessageCollectionViewCell", forIndexPath: indexPath) as! MessageCollectionViewCell
      let messageContentView = messageCell.messageCollectionViewCellContentView
      if let conversation = conversation {
        messageContentView.dateTimeLabel.text = conversation.messageTime.formattedAsTimeAgo()
        messageContentView.messageTextView.text = conversation.messageText
        fetchUserFromId(conversation.senderId) {
          user, error in
          if let user = user {
            messageContentView.senderDisplayNameLabel.text = self.conversation!.senderId == currentUser().id ? "You" : user.displayName
            user.getPhoto {messageContentView.senderImageView.image = $0}
          } else {
            if let error = error {
              println(error)
            }
          }
        }
        messageContentView.messageTextView.backgroundColor = conversation.senderId == currentUser().id ? UIColor.blue() : UIColor.grayL()
        messageContentView.messageTextView.textColor = conversation.senderId == currentUser().id ? UIColor.whiteColor() : UIColor.grayD()
      }
      messageContentView.noMessageHistoryLabel.hidden = conversation != nil || selectedContactUserIds.isEmpty
      messageContentView.dateTimeLabel.hidden = conversation == nil
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
        presentAddContactAlertController()
      } else if indexPath.row <= contacts.count {
        selectContactForIndexPath(indexPath)
        let participantIds = selectedContactUserIds + [currentUser().id]
        fetchConversationForParticipantIds(participantIds) {
          conversation, error in
          self.conversation = conversation
          collectionView.reloadSections(NSIndexSet(index: 1))
        }
        updatePlaceholderLabelCharacterCounterLabelAndSendButton()
      }
    default:
      break
    }
  }
  
  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.section {
    case 0:
      if indexPath.row == 0 {
        presentAddContactAlertController()
      } else if indexPath.row <= contacts.count {
        deselectContactForIndexPath(indexPath)
        if selectedContactUserIds.isEmpty {
          conversation = nil
          collectionView.reloadSections(NSIndexSet(index: 1))
        } else {
          let participantIds = selectedContactUserIds + [currentUser().id]
          fetchConversationForParticipantIds(participantIds) {
            conversation, error in
            self.conversation = conversation
            collectionView.reloadSections(NSIndexSet(index: 1))
          }
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
  
  private func saveUserInstallation() {
    let installation = PFInstallation.currentInstallation()
    installation["user"] = PFUser.currentUser()
    installation.saveInBackgroundWithBlock {
      success, error in
      
      if !success {
        println(error)
      }
    }
  }
  
  private func selectContactForIndexPath(indexPath: NSIndexPath) {
    if !contains(selectedContactUserIds, contacts[indexPath.row - 1]) {
      selectedContactUserIds.append(contacts[indexPath.row - 1])
    }
  }
  
  private func selectContactsForConversation(conversation: Conversation) {
    selectedContactUserIds = conversation.participantIds.filter {contains(self.contacts, $0)}
    for s in selectedContactUserIds {
      for c in 0..<self.contacts.count {
        if s == self.contacts[c] {
          contactCollectionView.selectItemAtIndexPath(NSIndexPath(forItem: c + 1, inSection: 0), animated: true, scrollPosition: .None)
          break
        }
      }
    }
    contactCollectionView.reloadSections(NSIndexSet(index: 1))
  }
  
  private func deselectContactForIndexPath(indexPath: NSIndexPath) {
    if contains(selectedContactUserIds, contacts[indexPath.row - 1]) {
      selectedContactUserIds = selectedContactUserIds.filter {$0 != self.contacts[indexPath.row - 1]}
    }
  }
  
  private func deselectAllSelectedContacts() {
    for indexPath in contactCollectionView.indexPathsForSelectedItems() {
      contactCollectionView.deselectItemAtIndexPath((indexPath as! NSIndexPath), animated: false)
    }
    selectedContactUserIds = []
  }
  
  private func presentAddContactAlertController() {
    if contacts.count < 7 {
      let notificationCenter = NSNotificationCenter.defaultCenter()
      let mainQueue = NSOperationQueue.mainQueue()
      
      let alert = UIAlertController(title: "Add Contact", message: "Type an username", preferredStyle: .Alert)
      alert.addTextFieldWithConfigurationHandler {
        textField in
        textField.secureTextEntry = false
        textField.textAlignment = .Center
        textField.returnKeyType = .Done
      }
      let textField = alert.textFields![0] as! UITextField
      
      let addAction = UIAlertAction(title: "Add", style: .Default) {
        action in
        fetchUserIdFromUsername(textField.text) {
          userId, error in
          if userId != nil {
            addUserToContactsForUserId(userId!) {
              success, error in
              if success != nil {
                self.contacts = currentUser().contacts!
                let newContactIndexPath = NSIndexPath(forItem: currentUser().contacts!.count, inSection: 0)
                self.contactCollectionView.performBatchUpdates({
                  self.contactCollectionView.insertItemsAtIndexPaths([newContactIndexPath])
                  }, completion: nil)
              } else {
                println(error!)
              }
              notificationCenter.removeObserver(UITextFieldTextDidChangeNotification, name: nil, object: textField)
            }
          } else {
            if error != nil {
              self.presentAlertControllerWithHeaderText("Unable to find user", message: "Try adding them again.", actionMessage: "Okay")
            }
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
    } else {
      presentAlertControllerWithHeaderText("Your grid is full", message: "Delete a contact before adding another.", actionMessage: "Okay")
    }
  }
  
  private func presentAddContactAlertControllerForConversation(conversation: Conversation) {
    fetchUserFromId(conversation.senderId) {
      user, error in
      if let user = user {
        let alert = UIAlertController(title: "\(user.displayName) is not in your contacts", message: "Would you like to add \(user.displayName)?", preferredStyle: .Alert)
        let addAction = UIAlertAction(title: "Add", style: .Default) {
          action in
          if self.contacts.count < 7 {
            addUserToContactsForUserId(conversation.senderId) {
              success, error in
              if success != nil {
                self.contacts = currentUser().contacts!
                let newContactIndexPath = NSIndexPath(forItem: currentUser().contacts!.count, inSection: 0)
                self.contactCollectionView.performBatchUpdates({
                  self.contactCollectionView.insertItemsAtIndexPaths([newContactIndexPath])
                  }, completion: nil)
                self.selectContactsForConversation(conversation)
              } else {
                println(error!)
              }
            }
          } else {
            self.presentAlertControllerWithHeaderText("Your grid is full", message: "Delete a contact before adding another.", actionMessage: "Okay")
          }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
          action in
          self.selectContactsForConversation(conversation)
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
      }
    }
  }
  
  private func presentDeleteContactAlertControllerForIndexPath(indexPath: NSIndexPath) {
    let userId = contacts[indexPath.row - 1]
    let alert = UIAlertController(title: "Remove from contacts", message: nil, preferredStyle: .ActionSheet)
    let deleteAction = UIAlertAction(title: "Remove", style: .Destructive) {
      action in
      deleteUserFromContactsForUserId(userId) {
        success, error in
        if success != nil {
          self.contacts = currentUser().contacts!
          self.contactCollectionView.performBatchUpdates({
            self.contactCollectionView.deleteItemsAtIndexPaths([indexPath])
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
  
  private func presentAlertControllerWithHeaderText(header: String, message: String?, actionMessage: String = "Okay") {
    let alert = UIAlertController(title: header, message: message, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: actionMessage, style: .Default, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
  }
  
}

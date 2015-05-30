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
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var toolbar: UIToolbar!
  @IBOutlet weak var messageTextField: UITextField!
  
  var contacts: [Contact] = []
  var selectedContacts: [String] = []
  var pushMessage: String?
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "remoteNotificationReceived:", name: "PushNotificationMessageReceivedNotification", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.delegate = self
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    messageTextField.becomeFirstResponder()
    
    fetchContacts({
      fetchedContacts in
      self.contacts = fetchedContacts
      self.collectionView.reloadData()
    })
  }
  
  // MARK: Notification Observers
  func remoteNotificationReceived(notification: NSNotification) {
    let userInfo = notification.userInfo!
    let info = userInfo["aps"] as? [String: AnyObject]
    let alert = info!["alert"] as! String
    pushMessage = alert
    collectionView.reloadData()
  }
  
  func keyboardWillShow(notification: NSNotification) {
    if let frameObject: AnyObject = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] {
      let keyboardRect = frameObject.CGRectValue()
      toolbar.frame.origin.y = keyboardRect.origin.y - toolbar.frame.height
    }
  }
  
  @IBAction func sendBarButtonItemPressed(sender: UIBarButtonItem) {
    PFCloud.callFunctionInBackground("sendPush", withParameters:
      [
        "from": "\(currentUser().username)",
        "to": selectedContacts,
        "message": messageTextField.text,
        "senderId": "\(currentUser().id)"
      ]
      ) {
        success, error in
        
        if success != nil {
          println(success!)
        } else {
          println(error!)
        }
    }
  }
  
  private func logOut() {
    PFUser.logOutInBackgroundWithBlock {
      error in
      
      if error != nil {
        println("Log out error")
      } else {
        println("Log out success!")
        let logInViewController = kStoryboard.instantiateViewControllerWithIdentifier("LogInViewController") as! LogInViewController
        self.presentViewController(logInViewController, animated: true, completion: nil)
      }
    }
  }
  
  private func addContactAlertController() {
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
                self.collectionView.reloadData()
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
  
  // TODO: Don't reload data on select
  private func selectContact(indexPath: NSIndexPath) {
    if indexPath.row < contacts.count {
      if !contains(selectedContacts, contacts[indexPath.row].userId) {
        selectedContacts += [contacts[indexPath.row].userId]
      } else {
        for c in 0..<selectedContacts.count {
          if selectedContacts[c] == contacts[indexPath.row].userId {
            selectedContacts.removeAtIndex(c)
            break
          }
        }
      }
      collectionView.reloadData()
    }
  }
  
}

// MARK: UICollectionViewDataSource
extension MessageViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    switch indexPath.section {
    case 0:
      var actionCell = collectionView.dequeueReusableCellWithReuseIdentifier("ActionCollectionViewCell", forIndexPath: indexPath) as! ActionCollectionViewCell
      
      switch indexPath.row {
      case 0:
        actionCell.backgroundColor = UIColor.blueColor()
        actionCell.imageView.image = UIImage(named: "settings")
        actionCell.nameLabel.text = "Settings"
      case 1:
        actionCell.backgroundColor = UIColor.greenColor()
        actionCell.imageView.image = UIImage(named: "add")
        actionCell.nameLabel.text = "Add"
      case 2:
        actionCell.backgroundColor = UIColor.redColor()
        actionCell.imageView.image = UIImage(named: "user")
        actionCell.nameLabel.text = "Contacts"
      case 3:
        actionCell.backgroundColor = UIColor.orangeColor()
        currentUser().getPhoto({
          image in
          
          actionCell.imageView.image = image
        })
        actionCell.nameLabel.text = "You"
      default:
        break
      }
      
      return actionCell
    case 1:
      var pushCell = collectionView.dequeueReusableCellWithReuseIdentifier("PushCollectionViewCell", forIndexPath: indexPath) as! PushCollectionViewCell
      
      pushCell.backgroundColor = UIColor.whiteColor()
      if pushMessage != nil {
        pushCell.messageLabel.text = pushMessage!
      } else {
        pushCell.messageLabel.text = ""
      }
      
      return pushCell
    default:
      var contactCell = collectionView.dequeueReusableCellWithReuseIdentifier("ContactCollectionViewCell", forIndexPath: indexPath) as! ContactCollectionViewCell
      
      switch indexPath.row {
      case 0, 2, 5, 7, 8:
        contactCell.backgroundColor = UIColor.grayColor()
      default:
        contactCell.backgroundColor = UIColor.blackColor()
      }
      
      if indexPath.row < contacts.count {
        let contact = contacts[indexPath.row]
        contact.getUser({
          user in
          
          contactCell.nameLabel.text = user.username
          contactCell.nameLabel.hidden = false
          
          user.getPhoto({
            image in
            contactCell.imageView.image = image
            contactCell.imageView.hidden = false
          })
        })
        
        if contains(selectedContacts, contact.userId) {
          contactCell.selectedImageView.hidden = false
        } else {
          contactCell.selectedImageView.hidden = true
        }
      } else {
        contactCell.imageView.hidden = true
        contactCell.nameLabel.hidden = true
        contactCell.selectedImageView.hidden = true
      }
      return contactCell
    }
  }
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 3
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 4
    case 1:
      return 1
    case 2:
      return 8
    default:
      return 0
    }
  }
  
}

// MARK: UICollectionViewDelegate
extension MessageViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 0:
        logOut()
      case 1:
        addContactAlertController()
      default:
        println("default case")
      }
    case 1:
      println("section 2 touched")
    case 2:
      selectContact(indexPath)
    default:
      println("default case")
    }
  }
  
}

// MARK: UICollectionViewDelegateFlowLayout
extension MessageViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let collectionViewHeight = collectionView.frame.height
    let collectionViewWidth = collectionView.frame.width
    let cellHeight = collectionViewWidth / 4
    let messageCellHeight = collectionViewHeight - (cellHeight * 3)
    
    switch indexPath.section {
    case 0, 2:
      return CGSize(width: cellHeight, height: cellHeight)
    default:
      return CGSize(width: collectionViewWidth, height: messageCellHeight)
    }
  }
  
}

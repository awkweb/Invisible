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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.delegate = self
    
    messageTextField.becomeFirstResponder()
    
    // Better spot for this?
    let installation = PFInstallation.currentInstallation()
    installation["user"] = PFUser.currentUser()
    installation.saveInBackgroundWithBlock {
      success, error in
      
      if success {
        println("Association worked.")
      } else {
        println(error)
      }
    }
    
    fetchMatches({
      contacts in
      self.contacts = contacts
      self.collectionView.reloadData()
    })
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
}

extension MessageViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    var userCell = collectionView.dequeueReusableCellWithReuseIdentifier("UserCollectionViewCell", forIndexPath: indexPath) as! UserCollectionViewCell
    
    if indexPath.section == 0 {
      userCell.userNameLabel.hidden = false
      userCell.userImageView.hidden = false
      
      switch indexPath.row {
      case 0:
        userCell.backgroundColor = UIColor.blueColor()
        userCell.userNameLabel.text = "Settings"
      case 1:
        userCell.backgroundColor = UIColor.greenColor()
        userCell.userNameLabel.text = "Add"
      case 2:
        userCell.backgroundColor = UIColor.redColor()
        userCell.userNameLabel.text = "Remaining"
      case 3:
        currentUser()?.getPhoto {
          image in
          userCell.userImageView.image = image
        }
        userCell.userNameLabel.text = "You"
      default:
        break
      }
    } else if indexPath.section == 1 {
      if contains([0, 2, 5, 7, 8, 10], indexPath.row) {
        userCell.backgroundColor = UIColor.grayColor()
      } else {
        userCell.backgroundColor = UIColor.blackColor()
      }
      
      if indexPath.row < contacts.count {
        let user = contacts[indexPath.row].user
        userCell.userNameLabel.text = user.username
        userCell.userNameLabel.hidden = false
        user.getPhoto({
          image in
          userCell.userImageView.image = image
          userCell.userImageView.hidden = false
        })
      }
    }
    
    return userCell
  }
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 2
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 4
    case 1:
      return 12
    default:
      return 0
    }
  }

}

extension MessageViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    println("Cell \(indexPath.row) touched in section \(indexPath.section).")
    
    if indexPath.section == 0 && indexPath.row == 0 {
      logOut()
    }
  }
}

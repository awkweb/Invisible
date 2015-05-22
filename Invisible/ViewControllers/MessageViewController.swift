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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "New Message"
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: "goToSettingsVC:")
    
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
  }
  
  func goToSettingsVC(button: UIBarButtonItem) {
    pageController.goToPreviousVC()
  }
  
//  @IBAction func sendPushButtonPressed(sender: UIButton) {
//    
//    PFCloud.callFunctionInBackground("sendPush", withParameters:
//      [
//        "fromUser": "\(PFUser.currentUser()!.username!)",
//        "toUser": "\(toTextField.text)",
//        "message": "\(messageTextField.text)"
//      ]) {
//      success, error in
//      
//      if success != nil {
//        println(success!)
//      } else {
//        println(error)
//      }
//    }
//    
//  }
  
}

extension MessageViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    var userCell = collectionView.dequeueReusableCellWithReuseIdentifier("UserCollectionViewCell", forIndexPath: indexPath) as! UserCollectionViewCell
    
    userCell.userImageView.image = UIImage(named: "tom")
    userCell.userNameLabel.text = "tom"
    
    return userCell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 20
  }
  
}

extension MessageViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    println("Cell touched.")
  }
  
}

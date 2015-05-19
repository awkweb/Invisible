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
  
  @IBOutlet weak var toTextField: UITextField!
  @IBOutlet weak var messageTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "New Message"
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: "goToSettingsVC:")
    
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
  
  @IBAction func sendPushButtonPressed(sender: UIButton) {
    
    PFCloud.callFunctionInBackground("sendPush", withParameters: ["toUser": "\(toTextField.text)", "message": "\(messageTextField.text)"]) {
      success, error in
      
      if success != nil {
        println(success!)
      } else {
        println(error)
      }
    }
    
  }
  
}

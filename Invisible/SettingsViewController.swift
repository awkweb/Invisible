//
//  SettingsViewController.swift
//  Invisible
//
//  Created by thomas on 5/11/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Settings"
  }
  
  @IBAction func logOutButtonPressed(sender: UIButton) {
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

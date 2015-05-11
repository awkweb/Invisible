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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "New Message"
  }

  @IBAction func logOutButtonPressed(sender: UIButton) {
    PFUser.logOut()
    let logInViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LogInViewController") as! LogInViewController
    presentViewController(logInViewController, animated: true, completion: nil)
  }
}

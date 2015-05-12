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
  
  @IBOutlet weak var usernameLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "New Message"
    usernameLabel.text = PFUser.currentUser()?.username
  }
  
}

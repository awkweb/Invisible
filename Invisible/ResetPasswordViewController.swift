//
//  ResetPasswordViewController.swift
//  Invisible
//
//  Created by thomas on 5/17/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordViewController: UIViewController {
  
  @IBOutlet weak var emailTextField: UITextField!
  
  @IBAction func resetPasswordButtonPressed(sender: UIButton) {
    let email = emailTextField.text
    
    if !Helpers().isValidEmail(email) {
      println("Enter a valid email.")
    } else {
      PFUser.requestPasswordResetForEmail(email)
    }
  }
  
  @IBAction func cancelButtonPressed(sender: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

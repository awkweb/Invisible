//
//  LoginViewController.swift
//  Invisible
//
//  Created by thomas on 5/9/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {

  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    usernameTextField.delegate = self
    passwordTextField.delegate = self
  }
  
  @IBAction func logInButtonPressed(sender: UIButton) {
    let username = usernameTextField.text
    let password = passwordTextField.text
    
    if username.isEmpty {
      println("Enter a username.")
    } else {
      if password.isEmpty {
        println("Enter a password.")
      } else {
        logIn(username, password: password)
      }
    }
  }
  
  private func logIn(username: String, password: String) {
    PFUser.logInWithUsernameInBackground(username, password: password) {
      user, error in
      
      if user != nil {
        println("Log in success!")
        let messageVC = kStoryboard.instantiateViewControllerWithIdentifier("MessageViewController") as! MessageViewController
        self.presentViewController(messageVC, animated: true, completion: nil)
      } else {
        println("Log in error: \(error)")
      }
    }
  }
}

// MARK: UITextFieldDelegate
extension LogInViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    switch textField {
    case usernameTextField: passwordTextField.becomeFirstResponder()
    case passwordTextField: logInButtonPressed(UIButton())
    default: break
    }
    
    return true
  }
  
}

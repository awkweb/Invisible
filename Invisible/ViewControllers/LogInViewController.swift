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
        logInWithUsername(username, password: password)
      }
    }
  }
  
  private func logInWithUsername(username: String, password: String) {
    PFUser.logInWithUsernameInBackground(username, password: password) {
      user, error in
      
      if user != nil {
        println("Log in success!")
        self.saveUserInstallation()
        let messageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MessagesNavController") as! UIViewController
        self.presentViewController(messageVC, animated: true, completion: nil)
      } else {
        println("Log in error: \(error)")
      }
    }
  }
  
  // TODO: Move to SignUpVC
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

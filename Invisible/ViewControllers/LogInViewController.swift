//
//  LoginViewController.swift
//  Invisible
//
//  Created by thomas on 5/9/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

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
  
  @IBAction func signUpButtonPressed(sender: UIButton) {
    let signUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController
    self.presentViewController(signUpVC, animated: true, completion: nil)
  }
  
  private func logInWithUsername(username: String, password: String) {
    PFUser.logInWithUsernameInBackground(username, password: password) {
      user, error in
      if let user = user {
        let messageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MessagesNavController") as! UIViewController
        self.presentViewController(messageVC, animated: true, completion: nil)
      } else {
        if let error = error {
          println("Log in error: \(error)")
        }
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

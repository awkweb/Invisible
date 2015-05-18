//
//  SignUpViewController.swift
//  Invisible
//
//  Created by thomas on 5/9/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    usernameTextField.delegate = self
    passwordTextField.delegate = self
    emailTextField.delegate = self
  }
  
  @IBAction func signUpButtonPressed(sender: UIButton) {
    let username = usernameTextField.text
    let password = passwordTextField.text
    let email = emailTextField.text
    
    if username.isEmpty {
      println("Enter a username.")
    } else {
      if password.isEmpty {
        println("Enter a password.")
      } else {
        if !Helpers().isValidEmail(email) {
          println("Enter a valid email.")
        } else {
          signUp(username, password: password, email: email)
        }
      }
    }
  }
  
  @IBAction func cancelButtonPressed(sender: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  private func signUp(username: String, password: String, email: String) {
    var user = PFUser()
    user.username = username.lowercaseString
    user.password = password
    user.email = email.lowercaseString
    
    user.signUpInBackgroundWithBlock {
      succeeded, error in
      
      if let error = error {
        let errorString = error.userInfo?["error"] as? NSString
        println("Log in error: \(errorString)")
        
        if error.code == 202 {
          println("Bummer! Username already taken.")
        }
      } else {
        println("Sign up success!")
        let pageVC = kStoryboard.instantiateViewControllerWithIdentifier("PageViewController") as! PageViewController
        self.presentViewController(pageVC, animated: true, completion: nil)
      }
    }
  }
  
}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    switch textField {
    case usernameTextField: emailTextField.becomeFirstResponder()
    case emailTextField: passwordTextField.becomeFirstResponder()
    case passwordTextField: textField.resignFirstResponder()
    default: break
    }
    
    return true
  }
  
}

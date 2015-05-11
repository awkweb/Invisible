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
        if isValidEmail(email) == false {
          println("Enter a valid email.")
        } else {
          signUp(username, password: password, email: email)
        }
      }
    }
  }
  
  @IBAction func cancelButtonPressed(sender: UIButton) {
    self.dismissViewControllerAnimated(true, completion: nil)
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
        let messageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MessageViewController") as! MessageViewController
        self.presentViewController(messageViewController, animated: true, completion: nil)
      }
    }
  }
  
  private func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(email)
  }
  
}

extension SignUpViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    switch textField {
    case usernameTextField:
      emailTextField.becomeFirstResponder()
    case emailTextField:
      passwordTextField.becomeFirstResponder()
    case passwordTextField:
      textField.resignFirstResponder()
    default:
      textField.resignFirstResponder()
    }
    
    return true
  }
  
}

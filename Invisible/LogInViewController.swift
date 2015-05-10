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
  
  @IBAction func loginButtonPressed(sender: UIButton) {
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
  
  @IBAction func signUpButtonPressed(sender: UIButton) {
    self.performSegueWithIdentifier("presentSignUpVC", sender: self)
  }
  
  private func logIn(username: String, password: String) {
    PFUser.logInWithUsernameInBackground(username, password: password) {
      user, error in
      
      if user != nil {
        println("Log in success!")
      } else {
        println("Log in error: \(error)")
      }
    }
  }

}

//
//  SignUpViewController.swift
//  Invisible
//
//  Created by thomas on 6/21/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  private func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(email)
  }
  
}

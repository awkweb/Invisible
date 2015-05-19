//
//  SettingsViewController.swift
//  Invisible
//
//  Created by thomas on 5/11/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController {
  
  // MARK: - UI Elements
  @IBOutlet weak var tableView: UITableView!
  
  var baseArray: [[SettingsModel]] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Settings"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Message", style: .Plain, target: self, action: "goToMessageVC:")

    tableView.dataSource = self
    tableView.delegate = self
    
    // Set up tableView items
    let settingsA0 = SettingsModel(title: "Username", detail: PFUser.currentUser()!.username!, disclosureIndicator: false)
    let settingsA1 = SettingsModel(title: "Email", detail: PFUser.currentUser()!.email!, disclosureIndicator: true)
    let settingsA2 = SettingsModel(title: "Password", detail: nil, disclosureIndicator: true)
    
    let settingsB0 = SettingsModel(title: "Support", detail: nil, disclosureIndicator: true)
    let settingsB1 = SettingsModel(title: "Log Out", detail: nil, disclosureIndicator: true)
    
    var settingsAArray = [settingsA0, settingsA1, settingsA2]
    var settingsBArray = [settingsB0, settingsB1]
    
    baseArray += [settingsAArray, settingsBArray]
  }
  
  func goToMessageVC(button: UIBarButtonItem) {
    pageController.goToNextVC()
  }
  
  private func logOut() {
    PFUser.logOutInBackgroundWithBlock {
      error in
      
      if error != nil {
        println("Log out error")
      } else {
        println("Log out success!")
        let logInViewController = kStoryboard.instantiateViewControllerWithIdentifier("LogInViewController") as! LogInViewController
        self.presentViewController(logInViewController, animated: true, completion: nil)
      }
    }
  }
  
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return baseArray.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let thisCell = baseArray[indexPath.section][indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as! UITableViewCell
    
    cell.textLabel!.text = thisCell.title
    
    if thisCell.detail != nil {
      cell.detailTextLabel!.text = thisCell.detail
    } else {
      cell.detailTextLabel!.text = ""
    }
    
    if thisCell.disclosureIndicator {
      cell.accessoryType = .DisclosureIndicator
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return baseArray[section].count
  }
  
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let thisCell = baseArray[indexPath.section][indexPath.row]
    
    if thisCell.title == "Log Out" {
      logOut()
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

  }
}

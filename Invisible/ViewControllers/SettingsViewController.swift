//
//  SettingsViewController.swift
//  Invisible
//
//  Created by thomas on 6/21/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  let settingsA0 = SettingsModel(title: "Log Out", detail: nil, disclosureIndicator: true)
  let settingsB0 = SettingsModel(title: "Support", detail: nil, disclosureIndicator: true)
  let settingsB1 = SettingsModel(title: "Twitter", detail: nil, disclosureIndicator: true)
  let settingsC0 = SettingsModel(title: "Built By", detail: "@thomasmeagher", disclosureIndicator: true)
  let settingsC1 = SettingsModel(title: "Acknowledgements", detail: nil, disclosureIndicator: true)
  let settingsC2 = SettingsModel(title: "Version", detail: kVersion, disclosureIndicator: false)
  var baseArray: [[SettingsModel]] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    let settingsAArray = [settingsA0]
    let settingsBArray = [settingsB0, settingsB1]
    let settingsCArray = [settingsC0, settingsC1, settingsC2]
    baseArray += [settingsAArray, settingsBArray, settingsCArray]
  }
  
  private func logOut() {
    PFUser.logOutInBackgroundWithBlock {
      error in
      if let error = error {
        println("Log out error: \(error)")
      } else {
        let logInViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LogInViewController") as! LogInViewController
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
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return baseArray[section].count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let baseArrayItem = baseArray[indexPath.section][indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier("SettingsTableViewCell") as! SettingsTableViewCell
    cell.titleLabel.text = baseArrayItem.title
    cell.detailLabel.text = baseArrayItem.detail ?? nil
    if baseArrayItem.disclosureIndicator {
      cell.accessoryType = .DisclosureIndicator
    }
    return cell
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 1: return "Get In Touch"
    case 2: return "About"
    default: return nil
    }
  }
  
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let settingsCell = baseArray[indexPath.section][indexPath.row]
    if settingsCell.title == "Log Out" {
      logOut()
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
}

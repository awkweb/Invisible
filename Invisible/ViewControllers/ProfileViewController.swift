//
//  ProfileViewController.swift
//  Invisible
//
//  Created by thomas on 6/21/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  let profile0 = ProfileModel(title: "Display Name", detail: currentUser().displayName, disclosureIndicator: true)
  let profile1 = ProfileModel(title: "Email", detail: PFUser.currentUser()!.email, disclosureIndicator: true)
  let profile2 = ProfileModel(title: "Password", detail: nil, disclosureIndicator: true)
  var baseArray: [ProfileModel] = []
  
  // MARK: View life cycle
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    baseArray += [profile0, profile1, profile2]
    tableView.backgroundColor = UIColor.grayL()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    tableView.registerNib(UINib(nibName: "ProfileTableViewHeaderFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ProfileTableViewHeaderFooterView")
  }
  
}

// MARK: Table view data source

extension ProfileViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return baseArray.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let baseArrayItem = baseArray[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier("ProfileTableViewCell") as! ProfileTableViewCell
    cell.titleLabel.text = baseArrayItem.title
    cell.detailLabel.text = baseArrayItem.detail ?? nil
    if baseArrayItem.disclosureIndicator {
      cell.accessoryType = .DisclosureIndicator
    }
    return cell
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ProfileTableViewHeaderFooterView") as! ProfileTableViewHeaderFooterView
    return headerView
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ProfileTableViewHeaderFooterView") as! ProfileTableViewHeaderFooterView
    return headerView.frame.size.height
  }
    
}

// MARK: Table view data delegaate

extension ProfileViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
}

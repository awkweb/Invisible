//
//  ProfileTableViewHeaderFooterView.swift
//  Invisible
//
//  Created by thomas on 6/25/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

class ProfileTableViewHeaderFooterView: UITableViewHeaderFooterView {
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var profilePictureImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var dateJoinedLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    profilePictureImageView.layer.masksToBounds = true
    profilePictureImageView.layer.cornerRadius = 18.75
    currentUser().getPhoto {
      self.backgroundImageView.image = $0
      self.profilePictureImageView.image = $0
    }
    usernameLabel.text = currentUser().username
    dateJoinedLabel.text = (PFUser.currentUser()!.createdAt)!.formattedAsTimeAgo()
    usernameLabel.textColor = UIColor.whiteColor()
    dateJoinedLabel.textColor = UIColor.whiteColor()
  }
  
}

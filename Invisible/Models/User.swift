//
//  User.swift
//  Invisible
//
//  Created by thomas on 5/23/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import Foundation

struct User {
  let id: String
  let username: String
  let displayName: String
  let contacts: [String]?
  private let pfUser: PFUser
  
  func getPhoto(callback: (UIImage) -> ()) {
    let imageFile = pfUser["picture"] as! PFFile
    
    imageFile.getDataInBackgroundWithBlock {
      data, error in
      if let data = data {
        callback(UIImage(data: data)!)
      }
    }
  }
}

func currentUser() -> User {
  return pfUserToUser(PFUser.currentUser()!)
}

func pfUserToUser(user: PFUser) -> User {
  return User(id: user.objectId!, username: user.username!, displayName: user["displayName"]! as! String, contacts: user["contacts"] as? [String], pfUser: user)
}

func fetchUserFromId(id: String, callback: (User) -> ()) {
  PFUser.query()!
    .getObjectInBackgroundWithId(id) {
      object, error in
      if let pfUser = object as? PFUser {
        callback(pfUserToUser(pfUser))
      }
    }
}

func fetchUserIdFromUsername(username: String, callback: (String?, NSError?) -> ()) {
  PFUser.query()!
  .whereKey("username", equalTo: username)
  .getFirstObjectInBackgroundWithBlock {
    object, error in
    if let pfUser = object as? PFUser {
      callback(pfUser.objectId!, nil)
    } else {
      if let error = error {
        callback(nil, error)
      }
    }
  }
}

func saveUserToContactsForUserId(userId: String, callback: (Bool?, NSError?) -> ()) {
  if userId != currentUser().id && !contains(currentUser().contacts!, userId) {
    let user = currentUser().pfUser
    user["contacts"] = currentUser().contacts! + [userId]
    user.saveInBackgroundWithBlock {
      success, error in
      if success {
        callback(success, nil)
      } else {
        if let error = error {
          callback(nil, error)
        }
      }
    }
  }
}

func deleteUserFromContactsForUserId(userId: String, callback: (Bool?, NSError?) -> ()) {
  let user = currentUser().pfUser
  user["contacts"] = currentUser().contacts!.filter {$0 != userId}
  user.saveInBackgroundWithBlock {
    success, error in
    if success {
      callback(success, nil)
    } else {
      if let error = error {
        callback(nil, error)
      }
    }
  }
}

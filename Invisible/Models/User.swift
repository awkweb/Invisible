//
//  User.swift
//  Invisible
//
//  Created by thomas on 5/23/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import Foundation
import Parse

struct User {
  let id: String
  let username: String
  private let pfUser: PFUser
  
  func getPhoto(callback: (UIImage) -> ()) {
    let imageFile = pfUser.objectForKey("picture") as! PFFile
    
    imageFile.getDataInBackgroundWithBlock({
      data, error in
      if let data = data {
        callback(UIImage(data: data)!)
      }
    })
  }
}

func pfUserToUser(user: PFUser) -> User {
  return User(id: user.objectId!, username: user.username!, pfUser: user)
}

func currentUser() -> User? {
  if let user = PFUser.currentUser() {
    return pfUserToUser(user)
  }
  return nil
}

func fetchUserByUsername(username: String, callback: (User) -> ()) {
  PFUser.query()!
  .whereKey("username", equalTo: username).findObjectsInBackgroundWithBlock({
    object, error in
    
    if let pfUser = object as? [PFUser] {
      let user = pfUserToUser(pfUser[0])
      callback(user)
    }
  })
}

func saveContact(user: User) {
  let contact = PFObject(className: "ContactList")
  contact["byUser"] = PFUser.currentUser()!.objectId!
  contact["toUser"] = user.id
  contact["displayName"] = user.username
  contact.saveInBackgroundWithBlock {
    success, error in
    
    if success {
      println("Contact saved!")
    } else {
      println("Contact not saved!")
    }
  }
}

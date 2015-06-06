//
//  Contact.swift
//  Invisible
//
//  Created by thomas on 5/23/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import Foundation
import Parse

struct Contact {
  let id: String
  let userId: String
  // TODO fetch users here and not in collection view data source
  func getUser(callback: (User) -> ()) {
    fetchUserById(userId) { if let user = $0 as User? {callback(user)} }
  }
}

func saveUserAsContact(user: User, callback: (Bool, NSError?) -> ()) {
  if user.id != currentUser().id {
    let contact = PFObject(className: "ContactList")
    contact["byUser"] = currentUser().id
    contact["toUser"] = user.id
    
    contact.saveInBackgroundWithBlock {
      success, error in
      
      if success {
        callback(success, error)
      }
    }
  }
}

func deleteContact(contactId: String, callback: (Bool, NSError?) -> ()) {
  PFQuery(className: "ContactList")
    .getObjectInBackgroundWithId(contactId) {
      object, error in
      
      if let contact = object as PFObject? {
        contact.deleteInBackgroundWithBlock {
         success, error in
          
          if success {
            callback(success, error)
          }
        }
      }
    }
}

func fetchContacts(callback: ([Contact]) -> ()) {
  PFQuery(className: "ContactList")
    .whereKey("byUser", equalTo: currentUser().id)
    .findObjectsInBackgroundWithBlock {
      objects, error in
      
      if let contacts = objects as? [PFObject] {
        let contactUsers = contacts.map {
          (object) -> (contactId: String, userId: String) in
          (object.objectId!, object["toUser"] as! String)
        }
        let userIds = contactUsers.map {Contact(id: $0.contactId, userId: $0.userId)}
        callback(userIds)
      }
    }
}

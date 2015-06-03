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
  
  func getUser(callback: (User) -> ()) {
    fetchUserById(userId, {
      user in
      
      if let user = user as User? {
        callback(user)
      }
    })
  }
}

func saveUserAsContact(user: User, callback: (Bool) -> ()) {
  if user.id != currentUser().id {
    let contact = PFObject(className: "ContactList")
    contact["byUser"] = currentUser().id
    contact["toUser"] = user.id
    
    contact.saveInBackgroundWithBlock {
      success, error in
      
      if success {
        callback(success)
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

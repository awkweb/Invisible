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
  let user: User
  let position: Int
}

private func fetchLastContactPosition(callback: (Int) -> ()) {
  PFQuery(className: "ContactList")
    .whereKey("byUser", equalTo: PFUser.currentUser()!.objectId!)
    .orderByDescending("position")
    .getFirstObjectInBackgroundWithBlock({
      object, error in
      
      if let contact = object as PFObject! {
        let position = contact["position"] as! Int
        callback(position)
      } else {
        callback(-1)
      }
    })
}

func saveUserAsContact(user: User, callback: (Bool) -> ()) {
  let contact = PFObject(className: "ContactList")
  contact["byUser"] = PFUser.currentUser()!.objectId!
  contact["toUser"] = user.id
  fetchLastContactPosition({
    position in
    let nextPosition = position + 1
    contact["position"] = nextPosition
    
    contact.saveInBackgroundWithBlock {
      success, error in
      
      if success {
        callback(success)
      }
    }
  })
}

func fetchContacts(callback: ([Contact]) -> ()) {
  PFQuery(className: "ContactList")
    .whereKey("byUser", equalTo: PFUser.currentUser()!.objectId!)
    .findObjectsInBackgroundWithBlock({
      objects, error in
      
      if let contacts = objects as? [PFObject] {
        let contactUsers = contacts.map({
          (object)->(contactId: String, userId: String, position: Int) in
          (object.objectId!, object["toUser"] as! String, object["position"] as! Int)
        })
        let userIds = contactUsers.map {$0.userId}
        
        PFUser.query()!
          .whereKey("objectId", containedIn: userIds)
          .findObjectsInBackgroundWithBlock({
            objects, error in
            
            if let users = objects as? [PFUser] {
              var c: [Contact] = []
              
              for user in users {
                for cUser in contactUsers {
                  if cUser.userId == user.objectId! {
                    let contact = Contact(id: cUser.contactId, user: pfUserToUser(user), position: cUser.position)
                    
                    if contact.position > c.count {
                      c.append(contact)
                    } else {
                      c.insert(contact, atIndex: contact.position)
                    }
                  }
                }
              }
              callback(c)
            }
          })
      }
    })
}

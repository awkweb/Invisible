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
}

func fetchContacts(callback: ([User] -> ())) {
  PFQuery(className: "ContactList")
    .whereKey("byUser", equalTo: PFUser.currentUser()!.objectId!)
    .findObjectsInBackgroundWithBlock({
      objects, error in
      
      let contacts = map(objects!, {$0.objectForKey("toUser")!})
      
      PFUser.query()!
        .whereKey("objectId", containedIn: contacts)
        .findObjectsInBackgroundWithBlock({
          objects, error in
          
          if let pfUsers = objects as? [PFUser] {
            let users = map(pfUsers, {pfUserToUser($0)})
            callback(users)
          }
        })
    })
}

func fetchMatches(callBack: ([Contact]) -> ()) {
  PFQuery(className: "ContactList")
    .whereKey("byUser", equalTo: PFUser.currentUser()!.objectId!)
    .findObjectsInBackgroundWithBlock({
      objects, error in
      
      if let contacts = objects as? [PFObject] {
        let contactUsers = contacts.map({
          (object)->(contactID: String, userID: String) in
          (object.objectId!, object.objectForKey("toUser") as! String)
        })
        let userIDs = contactUsers.map({$0.userID})
        
        PFUser.query()!
          .whereKey("objectId", containedIn: userIDs)
          .findObjectsInBackgroundWithBlock({
            objects, error in
            
            if let users = objects as? [PFUser] {
              var c: [Contact] = []
              for (index, user) in enumerate(users) {
                c.append(Contact(id: contactUsers[index].contactID, user: pfUserToUser(user)))
              }
              callBack(c)
            }
          })
      }
    })
}

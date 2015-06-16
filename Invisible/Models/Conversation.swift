//
//  Conversation.swift
//  Invisible
//
//  Created by thomas on 6/13/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import Foundation

struct Conversation {
  let id: String
  let senderId: String
  let messageText: String
  let messageTime: NSDate
  let participantIds: [String]
}

func fetchConversationFromId(id: String, callback: (Conversation?, NSError?) -> ()) {
  PFQuery(className: "Conversation")
    .getObjectInBackgroundWithId(id) {
      object, error in
      if let conversation = object as PFObject! {
        callback(Conversation(id: conversation.objectId!, senderId: conversation["senderId"] as! String, messageText: conversation["messageText"] as! String, messageTime: conversation["messageTime"] as! NSDate, participantIds: conversation["participantIds"] as! [String]), nil)
      } else {
        if let error = error {
          callback(nil, error)
        }
      }
  }
}

func fetchConversationForParticipantIds(participantIds: [String], callback: (Conversation?, NSError?) -> ()) {
  PFQuery(className: "Conversation")
    .whereKey("participantIds", containsAllObjectsInArray: participantIds)
    .findObjectsInBackgroundWithBlock {
      objects, error in
      if let conversations = objects as? [PFObject] {
        if !conversations.isEmpty {
          for c in conversations {
            if c["participantIds"]!.count == participantIds.count {
              callback(Conversation(id: c.objectId!, senderId: c["senderId"] as! String, messageText: c["messageText"] as! String, messageTime: c["messageTime"] as! NSDate, participantIds: c["participantIds"] as! [String]), nil)
              break
            } else {
              callback(nil, nil)
            }
          }
        } else {
          callback(nil, nil)
        }
      } else {
        if let error = error {
          callback(nil, error)
        }
      }
  }
}

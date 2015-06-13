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
  let messageTime: String
  let participantIds: [String]
}

func fetchConversationForParticipantIds(senderId: String, recipientIds: [String], callback: (Conversation, NSError?) -> ()) {
  var participantIds = recipientIds + [senderId]
  
  PFQuery(className: "Conversation")
    .whereKey("participantIds", containsAllObjectsInArray: participantIds)
    .getFirstObjectInBackgroundWithBlock {
      object, error in
      if let conversation = object {
        callback(Conversation(id: conversation.objectId!, senderId: conversation["senderId"] as! String, messageText: conversation["messageText"] as! String, messageTime: conversation["messageTime"] as! String, participantIds: conversation["participantIds"] as! [String]), error)
      }
  }
}

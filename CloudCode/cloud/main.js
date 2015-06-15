// CloudCode

Parse.Cloud.define("sendMessage", function(request, response) {
  var conversationId = request.params.conversation_id;
  var senderId = request.params.sender_id;
  var senderName = request.params.sender_name;
  var messageText = request.params.message_text;
  var messageTime = request.params.date_time;
  var recipientIds = request.params.recipient_ids;

  if (conversationId != "nil") {
    updateConversationForConversationId(conversationId, senderId, messageText, messageTime);
  } else {
    var participantIds = recipientIds.slice();
    participantIds.push(senderId);
    createConversation(senderId, participantIds, messageText, messageTime);
  }

  // Send push notification to query
  Parse.Push.send({
    where: findUsersFromRecipientIds(recipientIds),
    data: {
      alert: senderName + ": " + messageText,
      badge: "Increment",
      sound: "ringring.wav",
      conversationId: conversationId
    }
  }, {
    success: function() {
      response.success("CloudCode push sent.");
    },
    error: function(error) {
      response.error(error);
    }
  });
});

// Helpers

function updateConversationForConversationId(conversationId, senderId, messageText, messageTime) {
  var Conversation = Parse.Object.extend("Conversation");
  var query = new Parse.Query(Conversation);
  query.get(conversationId, {
    success: function(conversation) {
      conversation.set("senderId", senderId);
      conversation.set("messageText", messageText);
      conversation.set("messageTime", messageTime);
      conversation.save();
    },
    error: function(object, error) {
      // The object was not retrieved successfully.
      // error is a Parse.Error with an error code and message.
    }
  });
}

function createConversation(senderId, participantIds, messageText, messageTime) {
  var Conversation = Parse.Object.extend("Conversation");
  var conversation = new Conversation();

  conversation.set("senderId", senderId);
  conversation.set("messageText", messageText);
  conversation.set("messageTime", messageTime);
  conversation.set("participantIds", participantIds);
  conversation.save();
}

function findUsersFromRecipientIds(recipientIds) {
  // Find users from recipient ids
  var userQuery = new Parse.Query(Parse.User);
  userQuery.containedIn("objectId", recipientIds);

   // Find devices associated with these users
  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.matchesQuery("user", userQuery);

  return pushQuery
}

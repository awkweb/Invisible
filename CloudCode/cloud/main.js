// CloudCode

Parse.Cloud.define("sendMessage", function(request, response) {
  var conversationId = request.params.conversation_id;
  var senderId = request.params.sender_id;
  var senderName = request.params.sender_name;
  var messageText = request.params.message_text;
  var messageTime = request.params.date_time;
  var recipientIds = request.params.recipient_ids;

  if (conversationId != "empty") {
    var Conversation = Parse.Object.extend("Conversation");
    var query = new Parse.Query(Conversation);
    query.get(conversationId, {
      success: function(conversation) {
        conversation.set("senderId", senderId);
        conversation.set("messageText", messageText);
        conversation.set("messageTime", messageTime);
        conversation.save();

        sendPushToRecipients(recipientIds, senderName, messageText, conversationId);
        response.success(true);
      },
      error: function(object, error) {
        response.error("updateConversationForConversationId error: " + error);
      }
    });
  } else {
    var participantIds = recipientIds.slice();
    participantIds.push(senderId);

    var Conversation = Parse.Object.extend("Conversation");
    var conversation = new Conversation();

    conversation.save({
      senderId: senderId,
      messageText: messageText,
      messageTime: messageTime,
      participantIds: participantIds
    }, {
      success: function(conversation) {
        sendPushToRecipients(recipientIds, senderName, messageText, conversation.id);
        response.success("Cloud Code sendMessage completed! conversationId: " + conversation.id);
      },
      error: function(conversation, error) {
        response.error("createConversation error: " + error);
      }
    });
    
  }
});

// Helpers

function findUsersFromRecipientIds(recipientIds) {
  // Find users from recipient ids
  var userQuery = new Parse.Query(Parse.User);
  userQuery.containedIn("objectId", recipientIds);

   // Find devices associated with these users
  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.matchesQuery("user", userQuery);

  return pushQuery
}

function sendPushToRecipients(recipientIds, senderName, messageText, conversationId) {
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
      console.log("Cloud Code push sent to conversationId: " + conversationId);
    },
    error: function(error) {
      console.error("Send push error: " + error);
    }
  });
}

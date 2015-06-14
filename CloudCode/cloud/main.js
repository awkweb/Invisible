// CloudCode

Parse.Cloud.define("sendMessage", function(request, response) {
  var senderId = request.params.sender_id
  var senderName = request.params.sender_name
  var recipientIds = request.params.recipient_ids
  var messageText = request.params.message_text
  var messageTime = request.params.date_time

  // Fetch conversation for participant ids

  // Send push notification to query
  Parse.Push.send({
    where: findUsersFromRecipientIds(recipientIds),
    data: {
      alert: senderName + ": " + messageText,
      badge: "Increment",
      sound: "ringring.wav"
    }
  }, {
    success: function() {
      response.success("Cloud Code push sent.");
    },
    error: function(error) {
      response.error(error);
    }
  });
});

// Helpers

// Create conversation
// Update conversation

function findUsersFromRecipientIds(recipientIds) {
  // Find users from recipient ids
  var userQuery = new Parse.Query(Parse.User);
  userQuery.containedIn("objectId", recipientIds);

   // Find devices associated with these users
  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.matchesQuery("user", userQuery);

  return pushQuery
}

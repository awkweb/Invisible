// Send push notification
Parse.Cloud.define("sendPush", function(request, response) {
  var to = request.params.to
  var from = request.params.from
  var time = request.params.date_time
  var message = request.params.message
  var senderId = request.params.senderId

  // Find users from input array
  var userQuery = new Parse.Query(Parse.User);
  userQuery.containedIn("objectId", to);

  // Find devices associated with these users
  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.matchesQuery("user", userQuery);

  // Send push notification to query
  Parse.Push.send({
    where: pushQuery,
    data: {
      alert: from + ": " + message,
      badge: "Increment",
      sound: "default",
      sender: senderId,
      date_time: time
    }
  }, {
    success: function() {
      response.success("Cloud Code push worked!");
    },
    error: function(error) {
      response.error(error);
    }
  });
});







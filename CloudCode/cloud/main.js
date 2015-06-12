// Send push notification
Parse.Cloud.define("sendPush", function(request, response) {
  var to = request.params.to
  var from = request.params.from
  var message = request.params.message

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
      sound: "ringring.wav",
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







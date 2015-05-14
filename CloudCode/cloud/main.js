// Send push notification
Parse.Cloud.define("sendPush", function(request, response) {
  // Find users near a given location
  var userQuery = new Parse.Query(Parse.User);
  userQuery.equalTo("username", request.params.toUser);

  // Find devices associated with these users
  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.matchesQuery('user', userQuery);

  // Send push notification to query
  Parse.Push.send({
    where: pushQuery,
    data: {
      alert: request.params.message,
      badge: "Increment" 
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
angular.module("doubtfire.errors.states.timeout", [])

#
# Define the timeout state
#
.config((headerServiceProvider) ->
  stateData =
    url: "/timeout?dest&params"
    views:
      main:
        controller: "TimeoutCtrl"
        templateUrl: "errors/states/timeout/timeout.tpl.html"
    data:
      pageTitle: "_Timeout_"
  headerServiceProvider.state "timeout", stateData, 'ErrorHeaderCtrl'
)
.controller("TimeoutCtrl", ($scope, $timeout, dfApiUrl, auth, redirectService, currentUser) ->
  doRedirect = () ->
    redirectService.redirect "home", {}

  if auth.isAuthenticated()
    auth.signOut dfApiUrl + "/auth/" + currentUser.authenticationToken + ".json"
    $timeout doRedirect, 2000
)

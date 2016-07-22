angular.module("doubtfire.sessions.states.sign-out", [])

#
# State for sign out
#
.config(($stateProvider) ->
  signOutStateData =
    url: "/sign_out"
    views:
      main:
        controller: "SignOutCtrl"
        templateUrl: "sessions/states/sign-out/sign-out.tpl.html"
    data:
      pageTitle: "_Sign Out_"
  $stateProvider.state "sign_out", signOutStateData
)
.controller("SignOutCtrl", ($state, $timeout, auth, dfApiUrl, currentUser) ->
  if auth.signOut dfApiUrl + "/auth/" + currentUser.authenticationToken + ".json"
    $timeout (-> $state.go "sign_in"), 750
  return this
)

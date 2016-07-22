angular.module("doubtfire.api.models.user", [])

.factory("User", (resourcePlus, currentUser, dfApiUrl) ->
  User = resourcePlus "/users/:id", { id: "@id" }
  User.csvUrl = ->
    "#{dfApiUrl}/csv/users?auth_token=#{currentUser.authenticationToken}"
  return User
)

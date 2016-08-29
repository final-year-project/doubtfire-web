angular.module("doubtfire.api.models.helpdesk-stats", [])
#
# API endpoint for getting helpdesk stats
#
.factory("HelpdeskStats", ($http, $rootScope, $interval, api) ->
  HelpdeskStats = {}

  #
  # Gets the helpdesk statistics from the time specified by `from` to the
  # time specified by `to`.
  #
  # If to is null, statistics will fetch to now.
  # If from is null, all statistics from the start of time are returned.
  #
  HelpdeskStats.get = (from, to, callback) ->
    onSuccess = (response) -> callback(null, response.data)
    onFailure = (response) -> callback(response)
    config =
      params:
        from: from
        to: to
    $http.get("#{api}/helpdesk/stats", config).then(onSuccess, onFailure)

  HelpdeskStats
)

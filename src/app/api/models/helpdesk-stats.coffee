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

  # Internal poll interval
  HelpdeskStats._pollInterval = null

  #
  # Returns true if the stats are already being polled
  #
  HelpdeskStats.isPolling = ->
    HelpdeskStats._pollInterval isnt null

  #
  # Begins polling for stats. Default poll time is 30 seconds (measured in ms).
  # WARNING: You must explicitly stop polling when you no longer need it
  # by calling stopPolling.
  #
  HelpdeskStats.startPolling = (interval = 30000) ->
    return if HelpdeskStats.isPolling()
    pollFunction = ->
      from = moment().subtract(interval, 'seconds').format()
      to   = moment().format()
      getCallback = (error, response) ->
        $rootScope.$broadcast 'HelpdeskStatsUpdated', { error: error, data: response }
      HelpdeskStats.get(from, to, getCallback)
    # Call poll at least once to start now
    pollFunction()
    HelpdeskStats._pollInterval = $interval pollFunction, interval

  #
  # Stops helpdesk statistics from polling
  #
  HelpdeskStats.stopPolling = ->
    return unless HelpdeskStats.isPolling()
    $interval.cancel(HelpdeskStats._pollInterval)
    HelpdeskStats._pollInterval = null

  HelpdeskStats
)

#
# The programming helpdesk dashboard
#
angular.module('doubtfire.helpdesk.states.dashboard', [])
.config((headerServiceProvider) ->
  helpdeskDashboardState =
    url: "/helpdesk"
    views:
      main:
        controller: "HelpdeskDashboardCtrl"
        templateUrl: "helpdesk/states/dashboard/dashboard.tpl.html"
    data:
      pageTitle: "_Programming Helpdesk_"
      roleWhitelist: ['Student', 'Tutor', 'Convenor', 'Admin']
  headerServiceProvider.state 'helpdesk', helpdeskDashboardState
)
.controller("HelpdeskDashboardCtrl", ($scope, $rootScope, $interval, $state, HelpdeskStats, HelpdeskTicket, HelpdeskSession) ->
  # Internal poll interval
  pollInterval = null

  #
  # Returns true if the stats are already being polled
  #
  isPolling = -> pollInterval isnt null

  # Keep track of new stats|staff|tickets in these variable
  $scope.data =
    stats: []
    tickets: []
    staff: []

  #
  # This function is called when tickets have been updated
  #
  ticketsUpdated = (error, tickets) ->
    # TODO: Handle error
    $scope.data.tickets = tickets

  #
  # This function is called when stats have been updated
  #
  statsUpdated = (error, stats) ->
    # TODO: Handle error
    $scope.data.stats.push stats

  #
  # This function is called when staff have been updated
  #
  staffUpdated = (error, staff) ->
    # TODO: Handle error
    $scope.data.staff = staff

  #
  # Begins polling for stats. Default poll time is 30 seconds (measured in ms).
  #
  startPolling = (interval = 30000) ->
    return if isPolling()
    pollForStats = ->
      from = moment().subtract(interval, 'seconds').format()
      to   = moment().format()
      HelpdeskStats.get from, to, (error, response) ->
        $scope.lastUpdated = moment()
        statsUpdated(error, response)
    pollForTickets = ->
      HelpdeskTicket.getUnresolvedTickets null, (error, response) ->
        $scope.lastUpdated = moment()
        ticketsUpdated(error, response)
    pollForStaff = ->
      HelpdeskSession.tutorsWorkingNow (error, response) ->
        $scope.lastUpdated = moment()
        staffUpdated(error, response)
    pollFunction = ->
      pollForTickets()
      pollForStaff()
      pollForStats()
    # Call poll at least once to start now
    pollFunction()
    _pollInterval = $interval pollFunction, interval

  #
  # Stops helpdesk statistics from polling
  #
  stopPolling = ->
    return unless HelpdeskStats.isPolling()
    $interval.cancel(HelpdeskStats._pollInterval)
    HelpdeskStats._pollInterval = null

  # When we load, start polling
  startPolling(1000)
  # When we unload, stop polling
  $scope.$on '$destroy', stopPolling
)

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
.controller("HelpdeskDashboardCtrl", ($scope, $rootScope, $interval, $state, HelpdeskStats, HelpdeskTicket, HelpdeskSession, HelpdeskSessionModal) ->
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
    tutorsWorking: []

  #
  # This function is called when tickets have been updated
  #
  ticketsUpdated = (error, tickets) ->
    # Only update what we need to
    resolvedTickets   = _.differenceBy($scope.data.tickets, tickets, 'id')
    newTickets        = _.differenceBy(tickets, $scope.data.tickets, 'id')
    # Remove resolved tickets + merge new tickets
    $scope.data.tickets =
      _.chain($scope.data.tickets)
      .filter((t) -> !_.find(resolvedTickets, { id: t.id })?)
      .concat(newTickets)
      .map((ticket, idx) ->
        # Add ticket's position
        ticket.position = idx + 1
        ticket
      )
      .value()

  #
  # This function is called when stats have been updated
  #
  statsUpdated = (error, stats) ->
    # TODO: Handle error
    $scope.data.stats.push stats
    avgWaitTime = $scope.avgWaitTime = Math.round stats.tickets.average_wait_time
    numUnresolved = $scope.numUnresolved = stats.tickets.number_unresolved
    # TODO: Work out the right values
    $scope.averageWaitTimeColor =
      if 3 <= avgWaitTime < 6
        'primary'
      else if 6 <= avgWaitTime < 9
        'warning'
      else if avgWaitTime >= 9
        'danger'
    $scope.numberUnresolvedColor =
      if 3 <= numUnresolved < 6
        'primary'
      else if 6 <= numUnresolved < 9
        'warning'
      else if numUnresolved > 9
        'danger'


  #
  # This function is called when staff have been updated
  #
  tutorsUpdated = (error, sessions) ->
    # Same concept as ticketsUpdated
    sessionsFinished = _.differenceBy($scope.data.tutorsWorking, sessions, 'id')
    sessionsStarted  = _.differenceBy(sessions, $scope.data.tutorsWorking, 'id')
    $scope.data.tutorsWorking =
      _.chain($scope.data.tutorsWorking)
      .filter((s) -> !_.find(sessionsFinished, { id: s.id })?)
      .concat(sessionsStarted)
      .map((s) ->
        finishIn = s.timeUntilFinish()
        s.minuteDisplay = Math.round(finishIn.minutes() + (finishIn.seconds() * 0.01))
        s.hourDisplay = finishIn.hours()
        if s.minuteDisplay == 60
          s.minuteDisplay = 0
          s.hourDisplay += 1
        s.showHour = s.hourDisplay > 0
        s
      )
      .value()
    $scope.helpdeskClosed = $scope.data.tutorsWorking.length is 0
    $scope.helpdeskOpen = not $scope.helpdeskClosed

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
    pollForTutors = ->
      HelpdeskSession.tutorsWorkingNow (error, response) ->
        $scope.lastUpdated = moment()
        tutorsUpdated(error, response)
    pollFunction = ->
      pollForTickets()
      pollForTutors()
      pollForStats()
    # Call poll at least once to start now
    pollFunction()
    pollInterval = $interval pollFunction, interval

  #
  # Stops helpdesk statistics from polling
  #
  stopPolling = ->
    return unless isPolling()
    $interval.cancel(pollInterval)
    pollInterval = null


  #
  # Opens the session modal
  #
  $scope.openHelpdeskSessionModal = HelpdeskSessionModal.show

  # When we load, start polling
  startPolling(1000)
  # When we unload, stop polling
  $scope.$on '$destroy', stopPolling
)

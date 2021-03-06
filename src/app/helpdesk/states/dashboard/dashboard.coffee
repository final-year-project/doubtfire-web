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
.controller("HelpdeskDashboardCtrl", ($scope, $timeout, $rootScope, $interval, $state, HelpdeskStats, HelpdeskTicket, HelpdeskSession, HelpdeskSessionModal) ->
  # Internal poll interval
  pollInterval = null
  # How long the duration is between each poll, in seconds
  intervalDuration = 30

  #
  # Returns true if the stats are already being polled
  #
  isPolling = -> pollInterval isnt null

  # Keep track of new stats|staff|tickets in these variable
  $scope.data =
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
    statusColours = {'Quiet': 'primary', 'Available': 'warning', 'BUSY': 'danger'}
    statusEmojis = {'Quiet': '😃', 'Available': '😊', 'BUSY': '😱'}
    statsTimes = _.keys(stats)
    lastRecord = stats[_.last(statsTimes)]
    avgWaitTime   = $scope.avgWaitTime   = lastRecord.average_wait_time_in_mins
    numUnresolved = $scope.numUnresolved = lastRecord.number_of_unresolved_tickets
    # TODO: Work out the right values
    $scope.averageWaitTimeStatus =
      if avgWaitTime < 6
        'Quiet'
      else if 6 <= avgWaitTime < 9
        'Available'
      else if avgWaitTime > 9
        'BUSY'
    numberUnresolvedStatus =
      if numUnresolved < 6
        'Quiet'
      else if 6 <= numUnresolved < 9
        'Available'
      else if numUnresolved > 9
        'BUSY'
    $scope.averageWaitTimeEmoji = statusEmojis[$scope.averageWaitTimeStatus]
    $scope.averageWaitTimeColor = statusColours[$scope.averageWaitTimeStatus]
    $scope.numberUnresolvedColor = statusColours[numberUnresolvedStatus]
    # Angular nvd3 accepts milliseconds not seconds for unix time
    $scope.graphData = stats

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
  # If clock on event, refresh immediately
  #
  $rootScope.$on 'CurrentWorkingSession', (event, session) ->
    $scope.pollNow()

  #
  # Begins polling for stats
  #
  startPolling = (interval = intervalDuration) ->
    return if isPolling()
    pollForStats = ->
      # We know if it's the first poll if we are not polling yet!
      isFirstInterval = not isPolling()
      # First poll we want to get the last hour's worth
      subtractValue = if isFirstInterval then 1 * 60 * 60 else interval
      useInterval   = if isFirstInterval then null else interval
      from = moment().subtract(subtractValue, 'seconds').format()
      to   = moment().format()
      HelpdeskStats.get from, to, useInterval, (error, response) ->
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
    $scope.pollNow = ->
      pollFunction()
    # Call poll at least once to start now
    $scope.pollNow()
    pollInterval = $interval pollFunction, interval * 1000 # milliseconds

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

  # When we load, start polling at intervalDuration seconds
  startPolling(intervalDuration)
  # When we unload, stop polling
  $scope.$on '$destroy', stopPolling
)

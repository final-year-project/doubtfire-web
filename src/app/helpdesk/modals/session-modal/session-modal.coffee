#
# The helpdesk session modal is the modal by which staff can clock on and clock
# off from the helpdesk
#
angular.module('doubtfire.helpdesk.modals.session-modal', [])

.factory('HelpdeskSessionModal', ($modal) ->
  HelpdeskSessionModal = {}

  #
  # Pass in the user, project
  #
  HelpdeskSessionModal.show = (session) ->
    $modal.open
      templateUrl: 'helpdesk/modals/session-modal/session-modal.tpl.html'
      controller: 'HelpdeskSessionModal'
      resolve:
        session: -> session

  HelpdeskSessionModal
)

.controller('HelpdeskSessionModal', ($scope, $state, $rootScope, $interval, $modalInstance, HelpdeskSession, ConfirmationModal, alertService, currentUser, session) ->
  $scope.clockOffState = session? # I can clock off if I was given a session
  $scope.clockOnState = !session? # I can clock on if I wasn't given a session

  # Strip the profile
  $scope.currentUser = currentUser.profile

  # Duration to clock on
  $scope.duration = { hours: null }

  #
  # Updates the automatic clock off time
  #
  updateAutomaticClockOffTime = (newDuration) ->
    return unless newDuration?
    $scope.automaticClockOffTime =
      moment().add($scope.duration.hours, 'hours')

  # Watch duration to calculate the automaticClockOffTime
  $scope.$watch 'duration.hours', updateAutomaticClockOffTime

  # If we have a session, work out the automatic clock off time
  if $scope.clockOffState
    $scope.automaticClockOffTime = moment(session.clock_off_time)
    updateTimeLeft = ->
      $scope.timeLeft = moment.duration($scope.automaticClockOffTime.diff())
    updateTimeLeft()
    updateTimeLeftInterval = $interval updateTimeLeft, 1000
    # Must explicitly destroy the time interval when the controller ends!
    $scope.$on '$destroy', ->
      $interval.cancel(updateTimeLeftInterval)

  #
  # Clocks on the session
  #
  $scope.clockOn = ->
    clockOnCallback = (error, success) ->
      if success
        $modalInstance.close(success)
        $rootScope.$broadcast('CurrentWorkingSession', success)
        alertService.add("success", "Clocked on successfully.", 2000)
      if error
        alertService.add("danger", "Error: #{error.data.error}", 6000)
    HelpdeskSession.clockOn(currentUser.id, $scope.duration.hours, clockOnCallback)

  #
  # Clocks off the session
  #
  $scope.clockOff = ->
    clockOffCallback = (error, success) ->
      if success
        $modalInstance.close(success)
        $rootScope.$broadcast('CurrentWorkingSession', null)
        alertService.add("success", "You have been clocked off.", 2000)
      if error
        alertService.add("danger", "Error: #{error.data.error}", 6000)
    ConfirmationModal.show 'Clock off now', "You still have #{session.timeUntilFinish().humanize()} left to work. Are you sure you want to clock off prematurely?", ->
      session.clockOff(clockOffCallback)
)

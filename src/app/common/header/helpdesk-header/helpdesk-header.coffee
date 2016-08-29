#
# Directive for controlling helpdesk dropdown
#
angular.module('doubtfire.common.header.helpdesk-header', [])
.directive 'helpdeskHeader', ->
  restrict: 'E'
  replace: true
  scope:
    projects: '='
    unitRoles: '='
  templateUrl: 'common/header/helpdesk-header/helpdesk-header.tpl.html'
  controller: ($scope, $rootScope, currentUser, HelpdeskTicketModal, HelpdeskSessionModal, HelpdeskTicket, HelpdeskSession) ->
    #
    # This function updates the visibility of the element
    #
    updateVisibility = ->
      # These variables help us know if the user teaches or studies a unit
      $scope.studiesUnit = $scope.projects?.length > 0
      $scope.teachesUnit = $scope.unitRoles?.length > 0
      # Only show the helpdesk dropown if I'm learning or teaching a unit
      $scope.showHelpdeskDropdown = $scope.studiesUnit or $scope.teachesUnit
      # Check if the user has a ticket|session open to switch which modals they can open
      if $scope.studiesUnit
        HelpdeskTicket.currentOpenTicket $scope.currentUser.id, (error, data) ->
          $scope.currentOpenTicket = data
      if $scope.teachesUnit
        HelpdeskSession.currentWorkingSession $scope.currentUser.id, (error, data) ->
          $scope.currentWorkingSession = data


    #
    # Watch for changes in projects and unitRoles length's and update the
    # visibility in case they change
    #
    $scope.$watch('projects.length', updateVisibility)
    $scope.$watch('unitRoles.length', updateVisibility)

    # Current user binding
    $scope.currentUser = currentUser.profile

    # Watch the root scope for changes to the current ticket|session and set if needed
    $rootScope.$on 'CurrentOpenTicket', (event, ticket) ->
      $scope.currentOpenTicket = ticket
    $rootScope.$on 'CurrentWorkingSession', (event, session) ->
      $scope.currentWorkingSession = session

    #
    # Opens the submit ticket modal
    #
    $scope.openHelpdeskTicketModal = ->
      HelpdeskTicketModal.show $scope.currentOpenTicket

    #
    # Opens the session modal
    #
    $scope.openHelpdeskSessionModal = ->
      HelpdeskSessionModal.show $scope.currentWorkingSession

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
  controller: ($scope, currentUser, HelpdeskSubmitTicketModal) ->
    #
    # This function updates the visibility of the element
    #
    updateVisibility = ->
      # These variables help us know if the user teaches or studies a unit
      $scope.studiesUnit = $scope.projects.length > 0
      $scope.teachesUnit = $scope.unitRoles.length > 0
      # Only show the helpdesk dropown if I'm learning or teaching a unit
      $scope.showHelpdeskDropdown = $scope.studiesUnit or $scope.teachesUnit

    #
    # Watch for changes in projects and unitRoles length's and update the
    # visibility in case they change
    #
    $scope.$watch('projects.length', updateVisibility)
    $scope.$watch('unitRoles.length', updateVisibility)

    # Current user binding
    $scope.currentUser = currentUser.profile

    #
    # Opens the submit ticket modal
    #
    $scope.openHelpdeskSubmitTicket = ->
      HelpdeskSubmitTicketModal.show $scope.currentUser, $scope.projects
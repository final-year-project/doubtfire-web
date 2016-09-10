angular.module('doubtfire.helpdesk.helpdesk-ticket', [])
#
# Directive to display information related to a helpdesk ticket
#
.directive('helpdeskTicket', ->
  restrict: 'E'
  templateUrl: 'helpdesk/helpdesk-ticket/helpdesk-ticket.tpl.html'
  replace: true
  scope:
    ticket: '='
  controller: ($scope, HelpdeskTicket, projectService, unitService, HelpdeskTicketModal) ->

    #
    # Returns warning style for ticket
    #
    $scope.warningStyle = ->
      minsWaiting = -$scope.ticket.lengthOfTimeOpen().asMinutes()
      if minsWaiting < 3
        'success'
      else if 3 > minsWaiting > 6
        'primary'
      else if 6 > minsWaiting > 9
        'warning'
      else if minsWaiting > 9
        'danger'

    #
    # Opens the submit ticket modal
    #
    $scope.openHelpdeskTicketModal = ->
      return if $scope.isLoading
      HelpdeskTicketModal.show $scope.ticket
)

angular.module('doubtfire.helpdesk.helpdesk-ticket', [])
#
# Directive to display information related to a helpdesk ticket
#
.directive('helpdeskTicket', ->
  restrict: 'E'
  templateUrl: 'helpdesk/helpdesk-ticket/helpdesk-ticket.tpl.html'
  replace: true
  scope:
    # Ticket can either be a ticket object or ticket id number
    inputTicket: '=ticket'
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
    # Updates the ticket information shown
    #
    refreshTicket = (ticket) ->
      $scope.isLoading = true
      loadProjectDataFor = (ticket) ->
        # Use the ticket information to find the correct project
        projectService.findProject ticket.project_id, (project) ->
          $scope.project = project
          # Now load the unit associated to that project
          unitService.getUnit project.unit_id, false, false, (unit) ->
            $scope.unit = unit
            # If we have a task definition ID, load that in too
            tasdDefId = $scope.ticket.task_definition_id
            $scope.taskDefinition = unit.taskDef(taskDefId) if taskDefId?
            $scope.isLoading = false
      # Get a ticket ID?
      if _.isNumber ticket
        onSuccess = (response) ->
          $scope.ticket = response
          $scope.isLoading = false
          # loadProjectDataFor($scope.ticket) # Only need if we need even more info...
        onFailure = (response) ->
          # TODO: Have to handle this error...
          $scope.isLoading = false
          $scope.error = response
        HelpdeskTicket.get({id: ticket})
                      .$promise
                      .then(onSuccess, onFailure)
      # Get a ticket object?
      else if _.isObject ticket
        $scope.ticket = ticket
        $scope.isLoading = false
        # loadProjectDataFor(ticket) # Only need if we need even more info...
      else
        throw new Error("Not a ticket object or ticket ID")

    # Load the ticket data
    refreshTicket($scope.inputTicket)

    # Watch changes to ticket id
    $scope.$watch 'ticket.id', (newTicketId, oldTicketId) ->
      return unless newTicketId? or (newTicketId? and newTicketId is oldTicketId)
      refreshTicket(newTicketId)

    #
    # Opens the submit ticket modal
    #
    $scope.openHelpdeskTicketModal = ->
      return if $scope.isLoading
      HelpdeskTicketModal.show $scope.ticket
)

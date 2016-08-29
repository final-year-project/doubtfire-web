#
# The helpdesk ticket modal is the modal by which students can submit
# new tickets to or review their ticket information
#
angular.module('doubtfire.helpdesk.modals.ticket-modal', [])

.factory('HelpdeskTicketModal', ($modal) ->
  HelpdeskTicketModal = {}

  #
  # Pass in the user, project
  #
  HelpdeskTicketModal.show = (ticket) ->
    $modal.open
      templateUrl: 'helpdesk/modals/ticket-modal/ticket-modal.tpl.html'
      controller: 'HelpdeskTicketModal'
      resolve:
        ticket: -> ticket

  HelpdeskTicketModal
)

.controller('HelpdeskTicketModal', ($scope, $state, $rootScope, $modalInstance, HelpdeskTicket, ConfirmationModal, alertService, unitService, projectService, currentUser, analyticsService, ticket) ->
  $scope.isNew = !ticket?
  $scope.ticket = ticket || new HelpdeskTicket()

  #
  # Callback when a task definition has changed
  #
  $scope.taskDefSelected = (taskDef) ->
    $scope.ticket.taskDef = taskDef

  # Use project service to get projects
  projectService.getProjects (projects) ->
    $scope.projects = projects
    $scope.ticket.project = projects[0] if projects.length == 1
    unless $scope.isNew
      # Use the ticket information to find the correct project
      projectService.findProject $scope.ticket.project_id, (p) ->
        $scope.ticket.project = p

  #
  # Watch when a project is changed to update the selected unit
  #
  $scope.$watch 'ticket.project.project_id', (newId) ->
    return unless newId?
    $scope.taskDefSelected null # reset which task selected
    unitService.getUnit $scope.ticket.project.unit_id, false, false, (response) ->
      $scope.ticket.unit = response
      # If ticket was provided, we need to look up the task def now from the
      # unit loaded if it has one
      if not $scope.isNew and $scope.ticket.task_definition_id?
        taskDef = $scope.ticket.unit.taskDef($scope.ticket.task_definition_id)
        $scope.taskDefSelected taskDef

  #
  # Sends a HTTP request to open a ticket
  #
  $scope.openTicket = ->
    openTicketCallback = (error, success) ->
      if success
        $modalInstance.close(success)
        $rootScope.$broadcast('CurrentOpenTicket', success)
        alertService.add("success", "Ticket created successfully.", 2000)
      if error
        alertService.add("danger", "Error: #{error.data.error}", 6000)
    HelpdeskTicket.submitTicket(
      $scope.ticket.project.project_id,
      $scope.ticket.description,
      $scope.ticket.taskDef.id,
      openTicketCallback
    )

  #
  # Sends a request to resolve the ticket
  #
  $scope.resolveTicket = ->
    # TODO: Resolved by whom?
    resolveTicketCallback = (error, success) ->
      if success
        $modalInstance.close(success)
        $rootScope.$broadcast('CurrentOpenTicket', null)
        alertService.add("success", "Ticket resolved!", 2000)
      if error
        alertService.add("danger", "Error: #{error.data.error}", 6000)
    $scope.ticket.resolve(resolveTicketCallback)

  #
  # Sends a request to close the ticket
  #
  $scope.closeTicket = ->
    closeTicketCallback = (error, success) ->
      if success
        $modalInstance.close(success)
        $rootScope.$broadcast('CurrentOpenTicket', null)
        alertService.add("success", "Ticket closed.", 2000)
      if error
        alertService.add("danger", "Error: #{error.data.error}", 6000)
    ConfirmationModal.show 'Close Ticket', 'Are you sure you want to close the ticket without resolving the issue?', ->
      $scope.ticket.close(closeTicketCallback)

  #
  # Goes to the selected task
  #
  $scope.goToSelectedTask = $modalInstance.dismiss
)

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
  $scope.ticket = ticket

  #
  # Callback when a task definition has changed
  #
  $scope.taskDefSelected = (taskDef) ->
    $scope.selectedTaskDef = taskDef

  # Use project service to get projects
  projectService.getProjects (projects) ->
    $scope.projects = projects
    if $scope.isNew
      # Set the initial project to their first project for convenience
      $scope.selectedProject = $scope.projects[0]
    else
      # Use the ticket information to find the correct project
      projectService.findProject $scope.ticket.project_id, (p) ->
        $scope.selectedProject = p

  #
  # Watch when a project is changed to update the selected unit
  #
  $scope.$watch 'selectedProject.id', ->
    unitService.getUnit $scope.selectedProject.unit_id, false, false, (response) ->
      $scope.selectedUnit = response
      # If ticket was provided, we need to look up the task def now from the
      # unit loaded if it has one
      if not $scope.isNew and $scope.ticket.task_definition_id?
        taskDef = $scope.selectedUnit.taskDef($scope.ticket.task_definition_id)
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
      $scope.selectedProject.project_id,
      $scope.description,
      $scope.selectedTaskDef?.id,
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

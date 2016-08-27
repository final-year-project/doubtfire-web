#
# The helpdesk submit ticket modal is the modal by which students can submit
# new tickets to
#
angular.module('doubtfire.helpdesk.modals.helpdesk-submit-ticket-modal', [])

.factory('HelpdeskSubmitTicketModal', ($modal) ->
  HelpdeskSubmitTicketModal = {}

  HelpdeskSubmitTicketModal.show = (user, projects) ->
    $modal.open
      templateUrl: 'helpdesk/modals/helpdesk-submit-ticket-modal/helpdesk-submit-ticket-modal.tpl.html'
      controller: 'HelpdeskSubmitTicketModal'
      resolve:
        user: -> user
        projects: -> projects

  HelpdeskSubmitTicketModal
)

.controller('HelpdeskSubmitTicketModal', ($scope, $modalInstance, alertService, analyticsService, currentUser, User, user, unitService, projects, HelpdeskTicket, auth) ->
  $scope.currentUser = currentUser
  $scope.projects = projects

  # Set the initial project to their first project for convenience
  $scope.selectedProject = $scope.projects[0]

  #
  # Watch when a project is changed to update the selected unit
  #
  $scope.$watch 'selectedProject.id', ->
    unitService.getUnit $scope.selectedProject.unit_id, false, false, (response) ->
      $scope.selectedUnit = response

  #
  # Callback when a task definition has changed
  #
  $scope.taskDefSelected = (taskDef) ->
    $scope.selectedTaskDef = taskDef

  #
  # Sends a HTTP request to open a ticket
  #
  $scope.openTicket = ->
    openTicketCallback = (error, success) ->
      if success
        $modalInstance.close(success)
        alertService.add("success", "Ticket created successfully.", 2000)
      if error
        alertService.add("danger", "Error: #{error.data.error}", 6000)
    HelpdeskTicket.submitTicket(
      $scope.selectedProject.project_id,
      $scope.description,
      $scope.selectedTaskDef?.id,
      openTicketCallback
    )
)

angular.module('doubtfire.helpdesk.modals.helpdesk-submit-ticket-modal', [])

.factory('HelpDeskSubmitTicketModal', ($modal) ->
  HelpDeskSubmitTicketModal = {}

  HelpDeskSubmitTicketModal.show = (user, projects) ->
    $modal.open
      templateUrl: 'helpdesk/modals/helpdesk-submit-ticket-modal/helpdesk-submit-ticket-modal.tpl.html'
      controller: 'HelpDeskSubmitTicketModal'
      resolve:
        user: -> user
        projects: -> projects

  HelpDeskSubmitTicketModal
)

.controller('HelpDeskSubmitTicketModal', ($scope, $modalInstance, alertService, analyticsService, currentUser, User, user, unitService, projects, HelpDeskTicket, auth) ->
  $scope.currentUser = currentUser
  $scope.projects = projects
  $scope.selectedProject = $scope.projects[0]
  $scope.unitSelected = (project) ->
    $scope.selectedProject = project
  $scope.getUnit = (unitId) ->
    unitService.getUnit unitId, false, false, (response) ->
      $scope.loadedUnit = response
  $scope.getUnit($scope.selectedProject.unit_id)
  $scope.onSelectDefinition = (taskDef) ->
    $scope.selectedTaskDef = taskDef

  openNewTicket = ->
    dataToPost =
      project_id: $scope.selectedProject.project_id
      description: $scope.description
      task_definition_id: $scope.selectedTaskDef?.id
    HelpDeskTicket.create(dataToPost).$promise.then (
      (response) ->
        $modalInstance.close(response)
        alertService.add("success", "Ticket created successfully.", 2000)
    ),
    (
      (response) ->
        if response.data.error?
          alertService.add("danger", "Error: " + response.data.error, 6000)
    )

  $scope.openTicket = ->
    openNewTicket()
)

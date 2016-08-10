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

.controller('HelpDeskSubmitTicketModal', ($scope, $modalInstance, alertService, analyticsService, currentUser, User, user, projects, auth) ->
  $scope.currentUser = currentUser
  $scope.projects = projects

  $scope.modalState = {}
)

angular.module('doubtfire.helpdesk.modals.helpdesk-submit-ticket-modal', [])

.factory('HelpDeskSubmitTicketModal', ($modal) ->
  HelpDeskSubmitTicketModal = {}

  HelpDeskSubmitTicketModal.show = (user) ->
    $modal.open
      templateUrl: 'helpdesk/modals/helpdesk-submit-ticket-modal/helpdesk-submit-ticket-modal.tpl.html'
      controller: 'HelpDeskSubmitTicketModal'
      resolve:
        user: -> user

  HelpDeskSubmitTicketModal
)

.controller('HelpDeskSubmitTicketModal', ($scope, $modalInstance, alertService, analyticsService, currentUser, User, user, auth) ->
  $scope.currentUser = currentUser

  $scope.modalState = {}
)

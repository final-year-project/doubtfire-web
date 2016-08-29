#
# The programming helpdesk dashboard
#
angular.module('doubtfire.helpdesk.states.dashboard', [])
.config((headerServiceProvider) ->
  helpdeskDashboardState =
    url: "/helpdesk"
    views:
      main:
        controller: "HelpdeskDashboardCtrl"
        templateUrl: "helpdesk/states/dashboard/dashboard.tpl.html"
    data:
      pageTitle: "_Programming Helpdesk_"
      roleWhitelist: ['Student', 'Tutor', 'Convenor', 'Admin']
  headerServiceProvider.state 'helpdesk', helpdeskDashboardState
)
.controller("HelpdeskDashboardCtrl", ($scope, $state) ->

)

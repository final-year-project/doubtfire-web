angular.module("doubtfire.api.models.task-completion-csv", [])

.service("TaskCompletionCsv", (dfApiUrl, $window, currentUser) ->
  this.downloadFile = (unit) ->
    $window.open "#{dfApiUrl}/csv/units/#{unit.id}/task_completion.json?auth_token=#{currentUser.authenticationToken}", "_blank"

  return this
)

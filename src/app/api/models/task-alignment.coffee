angular.module("doubtfire.api.models.task-alignment", [])

.factory("TaskAlignment", (resourcePlus, dfApiUrl, currentUser, $window) ->
  TaskAlignment = {}
  TaskAlignment.taskAlignmentCSVUploadUrl = (unit, project_id) ->
    if project_id?
      "#{dfApiUrl}/units/#{unit.id}/learning_alignments/csv.json?project_id=#{project_id}&auth_token=#{currentUser.authenticationToken}"
    else
      "#{dfApiUrl}/units/#{unit.id}/learning_alignments/csv.json?auth_token=#{currentUser.authenticationToken}"

  TaskAlignment.downloadCSV = (unit, project_id) ->
    if project_id?
      $window.open "#{dfApiUrl}/units/#{unit.id}/learning_alignments/csv.json?project_id=#{project_id}&auth_token=#{currentUser.authenticationToken}", "_blank"
    else
      $window.open "#{dfApiUrl}/units/#{unit.id}/learning_alignments/csv.json?auth_token=#{currentUser.authenticationToken}", "_blank"
  return TaskAlignment
)

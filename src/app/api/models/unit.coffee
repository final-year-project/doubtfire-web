angular.module("doubtfire.api.models.unit", [])

.factory("Unit", (resourcePlus, currentUser, $window, dfApiUrl) ->
  Unit = resourcePlus "/units/:id", { id: "@id" }
  Unit.getGradesUrl = (unit) ->
    "#{dfApiUrl}/units/#{unit?.id}/grades?auth_token=#{currentUser.authenticationToken}"
  Unit.getPortfoliosUrl = (unit) ->
    "#{dfApiUrl}/submission/unit/#{unit?.id}/portfolio?auth_token=#{currentUser.authenticationToken}"
  Unit.taskUploadUrl = (unit) ->
    "#{dfApiUrl}/units/#{unit.id}/task_definitions/task_pdfs?auth_token=#{currentUser.authenticationToken}"
  Unit.taskSheetUploadUrl = (unit, taskDefinition) ->
    "#{dfApiUrl}/units/#{unit.id}/task_definitions/#{taskDefinition.id}/task_sheet?auth_token=#{currentUser.authenticationToken}"
  Unit.taskResourcesUploadUrl = (unit, taskDefinition) ->
    "#{dfApiUrl}/units/#{unit.id}/task_definitions/#{taskDefinition.id}/task_resources?auth_token=#{currentUser.authenticationToken}"
  Unit.allResourcesDownloadUrl = (unit) ->
    "#{dfApiUrl}/units/#{unit.id}/all_resources?auth_token=#{currentUser.authenticationToken}"
  Unit.enrolStudentsCSVUrl = (unit) ->
    "#{dfApiUrl}/csv/units/#{unit.id}?auth_token=#{currentUser.authenticationToken}"
  Unit.withdrawStudentsCSVUrl = (unit) ->
    "#{dfApiUrl}/csv/units/#{unit.id}/withdraw?auth_token=#{currentUser.authenticationToken}"

  Unit.learningProgressClassStats = resourcePlus "/units/:id/learning_alignments/class_stats", { id: "@id" }
  Unit.learningProgressClassDetails = resourcePlus "/units/:id/learning_alignments/class_details", {id: "@id"}

  Unit.tasksRequiringFeedback = resourcePlus "/units/:id/feedback", { id: "@id" }
  Unit.tasksForDefinition = resourcePlus "/units/:id/task_definitions/:task_def_id/tasks", {id: "@id", task_def_id: "@task_def_id"}
  Unit.taskStatusCountByTutorial = resourcePlus "/units/:id/stats/task_status_pct", {id: "@id"}
  Unit.targetGradeStats = resourcePlus "/units/:id/stats/student_target_grade", {id: "@id"}
  Unit.taskCompletionStats = resourcePlus "/units/:id/stats/task_completion_stats", {id: "@id"}

  Unit
)

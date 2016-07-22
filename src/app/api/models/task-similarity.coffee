angular.module("doubtfire.api.models.task-similarity", [])

.factory("TaskSimilarity", ($http, dfApiUrl, currentUser) ->
  get: (task, match, callback) ->
    url = "#{dfApiUrl}/tasks/#{task.id}/similarity/#{match}"
    $http.get(url).success ( data ) ->
      callback(data)
)

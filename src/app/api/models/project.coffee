angular.module("doubtfire.api.models.project", [])

.factory("Project", (resourcePlus, Task) ->
  projectApi = resourcePlus "/projects/:id", { id: "@id" }, {
    # on Project.get
    get: {
      # intercept all responses
      interceptor: {
        # modify the response object
        response: (response) ->
          project = response.resource
          # apply the Task prototype to each task in project's resource
          _.forEach project.tasks, Task.applyPrototype
          project
      }
    }
  }

  projectApi
)
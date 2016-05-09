angular.module("doubtfire.common.services.projects", [])

#
# Service for handling projects
#
.factory("projectService", ($filter, taskService, Project, $rootScope, alertService, Task) ->
  projectService = {}

  projectService.loadedProjects = null

  projectService.taskStatIndex = {
    fail: 0,
    not_started: 1,
    do_not_resubmit: 2,
    redo: 3,
    need_help: 4,
    working_on_it: 5,
    fix_and_resubmit: 6,
    ready_to_mark: 7,
    discuss: 8,
    demonstrate: 9,
    complete: 10
  }

  $rootScope.$on 'signOut', () ->
    projectService.loadedProjects = null

  projectService.getProjects = ( callback ) ->
    if ! projectService.loadedProjects?
      projectService.loadedProjects = []
      Project.query(
        (projects) ->
          Array.prototype.push.apply projectService.loadedProjects, projects
        (response) ->
          if response?.status != 419
            msg = if ! response? then response.error else ''
            alertService.add("danger", "Failed to connect to Doubtfire server. #{msg}", 6000)
        )


    if _.isFunction(callback)
      callback(projectService.loadedProjects)

    projectService.loadedProjects

  ###
  projects's can update their task stats
  converts the | delimited stats to its component arrays
  @param  student [Student|Project] The student's stats to update
  ###
  projectService.updateTaskStats = (project, newStatsStr) ->
    project.updateTaskStats(newStatsStr)

  projectService.mapTask = ( task, unit, project ) ->
    td = unit.taskDef(task.task_definition_id)

    # Lookup and return the existing projTask task object
    projTask = project.findTaskForDefinition(td.id)
    if projTask?
      _.extend projTask, task
      if projTask.definition?
        return projTask
      else
        # Augment the existing project task
        task = projTask

    # Add in the related definition object
    task.definition = td

    # must be function to avoid cyclic structure
    task.project = () -> project
    task.status_txt = () -> taskService.statusLabels[task.status]
    task.statusSeq = () -> taskService.statusSeq[task.status]
    task.updateTaskStatus = (project, new_stats) ->
      projectService.updateTaskStats(project, new_stats)
    task.needsSubmissionDetails = () ->
      task.has_pdf == null || task.has_pdf == undefined
    task.getSubmissionDetails = ( success, failure ) ->
      if ! task.needsSubmissionDetails()
        if _.isFunction(success) then success(task, {} )
      else
        Task.SubmissionDetails.get { id: project.project_id, task_definition_id: task.definition.id },
          (response) ->
            task.has_pdf = response.has_pdf
            task.processing_pdf = response.processing_pdf
            if _.isFunction(success) then success(task, response)
          (response) ->
            if _.isFunction(failure) then failure(task, response)
    task

  projectService.addTaskDetailsToProject = (project, unit) ->
    project.linkTaskDetails(unit)
    
  projectService.addProjectMethods = (project, unit) ->
    project.updateBurndownChart = () ->
      Project.get { id: project.project_id }, (response) ->
        project.burndown_chart_data = response.burndown_chart_data

    project.incorporateTask = (newTask) ->
      if ! project.tasks?
        project.tasks = []

      currentTask = _.find project.tasks, (t) -> t.task_definition_id == newTask.task_definition_id

      if currentTask?
        currentTask = _.extend currentTask, newTask
      else
        project.tasks.push projectService.mapTask(newTask, unit, project)
        currentTask = newTask

      currentTask

    project.refresh = (unit_obj) ->
      Project.get { id: project.project_id }, (response) ->
        _.extend project, response
        if unit_obj
          projectService.addTaskDetailsToProject(project, unit_obj)

  projectService.fetchDetailsForProject = (project, unit, callback) ->
    if project.burndown_chart_data?
      callback(project)
    else
      Project.get { id: project.project_id }, (project_response) ->
        _.extend project, project_response

        projectService.addProjectMethods(project, unit)

        if unit
          projectService.addTaskDetailsToProject(project, unit)
        callback(project)

  projectService.updateGroups = (project) ->
    if project.groups?
      Project.get { id: project.project_id }, (response) ->
        project.groups = response.groups

  projectService.getGroupForTask = (project, task) ->
    return null if not task.definition.group_set

    _.find project.groups, (grp) -> grp.group_set_id == task.definition.group_set.id

  projectService.taskFromTaskDefId = (project, task_definition_id) ->
    project.findTaskForDefinition(task_definition_id)

  projectService.tasksInTargetGrade = (project) ->
    $filter('byGrade')(project.tasks, project.target_grade)

  projectService.tasksByStatus = (project, statusKey) ->
    tasksToConsider = projectService.tasksInTargetGrade(project)
    _.filter(tasksToConsider, {status: statusKey})

  projectService
)

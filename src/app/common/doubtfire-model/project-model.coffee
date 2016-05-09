angular.module("doubtfire.common.doubtfire-model.project-model", [])

#
# Service for handling projects
#
.factory("ProjectModel", ($filter, taskService, Project, $rootScope, alertService, Task, projectService) ->
  prototypeFor = (project) ->
    open: false

    # projects can find tasks using their task definition ids
    findTaskForDefinition: (taskDefId) ->
      _.find project.tasks, (task) -> task.task_definition_id == taskDefId

    unit: () -> project._unit

    switchToLab: (tutorial) ->
      if tutorial
        newId = tutorial.id
      else
        newId = -1

      analyticsService.event 'Teacher View - Students Tab', 'Changed Student Tutorial'
      Project.update({ id: project.project_id, tutorial_id: newId },
        (project) ->
          project.tutorial_id = project.tutorial_id
          project.tutorial = project.unit().tutorialFromId( project.tutorial_id )
        (response) ->
          alertService.add "danger", "Failed to change tutorial. #{response?.data?.error}", 8000
      )

    #TODO: change these to use functions...
    name: () -> project.first_name + " " + project.last_name

    portfolio_status: () ->
      if project.has_portfolio
        1
      else if project.compile_portfolio
        0.5
      else
        0

    activeTasks: () ->
      _.filter project.tasks, (task) -> task.definition.target_grade <= project.target_grade

    tutorial: () -> project.unit().tutorialFromId( project.tutorial_id )

    tutorName: () ->
      if project.tutorial()?
        project.tutorial().tutor_name
      else
        ''

    # initialise taskStats with values and types(task status key)
    taskStats: [
      { value: 0, type: _.trim(_.dasherize(taskService.statusKeys[10]))}
      { value: 0, type: _.trim(_.dasherize(taskService.statusKeys[0]))}
      { value: 0, type: _.trim(_.dasherize(taskService.statusKeys[1]))}
      { value: 0, type: _.trim(_.dasherize(taskService.statusKeys[2]))}
      { value: 0, type: _.trim(_.dasherize(taskService.statusKeys[3]))}
      { value: 0, type: _.trim(_.dasherize(taskService.statusKeys[4]))}
      { value: 0, type: _.trim(_.dasherize(taskService.statusKeys[5]))}
      { value: 0, type: _.trim(_.dasherize(taskService.statusKeys[6]))}
      { value: 0, type: _.trim(_.dasherize(taskService.statusKeys[7]))}
      { value: 0, type: _.trim(_.dasherize(taskService.statusKeys[8]))}
      { value: 0, type: _.trim(_.dasherize(taskService.statusKeys[9]))}
    ]

    taskStatValue: (key) ->
      project.taskStats[projectService.taskStatIndex[key]].value

    progressSortOrder: () ->
      20 * project.taskStatValue('complete') +
      15 * (project.taskStatValue('discuss') + project.taskStatValue('demonstrate')) +
      10 * (project.taskStatValue('ready_to_mark')) +
      5 * (project.taskStatValue('fix_and_resubmit')) +
      2 * (project.taskStatValue('working_on_it')) +
      1 * (project.taskStatValue('need_help'))

    portfolioUrl: () ->
      PortfolioSubmission.getPortfolioUrl(student)

    assignGrade: (score, rationale) ->
      Project.update { id: project.project_id, grade: score, old_grade:project.grade, grade_rationale: rationale },
        (project) ->
          project.grade = project.grade
          project.grade_rationale = project.grade_rationale
          alertService.add("success", "Grade updated.", 2000)
        (response) ->
          alertService.add("danger", "Grade was not updated: #{response.data.error}", 8000)

    # Update the task stats for project project (on init, or task status change)
    updateTaskStats: (newStatsStr) ->
      for i, value of newStatsStr.split("|")
        if i < project.taskStats.length
          project.taskStats[i].value = Math.round(100 * value)
        else
          break

    # Link the tasks in the project with their definitions from the unit
    linkTaskDetails: (unit) ->
      if (! project.tasks?) || project.tasks.length < unit.task_definitions.length

        # Create base structure for a Task -- one per definition
        # As project only has Tasks with changed status
        base = unit.task_definitions.map (td) -> {
          id: null
          status: "not_started"
          task_definition_id: td.id
          include_in_portfolio: true
          pct_similar: 0
          similar_to_count: 0
          times_assessed: 0
          # pdf details are loaded from Task.SubmissionDetails
          # processing_pdf: null
          # has_pdf: null
        }

        # Remove all of the tasks that already exist in the project
        base = _.filter base, (task) ->
          ! _.find(project.tasks, (pt) ->
            pt.task_definition_id == task.task_definition_id)

        project.tasks = [] unless project.tasks?
        Array.prototype.push.apply project.tasks, base

      project.tasks = project.tasks.map (task) ->
        projectService.mapTask task, unit, project

      project.tasks = _.sortBy(project.tasks, (t) -> t.definition.abbreviation).reverse()
      project

    # Constructor...
    init: (unit) ->
      project.updateTaskStats(project.stats)
      if unit?
        project.linkTaskDetails(unit)
      #TODO: else
      # get unit... from project unit id then call link... (async)
      project

  ProjectModel =
    applyPrototype: (project, unit) ->
      _.extend project, prototypeFor(project)
      project.init(unit)

  ProjectModel
)
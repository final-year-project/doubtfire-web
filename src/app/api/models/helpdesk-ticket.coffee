angular.module("doubtfire.api.models.helpdesk-ticket", [])
#
# API endpoint for serving helpdesk tickets
#
.factory("HelpdeskTicket", (resourcePlus) ->
  HelpdeskTicket = resourcePlus "/helpdesk/tickets/", { id: "@id" }

  #
  # Submits a new helpdesk ticket. Provide a project ID, description and task
  # def id. Project ID is required, whereas the others can be `null`. Callback
  # is a function whose first parameter is error and second parameter is success
  # data.
  #
  HelpdeskTicket.submitTicket = (projectId, description, taskDefinitionId, callback) ->
    dataToPost =
      project_id: projectId
      description: description
      task_definition_id: taskDefinitionId
    onSuccess = (response) -> callback(null, response)
    onFailure = (response) -> callback(response)
    HelpdeskTicket.create(dataToPost)
                  .$promise
                  .then(onSuccess, onFailure)

  #
  # Gets all tickets by a specific state, optionally for the specified user id.
  # If user is not specified, then all tickets will be returned.
  #
  HelpdeskTicket.getTickets = (state, userId, callback) ->
    onSuccess = (response) -> callback(null, response)
    onFailure = (response) -> callback(response)
    HelpdeskTicket.get({ user_id: user, filter: state })
                  .$promise
                  .then(onSuccess, onFailure)

  #
  # Gets all unresolved tickets (optionally by user)
  #
  HelpdeskTicket.getUnresolvedTickets = (userId, callback) ->
    HelpdeskTicket.getTickets('unresolved', userId, callback)

  #
  # Gets all resolved tickets (optionally by user)
  #
  HelpdeskTicket.getResolvedTickets = (userId, callback) ->
    HelpdeskTicket.getTickets('resolved', userId, callback)

  #
  # Gets all closed tickets (optionally by user)
  #
  HelpdeskTicket.getClosedTickets = (userId, callback) ->
    HelpdeskTicket.getTickets('closed', userId, callback)

  #
  # Closes a specified ticket with the given ID
  #
  HelpdeskTicket.closeTicket = (ticketId, callback) ->
    onSuccess = (response) -> callback(null, response)
    onFailure = (response) -> callback(response)
    HelpdeskTicket.delete({ id: ticketId })
                  .$promise
                  .then(onSuccess, onFailure)

  #
  # Prototype close ticket method
  #
  HelpdeskTicket.prototype.close = (callback) ->
    HelpdeskTicket.closeTicket(this.id, callback)

  #
  # Resolves a specified ticket with the given ID
  #
  HelpdeskTicket.resolveTicket = (ticketId, callback) ->
    onSuccess = (response) -> callback(null, response)
    onFailure = (response) -> callback(response)
    HelpdeskTicket.delete({ id: ticketId, resolve: true })
                  .$promise
                  .then(onSuccess, onFailure)

  #
  # Prototype resolve ticket method
  #
  HelpdeskTicket.prototype.resolve = (callback) ->
    HelpdeskTicket.resolveTicket(this.id, callback)

  #
  # Returns the duration since the ticket was open
  #
  HelpdeskTicket.prototype.lengthOfTimeOpen = ->
    now = moment()
    createdTime = moment(this.created_at)
    moment.duration(createdTime.diff(now)).humanize()

  HelpdeskTicket
)

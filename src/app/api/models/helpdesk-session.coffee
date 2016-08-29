angular.module("doubtfire.api.models.helpdesk-session", [])
#
# API endpoint for helpdesk sessions of staff working
#
.factory("HelpdeskSession", (resourcePlus) ->
  HelpdeskSession = resourcePlus "/helpdesk/sessions/:id", { id: "@id" }

  #
  # Clocks on a user for the specified duration (in hours) given. Durations
  # must be specified in decimal format. E.g., 1h 15m == 1.25 hrs
  #
  HelpdeskSession.clockOn = (userId, duration, callback) ->
    clockOffTime = moment().add(duration, 'hours').format()
    dataToPost =
      clock_off_time: clockOffTime
      user_id: userId
    onSuccess = (response) -> callback(null, response)
    onFailure = (response) -> callback(response)
    HelpdeskSession.create(dataToPost).$promise.then(onSuccess, onFailure)

  #
  # Gets the active working session of a specific userId at the helpdesk
  #
  HelpdeskSession.getActiveSessions = (userId, callback) ->
    onSuccess = (response) -> callback(null, response)
    onFailure = (response) -> callback(response)
    HelpdeskSession.query({ user_id: userId, is_active: true }).$promise.then(onSuccess, onFailure)

  #
  # Gets the list of all tutors currently working
  #
  HelpdeskSession.tutorsWorkingNow = (callback) ->
    onSuccess = (response) -> callback(null, response)
    onFailure = (response) -> callback(response)
    HelpdeskSession.query({ id: 'tutors' }).$promise.then(onSuccess, onFailure)

  #
  # Prematurely clocks off a session before it's default expiry time
  #
  HelpdeskSession.clockOffSession = (sessionId, callback) ->
    onSuccess = (response) -> callback(null, response)
    onFailure = (response) -> callback(response)
    HelpdeskSession.delete({ id: sessionId }).$promise.then(onSuccess, onFailure)

  #
  # Clocks off this session prematurely
  #
  HelpdeskSession.prototype.clockOff = (callback) ->
    HelpdeskSession.clockOffSession(this.id, callback)

  #
  # Returns the duration until the session expires
  #
  HelpdeskSession.prototype.timeUntilFinish = ->
    clockOffTime = moment(this.clock_off_time)
    moment.duration(clockOffTime.diff()).humanize()

  #
  # Returns the currently working session for the user id provided, or
  # null if no such session exists
  #
  HelpdeskSession.currentWorkingSession = (userId, callback) ->
    HelpdeskSession.getActiveSessions userId, (error, success) ->
      return callback(error) if error
      callback(null, success[0])

  HelpdeskSession
)

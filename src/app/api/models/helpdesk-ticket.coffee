angular.module("doubtfire.api.models.helpdesk-ticket", [])
#
# API endpoint for serving helpdesk tickets
#
.factory("HelpdeskTicket", (resourcePlus) ->
  HelpdeskTicket = resourcePlus "/helpdesk/tickets/", { id: "@id" }

  #
  # Gets all unresolved tickets, optionally for the specified user.
  # If user is not specified, then all unresolved tickets will be
  # returned from all users.
  #
  HelpdeskTicket.getUnresolvedTickets = (user, callback) ->
    HelpdeskTicket.get({ user_id: user }, )

  #
  # Returns the duration since the ticket was open
  #
  HelpdeskTicket.prototype.lengthOfTimeOpen = ->
    this.created_at

  HelpdeskTicket
)

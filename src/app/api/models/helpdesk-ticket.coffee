angular.module("doubtfire.api.models.helpdesk-ticket", [])

.factory("HelpDeskTicket", (resourcePlus) ->
  resourcePlus "/helpdesk/tickets/", {id: "@id"}
)

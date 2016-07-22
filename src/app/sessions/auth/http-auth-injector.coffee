angular.module("doubtfire.sessions.auth.http-auth-injector", [])
#
# This module is responsible for injecting the auth credentials to
# all
#
.config(($httpProvider) ->
  $httpProvider.interceptors.push ($q, $rootScope, dfApiUrl, currentUser) ->
    #
    # Inject authentication token for requests
    #
    injectAuthForRequest = (request) ->
      # Intercept API requests and inject the auth token.
      if _.string.startsWith(request.url, dfApiUrl) and currentUser.authenticationToken?
        request.params = {} unless _.has request, "params"
        request.params.auth_token = currentUser.authenticationToken
      request or $q.when request

    #
    # Inject handlers for 419 and 401 response errors
    #
    injectAuthForResponseWithError = (response) ->
      # Intercept unauthorised API responses and fire an event.
      if response.config && response.config.url and _.string.startsWith(response.config.url, dfApiUrl)
        # Timeout?
        if response.status is 419
          $rootScope.$broadcast "tokenTimeout"
        # Unauthorised?
        else if response.status is 401
          $rootScope.$broadcast "unauthorisedRequestIntercepted"
      $q.reject response

    {
      request: injectAuthForRequest
      responseError: injectAuthForResponseWithError
    }
)

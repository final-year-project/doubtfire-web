angular.module('doubtfire.visualisations.helpdesk-dashboard-timeline', [])
.directive 'helpdeskDashboardTimeline', ->
  replace: true
  restrict: 'E'
  templateUrl: 'visualisations/visualisation.tpl.html'
  scope:
    rawData: '=data'
    height: '=?'
  controller: ($scope, $timeout, taskService, projectService, Visualisation) ->
    updateData = (rawData) ->
      key_to_name =
        average_wait_time_in_mins: 'Average Wait',
        unresolved: 'People In Queue'
      $scope.times = _.map(rawData.unresolved, (v) -> v[0])
      $scope.data = _.map rawData, (values, key) ->
        isBar = key == 'unresolved'
        key = key_to_name[key]
        { key: key, values: _.map(values, (v) -> { x: v[0], y: v[1] }), bar: isBar }
      $timeout ->
        $scope.api.refresh() if $scope.api?.refresh?

    updateData($scope.rawData)

    $scope.$watch 'rawData.unresolved.length', ->
      updateData $scope.rawData

    [$scope.options, $scope.config] = Visualisation 'linePlusBarChart', 'Helpdesk Dashboard Timeline', {
      showLabels: no
      margin:
        top: 30,
        right: 30,
        bottom: 50,
        left: 70
      height: $scope.height
      bars:
        forceY: [0, 20]
      bars2:
        forceY: [0, 20]
      lines:
        forceY: [0, 20]
      lines2:
        forceY: [0, 20]
      color: [
        'darkred',
        '#2ca02c'
      ]
      x: (d, i) -> i
      xAxis:
        axisLabel: 'Time'
        tickFormat: (d) -> moment($scope.times[d]).format('hh:mm a')
      x2Axis:
        showMaxMin: true
        tickFormat: (d) -> moment($scope.times[d]).format('hh:mm a')
      y1Axis:
        axisLabel: 'people waiting'
        tickFormat: (d) -> d
        axisLabelDistance: -12
      y2Axis:
        axisLabel: null
        tickFormat: (d) -> "#{d}m"
      y3Axis:
        tickFormat: (d) -> 'l'
      y4Axis:
        tickFormat: (d) -> 'x'
    }, {}

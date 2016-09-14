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
      # Function to fix time as nvd3 needs a unix time in ms, not s
      correctTime = (t) -> t * 1000
      $scope.times = _.chain(rawData).keys().map(correctTime).value()
      $scope.data = [
        {
          key: 'Average Wait Time',
          bar: false,
          values: _.map rawData, (data, time) ->
            {
              x: correctTime(time),
              y: data.average_wait_time_in_mins
            }
        },
        {
          key: 'People In Queue',
          bar: true,
          values: _.map rawData, (data, time) ->
            {
              x: correctTime(time),
              y: data.number_of_unresolved_tickets
            }
        }
      ]
      # Update forceY to be the max num
      barMax =
        _.chain(rawData)
        .map((data) -> data.number_of_unresolved_tickets)
        .max()
      barMax = if barMax > 10 then barMax else 10
      lineMax =
        _.chain(rawData)
        .map((data) -> data.average_wait_time_in_mins)
        .max()
      lineMax = if lineMax > 10 then lineMax else 10
      $scope.options.chart.bars.forceY =
      $scope.options.chart.bars2.forceY =
        [0, barMax]
      $scope.options.chart.lines.forceY =
      $scope.options.chart.lines2.forceY =
        [0, lineMax]
      $timeout ->
        $scope.api.refresh() if $scope.api?.refresh?

    $scope.$watch (-> _.keys($scope.rawData)[0]), ->
      return unless $scope.rawData?
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
        forceY: [0]
      bars2:
        forceY: [0]
      lines:
        forceY: [0]
      lines2:
        forceY: [0]
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

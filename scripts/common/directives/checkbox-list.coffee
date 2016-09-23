'use strict'

angular.module("app")
  .directive "checkboxList",  () ->
    transclude: true
    restrict: "E"
    scope:
      data: "="
      labelField: "@"
      limit: "@"
      type: "@"
      hasMedia: "@"
    templateUrl: '/templates/common/directives/list.html.tmpl'
    controller: ($scope) ->

      $scope.$watch 'data.list|filter:{checked:true}', (checked) ->
        if $scope.data?
          $scope.data.selected =
            if $scope.limit?
              sorted = _.sortBy(checked, 'updated')
              # unselect the first item
              if sorted.length > $scope.limit
                _.first(sorted).checked = false
              sorted
            else
              checked
      , true

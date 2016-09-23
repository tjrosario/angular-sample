'use strict'

angular.module('app')
.controller('RequestPasswordResetCtrl', [
  '$scope',
  '$stateParams'
  'Customer'
  '$timeout'
  '$state'
  'message'
  ($scope, $stateParams, Customer, $timeout, $state, message) ->
    scrollTo("html, body")

    $scope.onClick = () ->
      $scope.errorMsg = null
      $scope.errorMsg = null

    $scope.requestPasswordReset = (form) ->
      $scope.loading = true
      email = $scope.customer.email.toLowerCase()
      Customer.find({
        email: email
      }).$promise.then (resp) ->
        if resp.success
          Customer.resetPassword({
            id: resp.data.id
          }).$promise.then (resp) ->
            if resp.success
              $scope.errorMsg = null
              $scope.successMsg = true
            else
              $scope.errorMsg = true
              $scope.successMsg = false
            $scope.loading = false

        else
          $scope.errorMsg = true
          $scope.successMsg = false
          $scope.loading = false
      , () ->
        $scope.errorMsg = true
        $scope.successMsg = false
])

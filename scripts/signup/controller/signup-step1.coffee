'use strict'

angular.module('app')
.controller('SignUpStep1Ctrl', [
  '$scope', '$state', '$location', '$stateParams', '$timeout', 'MeasurementSize', 'Heights', 'SignedUpCustomer'
  ($scope, $state, $location, $stateParams, $timeout, MeasurementSize, Heights, SignedUpCustomer) ->
    scrollTo("html, body")

    # heights
    $scope.heights = Heights.list

    # ignored pant lengths
    ignoredPantLengths = []

    # ignored waist sizes
    ignoredWaistSizes = ['28']

    deDuplicate = (list, key) ->
      _.sortBy(
        _.uniq list, (size) -> size[key]
      , (size) ->
        size[key]
      )

    # casual shirt sizes
    getCasualShirtSizes = () ->
      if SignedUpCustomer.casualShirtSize
        $scope.casualShirtSize = SignedUpCustomer.casualShirtSize
        return

      MeasurementSize.find('Generic Shirt Size', 'Casual Shirt').$promise.then (sizes) ->
        $scope.casualShirtSize = SignedUpCustomer.casualShirtSize =
          list : sizes.data.sizes
          selected : []

    # generic waist size
    getGenericWaistSizes = () ->
      if SignedUpCustomer.waistSize
        $scope.waistSize = SignedUpCustomer.waistSize
        return

      MeasurementSize.find('Generic Waist').$promise.then (sizes) ->
        genericWaistSizes = sizes.data.sizes
        _.each genericWaistSizes, (size, i) ->
          _.each ignoredWaistSizes, (ignored) ->
            if size.value is ignored
              delete genericWaistSizes[i]

        $scope.waistSize = SignedUpCustomer.waistSize =
          list : deDuplicate(genericWaistSizes, 'value')
          selected : []

    # generic inseams
    getGenericInseams = () ->
      if SignedUpCustomer.pantLength
        $scope.pantLength = SignedUpCustomer.pantLength
        return

      MeasurementSize.find('Generic Inseam').$promise.then (sizes) ->
        pantLengths = sizes.data.sizes
        _.each pantLengths, (size, i) ->
          _.each ignoredPantLengths, (ignored) ->
            if size.value is ignored
              delete pantLengths[i]

        $scope.pantLength = SignedUpCustomer.pantLength =
          list : deDuplicate(pantLengths, 'value')
          selected : []

    $scope.goToStep2 = () ->
      #$scope.allowed = true
      #$scope.step1 = false
      SignedUpCustomer.customer.statedHeight = $scope.customer.statedHeight
      SignedUpCustomer.customer.statedWeight = $scope.customer.statedWeight

      $state.go('signup.step2')

    getCasualShirtSizes()
    getGenericWaistSizes()
    getGenericInseams()

    SignedUpCustomer.initted = true

    if !SignedUpCustomer.customer
      SignedUpCustomer.customer = {}

    $scope.customer = SignedUpCustomer.customer

])

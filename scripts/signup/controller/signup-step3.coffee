'use strict'

angular.module('app')
.controller('SignUpStep3Ctrl', [
  '$scope', '$state', '$stateParams', '$timeout', 'PriceRange', 'PriceRangeCategories', 'SignedUpCustomer'
  ($scope, $state, $stateParams, $timeout, PriceRange, PriceRangeCategories, SignedUpCustomer) ->
    scrollTo("html, body")

    if !SignedUpCustomer.initted
      $state.go "signup.step1"
      return

    # price range categories
    priceRangeCategories = PriceRangeCategories.list

    topsPriceRanges = []
    bottomsPriceRanges = []

    sortPrices = (prices) ->
      _.sortBy prices, (price) -> price.upperLimit

    priceToText = (price) ->
      if price.lowerLimit <= 0.01 then "$#{price.upperLimit | number:0} and Under"
      else if price.upperLimit > 900 then "$#{price.lowerLimit} and Over"
      else "$#{price.lowerLimit | number:0} - $#{price.upperLimit | number:0}"

    getPriceRanges = () ->
      _.map priceRangeCategories, (cat) ->

        if SignedUpCustomer[cat.scopeName]
          $scope[cat.scopeName] = SignedUpCustomer[cat.scopeName]
          return

        PriceRange.find(cat.name).$promise.then (priceRanges) ->
          $scope[cat.scopeName] = SignedUpCustomer[cat.scopeName] =
            list : sortPrices(
              _.map priceRanges.data.priceRanges, (price) ->
                price.value = priceToText(price)
                price)
            selected : []
          $scope[cat.scopeName].list[0].checked = true

    setPricePreferences = (model, set) ->
      selected = []
      _.each model.selected, (obj) ->
        found = objectFindByKey(model.list, 'id', obj.id)
        selected.push found

      _.each set, (obj) ->
        obj.selected = []
        _.each selected, (sel) ->
          idx = sel[1]
          match = getMatchByIndex(idx, obj.list)
          obj.selected.push match
      return

    setTopsPricePrefs = () ->
      topsPriceRanges = []
      topsPriceRanges.push SignedUpCustomer.sweatshirtPriceRange
      topsPriceRanges.push SignedUpCustomer.tshirtPriceRange
      setPricePreferences(SignedUpCustomer.sweaterPriceRange, topsPriceRanges)

    setBottomsPricePrefs = () ->
      bottomsPriceRanges.push SignedUpCustomer.chinosPriceRange

      setPricePreferences(SignedUpCustomer.jeansPriceRange, bottomsPriceRanges)

    $scope.setPricePrefs = () ->
      setBottomsPricePrefs()
      setTopsPricePrefs()
      $state.go('signup.step4')

    getPriceRanges()

    $scope.customer = SignedUpCustomer.customer
])

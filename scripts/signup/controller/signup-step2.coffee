'use strict'

angular.module('app')
.controller('SignUpStep2Ctrl', [
  '$scope', '$state', '$stateParams', '$timeout', 'CharacteristicAttribute', 'ShirtColorCategories', 'CollarTypeCategories', 'ShirtPatternCategories', 'SignedUpCustomer'
  ($scope, $state, $stateParams, $timeout, CharacteristicAttribute, ShirtColorCategories, CollarTypeCategories, ShirtPatternCategories, SignedUpCustomer) ->
    scrollTo("html, body")

    if !SignedUpCustomer.initted
      $state.go "signup.step1"
      return

    # shirt color categories
    shirtColorCategories = ShirtColorCategories.list

    # collar type categories
    collarTypeCategories = CollarTypeCategories.list

    # shirt Pattern categories
    shirtPatternCategories = ShirtPatternCategories.list

    sortSizes = (sizes) ->
      _.sortBy sizes, (size) -> size.value

    sortFits = (fits) ->
      _.sortBy fits, (fit) ->
        rank =
          Slim: 1
          Regular: 2
          Relaxed: 3

        rank[fit.value]

    sortAlphabetically = (a, b) ->
      return -1  if a.value < b.value
      return 1  if a.value > b.value
      0

    ###
    setSizePrefs = (model, set, conditionVal, setVal) ->
      selected = []
      xProductCat = model.list[0].xProductCategory
      _.each model.selected, (sel) ->
        _.each set.list, (obj) ->
          exists = objectFindByKey(selected, 'id', obj.id)
          if not exists
            if sel.value isnt conditionVal
              if obj.value is sel.value
                selected.push obj
            else
              if (obj.xProductCategory is xProductCat) and (obj.value is conditionVal)
                selected.push obj
              if (obj.xProductCategory isnt xProductCat) and (obj.value is setVal)
                selected.push obj
      set.selected = selected
    ###

    # pant fits
    getGenericPantFits = () ->
      if SignedUpCustomer.genericPantFits and SignedUpCustomer.jeansFit
        $scope.genericPantFits = SignedUpCustomer.genericPantFits
        $scope.jeansFit = SignedUpCustomer.jeansFit
        return

      CharacteristicAttribute.find('Generic Pant Fit').$promise.then (sizes) ->
        $scope.genericPantFits = SignedUpCustomer.genericPantFits =
          list : sortSizes(
            _.map sizes.data.attributes, (size) ->
              size)
          selected : []

        # filter out jeans
        $scope.jeansFit = {}
        $scope.jeansFit.list = []
        $scope.jeansFit.selected = []
        _.each $scope.genericPantFits.list, (fit) ->
          if fit.xProductCategory is 'Jeans'
            $scope.jeansFit.list.push fit

        $scope.jeansFit.list = sortFits($scope.jeansFit.list)

        SignedUpCustomer.jeansFit = $scope.jeansFit

    # generic shirt fits
    getGenericShirtFits = () ->
      if SignedUpCustomer.genericShirtFits and SignedUpCustomer.casualShirtFit
        $scope.genericShirtFits = SignedUpCustomer.genericShirtFits
        $scope.casualShirtFit = SignedUpCustomer.casualShirtFit
        return

      CharacteristicAttribute.find('Generic Shirt Fit').$promise.then (fits) ->
        $scope.genericShirtFits = SignedUpCustomer.genericShirtFits =
          list : fits.data.attributes
          selected : []

        # filter out casual shirts
        $scope.casualShirtFit = {}
        $scope.casualShirtFit.list = []
        $scope.casualShirtFit.selected = []
        _.each $scope.genericShirtFits.list, (fit) ->
          if fit.xProductCategory is 'Casual Shirt'
            $scope.casualShirtFit.list.push fit

        $scope.casualShirtFit.list = sortFits($scope.casualShirtFit.list)

        SignedUpCustomer.casualShirtFit = $scope.casualShirtFit

    # shirt colors
    getAllShirtColors = () ->
      #promises = _.map shirtColorCategories, (cat) ->
      _.map shirtColorCategories, (cat) ->
        #deferred  = $q.defer()

        if SignedUpCustomer[cat.scopeName]
          $scope[cat.scopeName] = SignedUpCustomer[cat.scopeName]
          return

        CharacteristicAttribute.find('Color', cat.name).$promise.then (colors) ->
          catList = _.map colors.data.attributes, (color) ->
            #color.checked = true
            color
          $scope[cat.scopeName] = SignedUpCustomer[cat.scopeName] =
            list: catList.sort(sortAlphabetically)
            #selected: (if (cat.name is "Casual Shirt") then catList else [])
            selected: []

          #deferred.resolve colors

        #deferred.promise
      #$q.all promises

    # shirt patterns
    getAllShirtPatterns = () ->
      #promises = _.map shirtPatternCategories, (cat) ->
      _.map shirtPatternCategories, (cat) ->
        #deferred  = $q.defer()

        if SignedUpCustomer[cat.scopeName]
          $scope[cat.scopeName] = SignedUpCustomer[cat.scopeName]
          return

        CharacteristicAttribute.find('Pattern', cat.name).$promise.then (patterns) ->
          catList = _.map patterns.data.attributes, (pattern) ->
            #pattern.checked = true
            pattern
          $scope[cat.scopeName] = SignedUpCustomer[cat.scopeName] =
            list : catList.sort(sortAlphabetically)
            selected: []
            #selected : catList

          #deferred.resolve patterns
        #deferred.promise
      #$q.all promises

    # collar types
    getAllCollarTypes = () ->
      #promises = _.map collarTypeCategories, (cat) ->
      _.map collarTypeCategories, (cat) ->
        #deferred  = $q.defer()

        if SignedUpCustomer[cat.scopeName]
          $scope[cat.scopeName] = SignedUpCustomer[cat.scopeName]
          return

        CharacteristicAttribute.find('Collar Type', cat.name).$promise.then (types) ->
          catList = _.map types.data.attributes, (val) ->
            val.value = val.value.replace(' Collar', '')
            val
          $scope[cat.scopeName] = SignedUpCustomer[cat.scopeName] =
            list: catList.sort(sortAlphabetically)
            #selected: []
            selected: catList.sort(sortAlphabetically)

          #deferred.resolve types

        #deferred.promise
      #$q.all promises

    setPreferenceMappings = (set, conditionVal, setVal) ->
      foundCondition = _.first(_.where(set.selected, {
        value: conditionVal
      }))

      if foundCondition
        foundSetVals = _.where(set.unselected, {
          value: setVal
        })

        _.each foundSetVals, (obj) ->
          foundSelected = _.where(set.unselected, {
            value: obj.value
          })

          _.each foundSelected, (sel) ->
            set.selected.push sel
            _.each set.unselected, (unsel, i) ->
              if unsel.value is sel.value
                set.unselected.splice(i, 1)

    setSizeDislikePrefs = (model, set) ->
      unselected = []

      _.each set.list, (obj) ->
        _.each model.unselected, (unsel) ->
          if obj.value is unsel.value
            unselected.push obj

        selectedID = objectFindByKey(model.selected, 'id', obj.id)
        selectedValue = objectFindByKey(model.selected, 'value', obj.value)
        exists = objectFindByKey(unselected, 'value', obj.value)

        if !selectedID and !selectedValue and !exists
          unselected.push obj

      set.unselected = unselected
      set.selected = model.selected

    setUnselected = (options, opts) ->
      opts = opts or {}
      opts.mappings = opts.mappings or undefined

      if opts.mappings
        for key of opts.mappings
          if opts.mappings.hasOwnProperty(key)
            found = _.first(_.where(options.selected, {
              value: key
            }))
            if found
              foundMap = _.first(_.where(options.list, {
                value: opts.mappings[key]
              }))
              foundMapSelected = _.first(_.where(options.selected, {
                value: opts.mappings[key]
              }))
              if foundMap and !foundMapSelected
                options.selected.push foundMap

      unselected = []
      _.each options.list, (obj) ->
        found = _.first(_.where(options.selected, {
          id: obj.id
        }))
        if !found
          unselected.push obj

      options.unselected = unselected

    $scope.goToStep1 = () ->
      $scope.step1 = true
      $state.go('signup.step1')

    $scope.setFitandStylePreferences = () ->
      setUnselected SignedUpCustomer.jeansFit,
        mappings:
          Relaxed: "Regular"
      setUnselected(SignedUpCustomer.casualShirtFit)

      setSizeDislikePrefs(SignedUpCustomer.jeansFit, SignedUpCustomer.genericPantFits)
      setSizeDislikePrefs(SignedUpCustomer.casualShirtFit, SignedUpCustomer.genericShirtFits)

      setPreferenceMappings(SignedUpCustomer.genericShirtFits, 'Slim', 'Extra Slim')
      setPreferenceMappings(SignedUpCustomer.genericShirtFits, 'Regular', 'Full')
      $state.go('signup.step3')


    getGenericPantFits()
    getGenericShirtFits()
    getAllShirtColors()
    getAllShirtPatterns()

    $scope.customer = SignedUpCustomer.customer
])

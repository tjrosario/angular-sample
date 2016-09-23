'use strict'

angular.module('app')
.controller('SignUpStep4Ctrl', [
  '$scope', '$state', '$stateParams', '$timeout', 'AcquisitionSources', 'SignedUpCustomer', 'auth', 'Customer', 'ProductPreference', 'StyleDislike', 'PricePreference', 'MeasurementPreference', 'SelectedCategories', '$q', '$location', 'MailChimpLists', 'ezfb', 'angularLoad', 'localStorageService', 'Facebook', 'ShirtColorCategories', 'CollarTypeCategories', 'ShirtPatternCategories'
  ($scope, $state, $stateParams, $timeout, AcquisitionSources, SignedUpCustomer, auth, Customer, ProductPreference, StyleDislike, PricePreference, MeasurementPreference, SelectedCategories, $q, $location, MailChimpLists, ezfb, angularLoad, localStorageService, Facebook, ShirtColorCategories, CollarTypeCategories, ShirtPatternCategories) ->
    scrollTo("html, body")

    if !SignedUpCustomer.initted
      $state.go "signup.step1"
      return

    adWords = App.constants.app.analytics.googleAdWords
    $scope.customer = SignedUpCustomer.customer
    isProduction = App.constants.app.env is 'production'

    signupCampaign = localStorageService.get('signupCampaign')

    if signupCampaign
      $scope.customer.campaign = signupCampaign
    else
      $scope.customer.campaign = null

    $scope.validation =
      errors : []
    sourceIsText = false

    $scope.signupForm = {}

    # shirt color categories
    shirtColorCategories = ShirtColorCategories.list

    # collar type categories
    collarTypeCategories = CollarTypeCategories.list

    # shirt Pattern categories
    shirtPatternCategories = ShirtPatternCategories.list

    # acquisition sources
    $scope.acquisitionSources = AcquisitionSources.list

    # password toggle
    $timeout (->
      new PasswordRevealer($('#customer-password .toggle'), $('#customer-password .password'))
    ), 1000

    getCollarTypePreferences = () ->
      collarTypePreferences = []
      _.each collarTypeCategories, (cat) ->
        if cat.scopeName isnt 'casualShirtCollarType'
          _.each SignedUpCustomer[cat.scopeName].list, (attr) ->
            _.each SignedUpCustomer.casualShirtCollarType.selected, (casualShirtSelectedAttr) ->
              if attr.value is casualShirtSelectedAttr.value
                SignedUpCustomer[cat.scopeName].selected.push attr
                collarTypePreferences.push attr

      _.each SignedUpCustomer.casualShirtCollarType.selected, (casualShirtSelectedAttr) ->
        collarTypePreferences.push casualShirtSelectedAttr

      collarTypePreferences

    getColorPreferences = () ->
      colorPreferences = []
      _.each shirtColorCategories, (cat) ->
        if cat.scopeName isnt 'casualShirtColor'
          _.each SignedUpCustomer[cat.scopeName].list, (attr) ->
            _.each SignedUpCustomer.casualShirtColor.selected, (casualShirtSelectedAttr) ->
              if attr.value is casualShirtSelectedAttr.value
                SignedUpCustomer[cat.scopeName].selected.push attr
                colorPreferences.push attr

      _.each SignedUpCustomer.casualShirtColor.selected, (casualShirtSelectedAttr) ->
        colorPreferences.push casualShirtSelectedAttr

      colorPreferences

    getShirtPatternPreferences = () ->
      shirtPatternPreferences = []
      _.each shirtPatternCategories, (cat) ->
        if cat.scopeName isnt 'casualShirtPattern'
          _.each SignedUpCustomer[cat.scopeName].list, (attr) ->
            _.each SignedUpCustomer.casualShirtPattern.selected, (casualShirtSelectedAttr) ->
              if attr.value is casualShirtSelectedAttr.value
                SignedUpCustomer[cat.scopeName].selected.push attr
                shirtPatternPreferences.push attr

      _.each SignedUpCustomer.casualShirtPattern.selected, (casualShirtSelectedAttr) ->
        shirtPatternPreferences.push casualShirtSelectedAttr

      shirtPatternPreferences

    getCustomerInfo = () ->
      info = $scope.customer
      info.statedHeight = info.statedHeight.replace('"', 'inches')

      info.statedWaist = _.first(SignedUpCustomer.waistSize.selected)?.value
      info.statedInseam = _.first(SignedUpCustomer.pantLength.selected)?.value
      info.statedPantFit = _.first(SignedUpCustomer.jeansFit.selected)?.value
      info.statedShirtSize = _.first(SignedUpCustomer.casualShirtSize.selected)?.value
      info.signUpMethod = 'web-flow'
      info

    onBeforeSave = (customer) ->
      #$scope.loading = true
      $scope.selectedCategories = SelectedCategories
      customer.statedWaist = _.first(SignedUpCustomer.waistSize.selected)?.value
      customer.statedInseam = _.first(SignedUpCustomer.pantLength.selected)?.value
      customer.statedPantFit = _.first(SignedUpCustomer.jeansFit.selected)?.value
      customer.statedShirtSize = _.first(SignedUpCustomer.casualShirtSize.selected)?.value
      customer.signUpMethod = 'web-flow'

    getPrefsFromStorage = (customer) ->
      colorDislikes = JSON.parse localStorageService.get("colorDislikes")
      shirtPatternDislikes = JSON.parse localStorageService.get("shirtPatternDislikes")

      {
        colorDislikes: colorDislikes
        shirtPatternDislikes: shirtPatternDislikes
      }

    setScopesToStorage = () ->
      localStorageService.set("waistSize", JSON.stringify(SignedUpCustomer.waistSize))
      localStorageService.set("pantLength", JSON.stringify(SignedUpCustomer.pantLength))
      localStorageService.set("jeansFit", JSON.stringify(SignedUpCustomer.jeansFit))
      localStorageService.set("casualShirtSize", JSON.stringify(SignedUpCustomer.casualShirtSize))

      localStorageService.set("selectedCategories", JSON.stringify(SelectedCategories))
      #localStorageService.set("casualShirtFit", JSON.stringify(SignedUpCustomer.casualShirtFit))
      localStorageService.set("genericShirtFits", JSON.stringify(SignedUpCustomer.genericShirtFits))
      localStorageService.set("genericPantFits", JSON.stringify(SignedUpCustomer.genericPantFits))

      ###
      localStorageService.set("colorDislikes", JSON.stringify(SignedUpCustomer.colorDislikes))
      localStorageService.set("shirtPatternDislikes", JSON.stringify(SignedUpCustomer.shirtPatternDislikes))
      ###

      localStorageService.set("jeansPriceRange", JSON.stringify(SignedUpCustomer.jeansPriceRange))
      localStorageService.set("shortsPriceRange", JSON.stringify(SignedUpCustomer.shortsPriceRange))
      localStorageService.set("chinosPriceRange", JSON.stringify(SignedUpCustomer.chinosPriceRange))
      localStorageService.set("dressPantsPriceRange", JSON.stringify(SignedUpCustomer.dressPantsPriceRange))
      localStorageService.set("casualShirtPriceRange", JSON.stringify(SignedUpCustomer.casualShirtPriceRange))
      localStorageService.set("golfPoloShirtPriceRange", JSON.stringify(SignedUpCustomer.golfPoloShirtPriceRange))
      localStorageService.set("sweaterPriceRange", JSON.stringify(SignedUpCustomer.sweaterPriceRange))
      localStorageService.set("sweatshirtPriceRange", JSON.stringify(SignedUpCustomer.sweatshirtPriceRange))
      localStorageService.set("tshirtPriceRange", JSON.stringify(SignedUpCustomer.tshirtPriceRange))

    setScopesFromStorage = () ->
      SignedUpCustomer.waistSize = JSON.parse localStorageService.get("waistSize")
      SignedUpCustomer.pantLength = JSON.parse localStorageService.get("pantLength")
      SignedUpCustomer.jeansFit = JSON.parse localStorageService.get("jeansFit")
      SignedUpCustomer.casualShirtSize = JSON.parse localStorageService.get("casualShirtSize")

      SignedUpCustomer.selectedCategories = JSON.parse localStorageService.get("selectedCategories")
      SignedUpCustomer.genericShirtFits = JSON.parse localStorageService.get("genericShirtFits")
      SignedUpCustomer.genericPantFits = JSON.parse localStorageService.get("genericPantFits")
      SignedUpCustomer.colorDislikes = JSON.parse localStorageService.get("colorDislikes")
      SignedUpCustomer.shirtPatternDislikes = JSON.parse localStorageService.get("shirtPatternDislikes")

      SignedUpCustomer.casualShirtFit = JSON.parse localStorageService.get("casualShirtFit")
      SignedUpCustomer.jeansPriceRange = JSON.parse localStorageService.get("jeansPriceRange")
      SignedUpCustomer.shortsPriceRange = JSON.parse localStorageService.get("shortsPriceRange")
      SignedUpCustomer.chinosPriceRange = JSON.parse localStorageService.get("chinosPriceRange")
      SignedUpCustomer.dressPantsPriceRange = JSON.parse localStorageService.get("dressPantsPriceRange")
      SignedUpCustomer.casualShirtPriceRange = JSON.parse localStorageService.get("casualShirtPriceRange")
      SignedUpCustomer.golfPoloShirtPriceRange = JSON.parse localStorageService.get("golfPoloShirtPriceRange")
      SignedUpCustomer.sweaterPriceRange = JSON.parse localStorageService.get("sweaterPriceRange")
      SignedUpCustomer.sweatshirtPriceRange = JSON.parse localStorageService.get("sweatshirtPriceRange")
      SignedUpCustomer.tshirtPriceRange = JSON.parse localStorageService.get("tshirtPriceRange")

    onSave = (customer) ->
      # store the selected preferences in one API call

      if $scope.customFBOauth
        prefs = getPrefsFromStorage()
        SignedUpCustomer.colorDislikes = prefs.colorDislikes
        SignedUpCustomer.shirtPatternDislikes = prefs.shirtPatternDislikes
      else
        SignedUpCustomer.colorDislikes = getColorPreferences()
        SignedUpCustomer.shirtPatternDislikes = getShirtPatternPreferences()

        #colorPrefs = getColorPreferences()
        #shirtPatternPrefs = getShirtPatternPreferences()

        #collarTypePrefs = getCollarTypePreferences()
        #measurementPrefs = $scope.genericPantFits.selected

      ###
      preferences =
        _.map(
          colorPrefs
          .concat(shirtPatternPrefs)
        ,
         (attr) ->
          'customer.id': customer.id
          'attribute.id': attr.id
        )
      ###

      styleDislikes =
        _.map(
          SignedUpCustomer.genericShirtFits.unselected
          .concat(SignedUpCustomer.genericPantFits.unselected)
          .concat(SignedUpCustomer.colorDislikes)
          .concat(SignedUpCustomer.shirtPatternDislikes)
          #.concat($scope.casualShirtFit.unselected)
        ,
         (attr) ->
          'customer.id': customer.id
          'attribute.id': attr.id
        )

      ###
      measurementPreferences =
        _.map(
          SignedUpCustomer.genericPantFits.selected
          .concat(SignedUpCustomer.casualShirtFit.selected)
        ,
         (size) ->
          'customer.id': customer.id
          'size.id': size.id
        )
      ###

      prices =
        _.map(
          SignedUpCustomer.jeansPriceRange.selected
          .concat(SignedUpCustomer.shortsPriceRange.selected)
          .concat(SignedUpCustomer.chinosPriceRange.selected)
          .concat(SignedUpCustomer.dressPantsPriceRange.selected)
          .concat(SignedUpCustomer.casualShirtPriceRange.selected)
          .concat(SignedUpCustomer.golfPoloShirtPriceRange.selected)
          .concat(SignedUpCustomer.sweaterPriceRange.selected)
          .concat(SignedUpCustomer.sweatshirtPriceRange.selected)
          .concat(SignedUpCustomer.tshirtPriceRange.selected)
        , (price) ->
          'customer.id': customer.id,
          'priceRange.id': price.id
        )

      if styleDislikes.length > 0
        $q.all(
          #ProductPreference.createAll(data: preferences)
          StyleDislike.createAll(data: styleDislikes)
          #MeasurementPreference.createAll(data: measurementPreferences)
          PricePreference.createAll(data: prices)
        )
      else
        $q.all(
          #ProductPreference.createAll(data: preferences)
          #StyleDislike.createAll(data: styleDislikes)
          #MeasurementPreference.createAll(data: measurementPreferences)
          PricePreference.createAll(data: prices)
        )

    $scope.selectAquisitionSource = (source) ->
      switch source
        when "Friend"
          sourceIsText = true
        when "Other"
          sourceIsText = true
        else
          sourceIsText = false

    onFail = (resp) ->
      $scope.loading = false

      if resp.data and resp.data.message
        if _.isArray(resp.data.message)
          $scope.validation.errors = resp.data.message
        else
          $scope.validation.errors = [resp.data.message]
      else
        if resp.message
          $scope.validation.errors = [resp.message]
        else
          $scope.validation.errors = [resp]

      $scope.registering = false

      # try to guess what error the server returned
      $scope.validation.errors = _.map(
        $scope.validation.errors,
        (e) ->
          if e?.indexOf("email") > -1 then "Email already exists"
          else if e?.indexOf("e-mail") > -1 then "Please verify your e-mail address under your Facebook account"
          else if e?.indexOf("inactive") > -1 then "User is inactive"
          else "Something unexpected happened"
      )

      scrollTo(".signup-form")

    onSuccess = (customerInfo) ->
      trackFacebookConversion()
      localStorageService.remove('signupCampaign')

      subscribeMailchimp customerInfo, ->
        trackSignupConversion ->
          $scope.registering = false
          $timeout ->
            $state.go "authenticate",
              customerInfo: customerInfo

    trackFacebookConversion = () ->
      # facebook pixel tracking
      Facebook.trackPixel "track", "CompleteRegistration"

    trackSignupConversion = (cb) ->
      # google adwords conversion
      if isProduction
        angularLoad.loadScript('https://www.googleadservices.com/pagead/conversion_async.js').then(->
          adWords.google_conversion_label = "ABlWCKPQh1wQyoO7-AM"
          window.google_trackConversion adWords
          cb()
        ).catch ->
          cb()
      else
        cb()

    subscribeMailchimp = (customerInfo, cb) ->
      customer = customerInfo.customer

      if isProduction
        # sign user up to mailing list
        MailChimpLists.subscribe({
          id: App.constants.app.mailchimp.lists.postSignup
          email:
            email: customer.email
          merge_vars:
            FNAME: customer.firstName
            LNAME: customer.lastName
          double_optin: false
        }).then (resp) ->
          cb()
      else
        cb()

    # email signup
    $scope.signUp = (form) ->
      onBeforeSave($scope.customer)
      $scope.registering = true

      credentials =
        username: $scope.customer.email
        password: $scope.customer.password

      # acquisition source
      if sourceIsText
        $scope.customer.acquisitionSource = $scope.customer.acquisitionSourceText + ' (' + $scope.customer.acquisitionSource + ')'

      # save the user's selected preferences
      Customer.create($scope.customer).$promise.then (resp) ->
        #$scope.customer.value = resp.data
        if resp.success
          customer = resp.data
          onSave(customer).then (resp) ->
            # authenticate the customer
            type = (if not customer.facebookId then "email" else "facebook")

            customerInfo =
              customer: customer
              credentials: credentials
              type: type
              signup: true

            onSuccess(customerInfo)

          , onFail
        else
          onFail resp
      , onFail

    # facebook signup
    $scope.fbLogin = () ->
      if navigator.userAgent.match('CriOS')
        customerInfo = getCustomerInfo()
        localStorageService.set('customerInfo', JSON.stringify(customerInfo))

        colorDislikes = getColorPreferences()
        localStorageService.set("colorDislikes", JSON.stringify(colorDislikes))

        shirtPatternDislikes = getShirtPatternPreferences()
        localStorageService.set("shirtPatternDislikes", JSON.stringify(shirtPatternDislikes))

        setScopesToStorage()
        window.open fbOauthURL, '', null
      else
        ezfb.login ((res) ->
          if res.authResponse
            updateFBLoginStatus(onFBConnect)
          return
        ), scope: fbScope

    onFBError = (resp) ->
      resp = decodeURIComponent(resp).replace(/\+/g, ' ').replace('#_=_', '')

      $timeout ->
        auth.clearInfo()
        #$window.sessionStorage["userInfo"] = null
        $scope.validation.error = resp
      $scope.loading = false
      $scope.registering = false

    onFBMeSuccess = (fbMeResp) ->
      if $scope.customFBOauth
        setScopesFromStorage()

      $scope.customer.firstName = fbMeResp.first_name
      $scope.customer.lastName = fbMeResp.last_name
      $scope.customer.email = fbMeResp.email

      credentials =
        username: $scope.customer.email
        password: $scope.customer.password

      # attempt to find customer by facebook email
      Customer.find({
        email: fbMeResp.email
      }).$promise.then (resp) ->
        if resp.success
          customer = resp.data
          onBeforeSave(customer)

          customer.facebookId = fbMeResp.id
          Customer.updateCustomerSignup(customer).then (resp) ->
            onSave(customer).then (resp) ->

              customerInfo =
                customer: customer
                credentials: credentials
                type: 'existing-email'
                signup: false

              onSuccess(customerInfo)

        else
          # attempt to find customer by facebook id
          Customer.find({
            facebookId: fbMeResp.id
          }).$promise.then (resp) ->
            if !resp.success
              # this is a brand new customer, sign up
              if resp.message is 'Object with id=null not found'
                $scope.customer.facebookId = fbMeResp.id
                $scope.customer.password = generatePW()
                $scope.signUp()
              else
                onFail resp.message

            else
              # if a customer with the same facebookId already exists, just update the existing customer
              if resp.data.facebookId is fbMeResp.id
                customer = resp.data

                onBeforeSave(customer)
                Customer.updateCustomerSignup(customer).then (resp) ->
                  onSave(customer).then (resp) ->

                    customerInfo =
                      customer: customer
                      credentials: credentials
                      type: 'existing-facebook'
                      signup: false

                    onSuccess(customerInfo)

                , onFail

    fbMe = (authResponse) ->
      ezfb.api '/me', (fbMeResp) ->
        if !fbMeResp.email
          failResp = 'Please verify your e-mail address under your Facebook account'
          onFail(failResp)
          return

        onFBMeSuccess(fbMeResp)

    onFBConnect = (resp) ->
      fbID = resp.authResponse.userID
      if resp
        fbMe(resp.authResponse)

    updateFBLoginStatus = (more) ->
      ezfb.getLoginStatus (res) ->
        $scope.fbLoginStatus = res
        (more or angular.noop)(res)
        return
      return

    fillForm = ($form, vals) ->
      fields = []

      for key of vals
        $field = $form.find('.' + key + ' input')
        if $field.length > 0
          $field.val(vals[key])
          fields.push key

      $timeout ->
        _.each fields, (field) ->
          $form.find('.' + field + ' input').trigger('change')

        $form.find(".ng-pristine").each ->
          $this = $(this)
          $row = $this.parents('.form-group')
          $row.find('.alert').removeClass('ng-hide')
          $this.addClass('ng-invalid ng-invalid-required').trigger('change')

    # facebook
    fbAppID = App.constants.app.facebook.appId
    fbScope = 'email,public_profile'
    fbRedirectURI = window.location.origin + '/signup/step4'
    fbOauthURL = 'https://www.facebook.com/dialog/oauth?client_id=' + fbAppID + '&redirect_uri=' + fbRedirectURI + '&scope=' + fbScope

    # check for FB auth token
    fbCode = $location.search()['code']

    $scope.customFBOauth = false
    if fbCode
      $scope.customFBOauth = true

      $timeout ->
        $state.go 'signup.step4'

      graphParams =
        client_id: fbAppID
        redirect_uri: fbRedirectURI
        code: fbCode

      auth.getFBGraphUser(graphParams).show().$promise.then ((resp) ->
        if resp.success
          ezfb.api '/me?access_token=' + resp.data.access_token, (fbMeResp) ->
            if fbMeResp.id
              onFBMeSuccess(fbMeResp)
            else
              onFBError(fbMeResp.error.message)
        else
          onFBError(resp.message)
      ), ->
        onFBError('An error has occurred.  Please try again.')

    fbErrorMsg = $location.search()['error_message']
    if fbErrorMsg
      onFBError(fbErrorMsg)
])

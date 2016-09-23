'use strict'

# has shared data between controllers
angular.module('app')
.factory 'SelectedCategories', [() ->
  return { list : [] }
]

angular.module('app')
.factory 'SignedUpCustomer', [() ->
  SignedUpCustomer = {}

  SignedUpCustomer
]

angular.module('app')
.factory 'CurrentOrder', [() ->
  CurrentOrder = {}

  CurrentOrder
]

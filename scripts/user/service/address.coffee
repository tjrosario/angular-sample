'use strict'

angular.module('app')
.factory 'Address', ['$resource', 'appConfig', ($resource, appConfig) ->
    Address = $resource "#{appConfig.api.baseUrl}/address/:action/:id?expand=:expand", undefined,
    id: '@id'
    create:
      method: 'GET'
      params:
        action: 'create'
    update:
      method: 'GET'
      params:
        action: 'update'
    show:
      method: 'GET'
      params:
        action: 'show'
    delete:
      method: 'GET'
      params:
        action: 'delete'
    findBy:
      method: 'GET'
      params:
        action: 'findBy'
        className: ''
        id: ''
        expand: ''

    Address
  ]

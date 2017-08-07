#= require plugins/lodash.min
#= require humps

class Notifications
  attributes: [
    'deviceTypeEq', 'countryCodeIn'
  ]

  constructor: (attributes) ->
    @update(humps.camelizeKeys(attributes))

  update: (attributes) ->
    _.extend(this, attributes)

  save: ->
    $.ajax(
      type: 'GET'
      url: '/admin/devices/count'
      data:
        q: @serializedHash()
      dataType: 'json'
    )

  serializedHash: ->
    _.omit(humps.decamelizeKeys(_.pick(this, @attributes)), _.isNull)

@CPA.Notification.Notifications = Notifications
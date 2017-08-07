#= require plugins/lodash.min
#= require humps

class CouponRule
  attributes: [
    'id', 'quantity', 'condition', 'thresholdId', 'productModelIds',
    'designerIds', 'productCategoryIds', 'workGids', 'bdeventId'
  ]

  constructor: (attributes) ->
    @update(humps.camelizeKeys(attributes))

  update: (attributes) ->
    _.extend(this, attributes)

  serializedHash: ->
    _.omit(humps.decamelizeKeys(_.pick(this, @attributes)), _.isNull)

@CPA.Coupons.CouponRule = CouponRule

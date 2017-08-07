#= require plugins/lodash.min
#= require humps

class Coupon
  attributes: [
    'id', 'quantity', 'title', 'code', 'usageCount', 'usageCountLimit',
    'beginAt', 'expiredAt', 'priceTierId', 'discountType', 'percentage',
    'condition', 'userUsageCountLimit', 'basePriceType', 'applyCountLimit',
    'codeType', 'codeLength', 'isFreeShipping', 'isNotIncludePromotion',
    'canUpdateExpiredAt'
  ]

  constructor: (attributes) ->
    @update(humps.camelizeKeys(attributes))

  update: (attributes) ->
    _.extend(this, attributes)

  save: ->
    if @id
      $.ajax(
        type: 'PATCH'
        url: "/admin/coupons/#{@id}"
        data:
          coupon: @serializedHash()
        dataType: 'json'
      )
    else
      $.ajax(
        type: 'POST'
        url: '/admin/coupons'
        data:
          coupon: @serializedHash()
        dataType: 'json'
      )

  serializedHash: ->
    result = _.omit(humps.decamelizeKeys(_.pick(this, @attributes)), _.isNull)
    result.coupon_rules = @serializeCouponRules()
    result

  serializeCouponRules: ->
    _.mapValues this.couponRules, (rule) ->
      _.omit(humps.decamelizeKeys(_.pick(rule, rule.attributes)), _.isNull)


@CPA.Coupons.Coupon = Coupon

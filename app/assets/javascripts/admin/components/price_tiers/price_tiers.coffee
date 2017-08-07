class PriceTiers
  constructor: (tiers, currencies) ->
    @tiers = @load(tiers)
    @currencies = currencies
    @changeset = []

  clone: -> new PriceTiers(@tiers, @currencies)

  load: (tiers) ->
    Immutable.fromJS(tiers)

  add: ->
    nextTier = @_nextTier()
    nextTier = nextTier.set('cid', Random.uuid())
    @tiers = @tiers.push(nextTier)
    @changeset.push(method: 'create', tier: nextTier.toJS())

  update: (priceTier) ->
    index = @_indexOfTier(priceTier)
    currentPriceTier = @tiers.get(index)
    priceTier = currentPriceTier.merge(priceTier)
    @tiers = @tiers.set(index, priceTier)
    @changeset.push(method: 'update', tier: priceTier.toJS())

  isValid: ->
    @_validateAllPricesArePresent() and @_validateAllPricesArePositive()

  asJSON: ->
    tiersWithouId = @tiers.map (tier) -> tier.remove('id')
    tiersWithouId.toJS()

  getChangeset: ->
    removingChanges = _.where(@changeset, method: 'destroy')
    _.each removingChanges, (removingChange) =>
      if removingChange.tier.id
        _.remove @changeset, (change) ->
          change.method isnt 'destroy' and change.tier.id is removingChange.tier.id
      else
        _.remove @changeset, (change) ->
          change.tier.cid is removingChange.tier.cid
    @changeset

  # private

  _indexOfTier: (priceTier) ->
    @tiers.findIndex (pt) -> pt.get('tier') is priceTier.get('tier')

  _nextTier: ->
    tier = tier: @tiers.count() + 1

    if @tiers.count() > 1
      for currency in @currencies
        length = @tiers.count()
        last1 = @tiers.get(length - 1).get(currency) || 0
        last2 = @tiers.get(length - 2).get(currency) || 0
        tier[currency] = last1 + (last1 - last2)

    Immutable.Map(tier)

  _validateAllPricesArePresent: ->
    valid = true
    for currency in @currencies
      @tiers.forEach (priceTier) ->
        valid = false if isNaN(priceTier.get(currency))
    valid

  _validateAllPricesArePositive: ->
    valid = true
    for currency in @currencies
      @tiers.forEach (priceTier) ->
        valid = false if priceTier.get(currency) <= 0
    valid

# testing
# PriceTiersTest = ->
#   priceTiers = new PriceTiers([
#     { tier: 1, TWD: 10, HKD:  5, JPY: 30 }
#     { tier: 2, TWD: 20, HKD: 10, JPY: 60 }
#     { tier: 3, TWD: 30, HKD: 15, JPY: 90 }
#   ], ['TWD', 'HKD', 'JPY'])
#   console.log 'priceTiers should have 3 tiers', priceTiers.tiers.size == 3
#   console.log 'tiers should have correct id', priceTiers.tiers.get(0).get('id') == 1
#   console.log 'tiers should have correct id', priceTiers.tiers.get(1).get('id') == 2
#   console.log 'tiers should have correct id', priceTiers.tiers.get(2).get('id') == 3
#   priceTiers.add()
#   console.log 'priceTiers should have 4 tiers after add()', priceTiers.tiers.size == 4
#   addedTier = priceTiers.tiers.last()
#   console.log 'added tier should have correct tier', addedTier.get('tier') == 4
#   console.log 'added tier should have correct TWD price', addedTier.get('TWD') == 40
#   console.log 'added tier should have correct HKD price', addedTier.get('HKD') == 20
#   console.log 'added tier should have correct JPY price', addedTier.get('JPY') == 120
#   console.log 'added tier should have correct id', priceTiers.tiers.get(3).get('id') == 4
#   priceTiers.update(Immutable.Map(tier: 3, TWD: 30, HKD: 18, JPY: 90))
#   updatedTier = priceTiers.tiers.get(2)
#   console.log 'updated tier should have correct HKD price', updatedTier.get('HKD') == 18
#   priceTiers.update(Immutable.Map(tier: 3, TWD: NaN, HKD: NaN, JPY: NaN))
#   console.log 'priceTiers should have 3 tiers after delete', priceTiers.tiers.size == 3
#   console.log 'priceTiers should have correct tier', priceTiers.tiers.get(0).get('tier') == 1
#   console.log 'priceTiers should have correct tier', priceTiers.tiers.get(1).get('tier') == 2
#   console.log 'priceTiers should have correct tier', priceTiers.tiers.get(2).get('tier') == 3
# PriceTiersTest()

@CPA.PriceTiers.PriceTiers = PriceTiers

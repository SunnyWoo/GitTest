# @cjsx

@CPA.Coupons.Form = React.createClass
  propTypes:
    coupon: React.PropTypes.object
    action: React.PropTypes.string.isRequired
    method: React.PropTypes.string.isRequired

  getInitialState: ->
    coupon: new CPA.Coupons.Coupon(@props.coupon)
    codeLengthMin: 6

  updateQuantity: (e) -> @update(quantity: e.value)

  updateTitle: (e) -> @update(title: e.target.value)

  generateCode: -> @refs.generateCodeInput.generateCode(@state.coupon.codeType, @state.coupon.codeLength)

  updateCode: (e) -> @update(code: e.value)

  updateCodeType: (e) ->
    @update(codeType: e.target.value)
    if e.target.value == 'number'
      codeLengthMin = 10
    else
      codeLengthMin = 6
    @setState({ codeLengthMin })
    @updateCodeLength(value: Math.max(codeLengthMin, @state.coupon.codeLength))

  updateCodeLength: (e) -> @update(codeLength: e.value)

  updateUsageCountLimit: (e) -> @update(usageCountLimit: e.value)

  updateUserUsageCountLimit: (e) -> @update(userUsageCountLimit: e.value)

  updateApplyCountLimit: (e) -> @update(applyCountLimit: e.value)

  updateDiscountType: (e) -> @update(discountType: e.target.value)

  updatePriceTierId: (e) -> @update(priceTierId: e.value)

  updatePercentage: (e) -> @update(percentage: e.value)

  updateCondition: (e) ->
    if e.target.value is 'simple'
      @state.coupon.couponRules[1] = new CPA.Coupons.CouponRule()
    @update(condition: e.target.value)

  updateApplyTarget: (e) -> @update(applyTarget: e.target.value)

  updateBasePriceType: (e) -> @update(basePriceType: e.target.value)

  updateBeginAt: (e) -> @update(beginAt: e.target.value)

  updateExpiredAt: (e) -> @update(expiredAt: e.target.value)

  updateWorkGids: (e) -> @update(workGids: e.value)

  updateIsFreeShipping: (e) -> @update(isFreeShipping: e.value)

  updateIsNotIncludePromotion: (e) -> @update(isNotIncludePromotion: e.value)

  updateCouponRule: (e) ->
    @state.coupon.couponRules[e.index] = e.coupon_rule
    @setState(coupon: @state.coupon)

  updateNeverExpires: (e) ->
    if e.target.checked
      @expiredAtWas = @state.coupon.expiredAt
      @update(expiredAt: '2199-12-31')
    else
      @update(expiredAt: @expiredAtWas)

  isNeverExpires: -> @state.coupon.expiredAt is '2199-12-31'

  canUpdateExpiredAt: -> @state.coupon.canUpdateExpiredAt

  update: (attributes) ->
    @state.coupon.update(attributes)
    @setState(coupon: @state.coupon)

  redirectToIndex: ->
    Turbolinks.visit('/admin/coupons')

  save: ->
    @setState(errors: null)
    @state.coupon.save()
      .error (xhr) => @setState(errors: humps.camelizeKeys JSON.parse(xhr.responseText))
      .success => @redirectToIndex()

  render: ->
    <div>
      <div className="pull-right">
        <button className="btn btn-link" onClick={@redirectToIndex}>{I18n.t('js.button.cancel')}</button>
        <button className="btn btn-primary" onClick={@save}>{I18n.t('js.button.save')}</button>
      </div>
      <h2>{I18n.t('js.coupon.new.title')}</h2>

      <div className="row">
        <div className="col-sm-3">
          <h3>{I18n.t('js.coupon.new.detail')}</h3>
          <p>{I18n.t('js.coupon.new.detail_desc')}</p>
        </div>
        <div className="col-sm-9">
          <h4>{I18n.t('js.coupon.new.name')}</h4>
          <input type="text" className="form-control"
                 value={@state.coupon.title} onChange={@updateTitle} disabled={@updateDisabled('title')}/>
          {@renderErrorsFor('title')}
          {@renderQuantityInputGroup()}
          {@renderCodeSetting()}
          {@renderCodeInput()}
          {@renderErrorsFor('code')}
          {@renderUsageCountLimitInput()}
          {@renderErrorsFor('usageCountLimit')}
        </div>
      </div>

      <div className="row">
        <div className="col-sm-3">
        </div>
        <div className="col-sm-9">
          <h4>{I18n.t('js.coupon.new.expired')}</h4>
          <div className="row">
            <div className="col-sm-4">
              <h6>{I18n.t('js.coupon.new.begin')}</h6>
              <input type="date"
                     value={@state.coupon.beginAt}
                     onChange={@updateBeginAt}
                     disabled={@updateDisabled('beginAt')} />
            </div>
            <div className="col-sm-8">
              <h6>{I18n.t('js.coupon.new.expires')}</h6>
              <input type="date" value={@state.coupon.expiredAt}
                     disabled={@isNeverExpires() || !@canUpdateExpiredAt()} onChange={@updateExpiredAt} />
              <label>
                  <input type="checkbox" checked={@isNeverExpires()}
                         onChange={@updateNeverExpires} disabled={!@canUpdateExpiredAt()} />
                  {I18n.t('js.coupon.new.never_expires')}
              </label>
              {@renderErrorsFor('expiredAt')}
            </div>
          </div>
        </div>
      </div>

      <hr />
      <div className="row">
        <div className="col-sm-3">
          <h3>{I18n.t('js.coupon.new.more')}</h3>
          <p>{I18n.t('js.coupon.new.more_desc')}</p>
        </div>
        <div className="col-sm-9">
          {@renderShippingSetting()}
          <h4>{I18n.t('js.coupon.new.base_price')}</h4>
          {@renderBasePriceType()}
          {@renderErrorsFor('basePriceType')}
          {@renderUserUsageCountLimitInput()}
          {@renderErrorsFor('userUsageCountLimit')}
          <h4>{I18n.t('js.coupon.new.target')}</h4>
          {@renderConditionComponents()}
          {@renderCouponRuleComponents(0)}
          {@renderCouponRuleComponents(1)}
          {@renderErrorsFor('couponRules.threshold')}
          {@renderErrorsFor('couponRules.designerIds')}
          {@renderErrorsFor('couponRules.productModelIds')}
          {@renderErrorsFor('couponRules.workGids')}
          {@renderErrorsFor('couponRules.productCategoryIds')}
          {@renderErrorsFor('couponRules')}
          {@renderErrorsFor('couponRules.quantity')}
          {@renderApplyCountLimit()}
          <h4>{I18n.t('js.coupon.new.type')}</h4>
          <div>
            <select value={@state.coupon.discountType} onChange={@updateDiscountType} disabled={@updateDisabled('couponType')}>
              <option value="fixed">{I18n.t('js.coupon.new.discount_amount')}</option>
              <option value="percentage">{I18n.t('js.coupon.new.discount_percentage')}</option>
              <option value="pay">{I18n.t('js.coupon.new.pay_amount')}</option>
              <option value="none">{I18n.t('js.coupon.new.discount_none')}</option>
            </select> {@renderDiscountInput()}
          </div>
          {@renderErrorsFor('discountType')}
          {@renderErrorsFor('percentage')}
          {@renderErrorsFor('priceTier')}
          {@renderErrorsFor('condition')}
          {@renderErrorsFor('applyCountLimit')}
        </div>
      </div>

      <div className="text-right">
        <button className="btn btn-link" onClick={@redirectToIndex}>{I18n.t('js.button.cancel')}</button>
        <button className="btn btn-primary" onClick={@save}>{I18n.t('js.button.save')}</button>
      </div>
    </div>

  updateDisabled: (inputType)->
    if @props.method is 'PATCH'
      switch inputType
        when 'title', 'couponCode', 'couponType', 'beginAt', 'basePriceType', 'codeType', 'codeLength', 'isFreeShipping', 'isNotIncludePromotion'
          disabled = true
    else
      disabled = false

  getApplyCountLimitDisplay: ->
    disabled = false
    @state.coupon.couponRules.forEach (rule) ->
      switch rule.condition
        when 'include_product_models', 'include_product_categories', 'include_designers', 'include_designers_models', 'include_works'
          disabled = true
    disabled

  renderQuantityInputGroup: ->
    unless @state.coupon.id
      <div>
        <h4>{I18n.t('js.coupon.new.count')}</h4>
        <CPA.Coupons.QuantityInput value={@state.coupon.quantity}
                                   onChange={@updateQuantity} />
        {@renderErrorsFor('quantity')}
      </div>

  renderErrorsFor: (attribute) ->
    if @state.errors?[attribute]
      <div className="text-danger">{@state.errors[attribute][0]}</div>

  renderGenerateCodeButton: ->
    <button className="btn btn-default" onClick={@generateCode} disabled={@updateDisabled('couponCode')}>{I18n.t('js.coupon.new.generate_code')}</button>

  renderCodeSetting: ->
    <div>
      <h4>折扣碼設定</h4>
      <div className="row">
        <div className="col-sm-3">
          CodeType：
          <select value={@state.coupon.codeType} onChange={@updateCodeType} disabled={@updateDisabled('codeType')}>
            <option value="base">base</option>
            <option value="number">number</option>
            <option value="alphabet">alphabet</option>
          </select>
        </div>
        <div className="col-sm-3">
          <CPA.Coupons.codeLength value={@state.coupon.codeLength}
                                  min={@state.codeLengthMin}
                                  onChange={@updateCodeLength}
                                  disabled={@updateDisabled('codeLength')} />
        </div>
      </div>
    </div>

  renderCodeInput: ->
    if @state.coupon.quantity is 1
      <div>
        <h4>{I18n.t('js.coupon.new.code')}</h4>
        <div className="col-sm-6">
          <CPA.Coupons.CodeInput ref="generateCodeInput"
                                 value={@state.coupon.code}
                                 onChange={@updateCode}
                                 disabled={@updateDisabled('couponCode')} />
        </div>
        <div className="col-sm-6">
          {@renderGenerateCodeButton()}
        </div>
      </div>

  renderUsageCountLimitInput: ->
    if @state.coupon.quantity is 1
      <div>
        <h4>
          <span>{I18n.t('js.coupon.new.usage_limit')}</span>
          {@renderUsedTimes()}
        </h4>
        <CPA.Coupons.UsageCountLimitInput value={@state.coupon.usageCountLimit}
                                          onChange={@updateUsageCountLimit} />
      </div>

  renderUserUsageCountLimitInput: ->
    <div>
      <h4>
        <span>{I18n.t('js.coupon.new.user_usage_limit')}</span>
      </h4>
      <CPA.Coupons.UserUsageCountLimitInput value={@state.coupon.userUsageCountLimit}
                                            onChange={@updateUserUsageCountLimit} />
    </div>

  renderUsedTimes: ->
    if @props.method is 'PATCH'
      html = <span className="couponUsed">(Used times: {@state.coupon.usageCount})</span>

  renderDiscountInput: ->
    switch @state.coupon.discountType
      when 'pay', 'fixed'
        <CPA.Base.PriceTierInput value={@state.coupon.priceTierId}
                                 onChange={@updatePriceTierId}
                                 disabled={@updateDisabled('couponType')} />
      when 'percentage'
        <CPA.Base.PercentageInput value={@state.coupon.percentage}
                                  onChange={@updatePercentage}
                                  disabled={@updateDisabled('couponType')} />

  renderConditionComponents: ->
    <span>
      <select value={@state.coupon.condition} onChange={@updateCondition} disabled={@updateDisabled('couponType')}>
        <option value="none">{I18n.t('js.coupon.new.all_order')}</option>
        <option value="simple">{I18n.t('js.coupon.new.simple')}</option>
        <option value="rules">{I18n.t('js.coupon.new.rules')}</option>
      </select>
    </span>

  renderCouponRuleComponents: (index)->
    if @state.coupon.condition is 'rules' || (@state.coupon.condition is 'simple' && index is 0)
      <CPA.Coupons.RulesInput coupon={@state.coupon}
                              index={index}
                              onChange={@updateCouponRule}
                              disabled={@updateDisabled('couponType')} />

  renderApplyCountLimit: ->
    if @getApplyCountLimitDisplay()
      <div className="row">
        {I18n.t('js.coupon.new.item_limit')}
        <CPA.Coupons.ApplyCountLimitInput value={@state.coupon.applyCountLimit}
                                          onChange={@updateApplyCountLimit} />
        {@renderErrorsFor('applyCountLimit')}
      </div>

  renderBasePriceType: ->
    optionClass = if @props.method is 'PATCH' then '' else 'hide'
    <div>
      <select value={@state.coupon.basePriceType} onChange={@updateBasePriceType} disabled={@updateDisabled('basePriceType')}>
        <option className={optionClass} value="original">{I18n.t('js.coupon.new.original_price')}</option>
        <option value="special">{I18n.t('js.coupon.new.special_price')}</option>
      </select>
    </div>

  renderShippingSetting: ->
    <div>
      <h4>運費設定</h4>
      <div className="row">
        <div className="col-sm-6">
          <CPA.Base.CheckboxInput name="isFreeShipping"
                                  value={@state.coupon.isFreeShipping}
                                  text="免運"
                                  onChange={@updateIsFreeShipping}
                                  disabled={@updateDisabled('isFreeShipping')} />
          <CPA.Base.CheckboxInput name="isNotIncludePromotion"
                                  value={@state.coupon.isNotIncludePromotion}
                                  text="不可與其他 promotion 同時使用"
                                  onChange={@updateIsNotIncludePromotion}
                                  disabled={@updateDisabled('isNotIncludePromotion')} />
        </div>
      </div>
    </div>

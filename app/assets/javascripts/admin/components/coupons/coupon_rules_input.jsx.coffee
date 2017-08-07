# Public: Coupon Rules Input Component
# @cjsx

@CPA.Coupons.RulesInput = React.createClass
  propTypes:
    coupon: React.PropTypes.object
    disabled: React.PropTypes.boolean
    index: React.PropTypes.integer
    onChange: React.PropTypes.func.isRequired

  getInitialState: ->
    rule: new CPA.Coupons.CouponRule(@props.coupon.couponRules[@props.index])

  updateThresholdId: (e) -> @update(thresholdId: e.value)

  updateProductModelIds: (e) -> @update(productModelIds: e.value)

  updateProductCategoryIds: (e) -> @update(productCategoryIds: e.value)

  updateDesignerIds: (e) -> @update(designerIds: e.value)

  updateWorkGids: (e) -> @update(workGids: e.value)

  updateBdeventId: (e) -> @update(bdeventId: e.value)

  updateQuantity: (e) -> @update(quantity: e.value)

  updateRuleCondition: (e) ->  @update(condition: e.target.value)

  update: (attributes) ->
    @state.rule.update(attributes)
    @setState(rule: @state.rule)
    @props.onChange?(coupon_rule: @state.rule, index: @props.index)

  renderThresholdInput: ->
    if @state.rule.condition is 'threshold'
      <div>
        <CPA.Base.PriceTierInput value={@state.rule.thresholdId}
                                 onChange={@updateThresholdId}
                                 disabled={@props.disabled} />
      </div>

  renderProductModelsInput: ->
    if @state.rule.condition is 'include_product_models'
      <div className="row">
        <div className="col-sm-8">
          <CPA.Base.ProductModelInput value={@state.rule.productModelIds}
                                      onChange={@updateProductModelIds}
                                      disabled={@props.disabled} />
        </div>
        {@renderQuantity()}
      </div>

  renderProductCategoriesInput: ->
    if @state.rule.condition is 'include_product_categories'
      <div className="row">
        <div className="col-sm-8">
          <CPA.Base.ProductCategoryInput value={@state.rule.productCategoryIds}
                                         onChange={@updateProductCategoryIds}
                                         disabled={@props.disabled} />
        </div>
        {@renderQuantity()}
      </div>

  renderDesignersInput: ->
    if @state.rule.condition is 'include_designers'
      <div className="row">
        <div className="col-sm-8">
          <CPA.Base.DesignersInput value={@state.rule.designerIds}
                                   onChange={@updateDesignerIds}
                                   disabled={@props.disabled} />
        </div>
        {@renderQuantity()}
      </div>

  renderWorksInput: ->
    if @state.rule.condition is 'include_works'
      <div className="row">
        <div className="col-sm-8">
          <CPA.Base.WorksInput value={@state.rule.workGids}
                               onChange={@updateWorkGids}
                               disabled={@props.disabled} />
        </div>
      </div>

  renderDesignersModesInput: ->
    if @state.rule.condition is 'include_designers_models'
      <div className="row">
        <div className="col-sm-8">
          <CPA.Base.DesignersInput value={@state.rule.designerIds}
                                   onChange={@updateDesignerIds}
                                   disabled={@props.disabled} />

          <CPA.Base.ProductModelInput value={@state.rule.productModelIds}
                                      onChange={@updateProductModelIds}
                                      disabled={@props.disabled} />
        </div>
        {@renderQuantity()}
      </div>

  renderBdeventInput: ->
    if @state.rule.condition is 'include_bdevent'
      <div className="row">
        <div className="col-sm-8">
          <CPA.Base.BdeventInput value={@state.rule.bdeventId}
                                 onChange={@updateBdeventId}
                                 disabled={@props.disabled} />
        </div>
      </div>

  renderQuantity: ->
    if @props.coupon.condition is 'rules'
      <div className="col-sm-4">
        <CPA.Base.NumberInput className="form-control"
                              value={@state.rule.quantity}
                              onChange={@updateQuantity}
                              disabled={@props.disabled} />
        {I18n.t('js.coupon.new.rule_quantity')}
      </div>
  renderTitle: ->
    if @props.coupon.condition is 'rules'
      <span>{I18n.t("js.coupon.new.rule#{@props.index+1}")}</span>

  otherRule: ->
    @props.coupon.couponRules[Math.abs(@props.index - 1)]

  renderThresholdDisplay: ->
    if (@props.coupon.condition is 'simple' || @otherRule().condition isnt 'threshold') then 'show' else 'hidden'

  renderBdeventDisplay: ->
    if @props.coupon.condition is 'simple' then 'show' else 'hidden'
  render: ->
    <div className="row">
      <div className="col-sm-5">
        {@renderTitle()}
        <span>
          <select value={@state.rule.condition} onChange={@updateRuleCondition} disabled={@props.disabled}>
            <option></option>
            <option className={@renderThresholdDisplay()} value="threshold">{I18n.t('js.coupon.new.order_over')}</option>
            <option value="include_product_models">{I18n.t('js.coupon.new.specify_products')}</option>
            <option value="include_product_categories">{I18n.t('js.coupon.new.specify_product_categories')}</option>
            <option value="include_designers">{I18n.t('js.coupon.new.specify_designers')}</option>
            <option value="include_designers_models">{I18n.t('js.coupon.new.specify_products_designers')}</option>
            <option className={@renderBdeventDisplay()} value="include_works">{I18n.t('js.coupon.new.specify_work')}</option>
            <option className={@renderBdeventDisplay()} value="include_bdevent">{I18n.t('js.coupon.new.specify_bdevent')}</option>
          </select>
        </span>
      </div>
      <div className="col-sm-5">
        {@renderThresholdInput()}
        {@renderProductModelsInput()}
        {@renderProductCategoriesInput()}
        {@renderDesignersInput()}
        {@renderDesignersModesInput()}
        {@renderWorksInput()}
        {@renderBdeventInput()}
      </div>
    </div>

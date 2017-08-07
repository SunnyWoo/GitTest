# @cjsx

@CPA.Assets.Edit = React.createClass
  getInitialState: ->
    assetPackage: CPA.Stores.AssetPackageForm.get()

  componentDidMount: ->
    $(@refs.icon.getDOMNode())
      .fileupload(url: "/admin/asset_packages/#{@state.assetPackage.id}/icon", paramName: 'file')
      .on('fileuploaddone', @onIconUploadDone)
      .on('fileuploadfail', @onIconUploadFail)

    CPA.Stores.AssetPackageForm.on('load',   @updateFromStore)
    CPA.Stores.AssetPackageForm.on('update', @updateFromStore)
    CPA.Stores.AssetPackageForm.on('error',  @updateErrors)
    CPA.Actions.AssetPackages.edit(@props.id)
    CPA.Actions.AssetPackages.loadCategory()
    CPA.Stores.AssetPackageForm.on('loadCategories',  @loadCategories)

  componentWillUnmount: ->
    $(@refs.icon.getDOMNode()).fileupload('destroy')

    CPA.Stores.AssetPackageForm.off('load',   @updateFromStore)
    CPA.Stores.AssetPackageForm.off('update', @updateFromStore)
    CPA.Stores.AssetPackageForm.off('error',  @updateErrors)
    CPA.Stores.AssetPackageForm.on('loadCategories',  @loadCategories)

  updateFromStore: ->
    assetPackage = CPA.Stores.AssetPackageForm.get()
    $(@refs.icon.getDOMNode())
      .fileupload(url: "/admin/asset_packages/#{assetPackage.id}/icon")
    @setState(assetPackage: assetPackage)

  updateErrors: (errors) ->
    @setState(errors: errors)

  loadCategories: (assetPackageCategories) ->
    @setState(categories: assetPackageCategories)

  loadCategoryCollection: ->
    if @state.categories
      _.map(@state.categories, (category) ->
          value: category.id
          label: category.name
        )
    else
      [{ value: '', label: '' }]

  onIconUploadDone: (e, data) ->
    CPA.Actions.AssetPackages.patch(@state.assetPackage, data.result)

  onIconUploadFail: (e, data) ->
    CPA.Actions.Flash.error('Something went wrong')

  updateDesignerId: (e) -> @updateColumn('designerId', e)

  updateNameTranslations: (e) -> @updateColumn('nameTranslations', e)

  updateDescriptionTranslations: (e) -> @updateColumn('descriptionTranslations', e)

  updateBeginAt: (e) -> @updateColumn('beginAt', e)

  updateEndAt: (e) -> @updateColumn('endAt', e)

  updateCountries: (e) -> @updateColumn('countries', e)

  updateForever: (e) ->
    if e.target.checked
      @state.endAtWas = @state.assetPackage.endAt
      @updateColumn('endAt', value: '2199-12-31')
    else
      @updateColumn('endAt', value: @state.endAtWas)

  updateCategoryId: (e) -> @updateColumn('categoryId', e)

  updateAvailable: (e) ->
    value = e.target.checked
    @state.assetPackage['available'] = value
    @forceUpdate()

  isAvaliabled: ->
    if @state.assetPackage.available is true then true else false

  isForever: -> @state.assetPackage.endAt is '2199-12-31'

  updateColumn: (column, e) ->
    value = e.target?.value or e.value
    @state.assetPackage[column] = value
    @forceUpdate()

  submit: ->
    CPA.Actions.AssetPackages.update(@state.assetPackage)

  render: ->
    <div>
      <h1>
        <div className='file-input-container inline'>
          <img src={@state.assetPackage.icon or 'http://placehold.it/100x100'} alt='placeholder' />
          <input type='file' ref='icon' />
        </div> {@state.assetPackage.name}
      </h1>
      <div className='well'>
        <div className='pull-right'>
          <CPA.Base.Link href='/' className='btn btn-default'>Cancel</CPA.Base.Link>
          <button className='btn btn-primary' onClick={@submit}>Save</button>
        </div>
        <h1>Edit Asset Package</h1>
        <hr />

        <div className='row'>
          <div className='col-sm-3'><h2>Basic Info</h2></div>
          <div className='col-sm-9'>
            <h3>Category</h3>
            <CPA.Base.SelectInput value={@state.assetPackage.categoryId}
                                  collection={@loadCategoryCollection()}
                                  onChange={@updateCategoryId}/>
            <h3>Designer</h3>
            <CPA.Base.DesignerInput value={@state.assetPackage.designerId}
                                    onChange={@updateDesignerId} />

            <h3>Available</h3>
              <div className='checkbox'>
                <label><input type="checkbox" value={@state.assetPackage.available}
                      defaultChecked={@state.assetPackage.available}
                      onChange={@updateAvailable} /> Available
                </label>
              </div>
            <h3>Title</h3>
            <CPA.Base.TranslationsInput value={@state.assetPackage.nameTranslations}
                                        onChange={@updateNameTranslations} />
            {@renderErrorsFor('name')}

            <h3>Description</h3>
            <CPA.Base.TranslationsInput multiline
                                        value={@state.assetPackage.descriptionTranslations}
                                        onChange={@updateDescriptionTranslations} />
            {@renderErrorsFor('description')}
          </div>
        </div>
        <hr />
        <div className='row'>
          <div className='col-sm-3'><h2>Distribution</h2></div>
          <div className='col-sm-9'>
            <div className='row'>
              <div className='col-sm-4'>
                <h3>Begins</h3>
                <input className='form-control' type='date'
                       value={@state.assetPackage.beginAt} onChange={@updateBeginAt} />
              </div>
              <div className='col-sm-4'>
                <h3>Ends</h3>
                <input className='form-control' type='date'
                       value={@state.assetPackage.endAt} onChange={@updateEndAt}
                       disabled={@isForever()} />
                <label><input type="checkbox" checked={@isForever()}
                              onChange={@updateForever} /> Never expires</label>
              </div>
            </div>
            <h3>Countries</h3>
            <CPA.Base.CountriesInput className='block-grid-lg-4 block-grid-md-3 block-grid-sm-2 block-grid-xs-1'
                                     value={@state.assetPackage.countries}
                                     onChange={@updateCountries} />
          </div>
        </div>
        <hr />
        <div className='text-right'>
          <CPA.Base.Link href='/' className='btn btn-default'>Cancel</CPA.Base.Link>
          <button className='btn btn-primary' onClick={@submit}>Save</button>
        </div>
      </div>
    </div>

  renderErrorsFor: (column) ->
    errors = @state.errors?[column]
    if errors?.length > 0
      <div className='red'>{errors.join(', ')}</div>

# @cjsx

class AppProvider extends React.Component
  constructor: (props) ->
    @flux = CPA.createFlux(
      ['StandardizedWorkStore', 'DesignerStore', 'ProductModelStore',
       'PriceTierStore'],
      ['setStandardizedWork', 'loadDesignersFromServer',
       'patchStandardizedWork', 'loadProductModelsFromServer',
       'loadPriceTiersFromServer', 'addStandardizedWorkPreview',
       'removeStandardizedWorkPreview', 'updateStandardizedWorkPreview',
       'submitStandardizedWork', 'addStandardizedWorkOutputFile',
       'removeStandardizedWorkOutputFile', 'updateStandardizedWorkOutputFile']
    )

  componentDidMount: ->
    @flux.actions.setStandardizedWork(@props.work_id)

  render: ->
    <App flux={@flux} />

App = React.createClass
  mixins: [CPA.FluxMixin, Fluxxor.StoreWatchMixin('StandardizedWorkStore')]

  getStateFromFlux: ->
    work: @getFlux().store('StandardizedWorkStore').get()
    errors: @getFlux().store('StandardizedWorkStore').getErrors()

  updateModel: (e) ->
    @getFlux().actions.patchStandardizedWork(model_id: e.value)

  updateDesigner: (e) ->
    @getFlux().actions.patchStandardizedWork(user_type: 'Designer', user_id: e.value)

  updateName: (e) ->
    @getFlux().actions.patchStandardizedWork(name: e.target.value)

  updatePriceTier: (e) ->
    @getFlux().actions.patchStandardizedWork(price_tier_id: e.value)

  updateFeatured: (e) ->
    @getFlux().actions.patchStandardizedWork(featured: e.target.checked)

  updateTag: (e) ->
    @getFlux().actions.patchStandardizedWork(tag_ids: e.value)

  updatePrintImage: (e, data) ->
    { id, url } = data.result.attachment
    @getFlux().actions.patchStandardizedWork(print_image_aid: id, print_image_url: url)

  addPreview: ->
    @getFlux().actions.addStandardizedWorkPreview()

  updatePreview: (preview, attributes) ->
    @getFlux().actions.updateStandardizedWorkPreview(preview, attributes)

  removePreview: (preview) ->
    @getFlux().actions.removeStandardizedWorkPreview(preview)

  addOutputFile: ->
    @getFlux().actions.addStandardizedWorkOutputFile()

  updateOutputFile: (outputFile, attributes) ->
    @getFlux().actions.updateStandardizedWorkOutputFile(outputFile, attributes)

  removeOutputFile: (outputFile) ->
    @getFlux().actions.removeStandardizedWorkOutputFile(outputFile)

  submit: ->
    @getFlux().actions.submitStandardizedWork(@state.work)

  renderGrayPrintImage: ->
    <div className='col-sm-3'>
      <div className='thumbnail'>
        <label className='control-label'>白墨用圖</label>
        <CPA.PopupImage href={@state.work.print_image_gray_url}>檢視圖片</CPA.PopupImage>
        <hr/>
        <img src={@state.work.print_image_gray_url} />
      </div>
    </div>

  render: ->
    return <div>Loading...</div> unless @state.work
    <div className='row'>
      <div className='col-xs-9'>
        <div className='well'>
          <h3>SKU cannot be changed! If you need a new SKU please create another work with correct product model</h3>
          <FormGroup errors={@state.errors} name='model'>
          <label className='control-label'>Model</label>
                <CPA.Common.ProductModelInput value={@state.work.model_id} onChange={@updateModel} />
          </FormGroup>
        </div>

        <FormGroup errors={@state.errors} name='user'>
          <label className='control-label'>Designer</label>
          <CPA.Common.DesignerInput value={@state.work.user_id} onChange={@updateDesigner} />
        </FormGroup>

        <FormGroup errors={@state.errors} name='name'>
          <label className='control-label'>Name</label>
          <input type='text' className='form-control' value={@state.work.name} onChange={@updateName} />
        </FormGroup>

        <FormGroup errors={@state.errors} name='price_tier'>
          <label className='control-label'>
            Price (keep it blank if you want use the original price of product model)
          </label>
          <CPA.Common.PriceTierInput value={@state.work.price_tier_id} onChange={@updatePriceTier} />
        </FormGroup>

        <div className='checkbox'>
          <label><input type='checkbox' checked={@state.work.featured} onChange={@updateFeatured} /> Featured</label>
        </div>

        <FormGroup errors={@state.errors} name='print_image'>
          <div className='row'>
            <div className='col-sm-3'>
              <div className='thumbnail'>
                <label className='control-label'>Print image</label>
                <CPA.PopupImage href={@state.work.print_image_url}>檢視圖片</CPA.PopupImage>
                <hr/>
                <CPA.Common.AttachmentInput defaultImage='http://placehold.it/100x100' value={@state.work.print_image_url}
                                            onChange={@updatePrintImage} />
              </div>
            </div>
            { @renderGrayPrintImage() if @state.work.print_image_gray_url }
          </div>

        </FormGroup>

        <p>Previews</p>
        <div className='row'>
          { _.reject(@state.work.previews_attributes, '_destroy').map (preview) =>
              <div className='col-sm-3'>
                <Preview preview={preview} onUpdate={@updatePreview} onRemove={@removePreview} />
              </div>
          }
          <div className='col-sm-3 center'>
            <button className='btn btn-default btn-lg' onClick={@addPreview}>Add</button>
          </div>
        </div>

        <p>Output files</p>
        <div className='row'>
          { _.reject(@state.work.output_files_attributes, '_destroy').map (file) =>
              <div className='col-sm-3'>
                <OutputFile file={file} onUpdate={@updateOutputFile} onRemove={@removeOutputFile} />
              </div>
          }
          <div className='col-sm-3 center'>
            <button className='btn btn-default btn-lg' onClick={@addOutputFile}>Add</button>
          </div>
        </div>
        <FormGroup errors={@state.errors} name='tag_ids'>
          <p>Tags</p>
          <CPA.Base.TagInput value={@state.work.tag_ids}
                             onChange={@updateTag} />
        </FormGroup>

        <button className='btn btn-primary' onClick={@submit}>Submit</button>
      </div>
      <div className='col-xs-3'>Editing <pre>{JSON.stringify(@state.work, null, '  ')}</pre></div>
    </div>

Preview = React.createClass
  updateFile: (e, data) ->
    { preview, onUpdate } = @props
    { id, url } = data.result.attachment
    onUpdate(preview, image_aid: id, image_url: url)

  updateKey: (e) ->
    { preview, onUpdate } = @props
    onUpdate(preview, key: e.target.value, position: e.target.value)

  updatePosition: (e) ->
    { preview, onUpdate } = @props
    onUpdate(preview, position: e.target.value)

  doRemove: ->
    { preview, onRemove } = @props
    onRemove(preview)

  render: ->
    { preview } = @props
    <div className='thumbnail'>
      <CPA.PopupImage href={preview.image_url}>檢視圖片</CPA.PopupImage>
      <hr/>
      <CPA.Common.AttachmentInput defaultImage='http://placehold.it/640x640' value={preview.image_url}
                                  onChange={@updateFile} />
      Key: <input type='text' className='form-control' placeholder='Key' value={preview.key} onChange={@updateKey} />
      Position: <input type='text' className='form-control' value={preview.position} onChange={@updatePosition} />
      <div className='caption'>
        <button className='btn btn-danger btn-xs' onClick={@doRemove}><i className='fa fa-remove' /></button>
      </div>
    </div>

OutputFile = React.createClass
  updateFile: (e, data) ->
    { file, onUpdate } = @props
    { id, url } = data.result.attachment
    onUpdate(file, file_aid: id, file_url: url)

  updateKey: (e) ->
    { file, onUpdate } = @props
    onUpdate(file, key: e.target.value)

  doRemove: ->
    { file, onRemove } = @props
    onRemove(file)

  render: ->
    { file } = @props
    <div className='thumbnail'>
      <CPA.PopupImage href={file.file_url}>檢視圖片</CPA.PopupImage>
      <hr/>
      <CPA.Common.AttachmentInput defaultImage='http://placehold.it/640x640' value={file.file_url}
                                  onChange={@updateFile} />
      <input type='text' className='form-control' placeholder='Key' value={file.key} onChange={@updateKey} />
      <div className='caption'>
        <button className='btn btn-danger btn-xs' onClick={@doRemove}><i className='fa fa-remove' /></button>
      </div>
    </div>

FormGroup = React.createClass
  render: ->
    inputClass = if @props.checkbox then 'checkbox' else 'form-group'
    hasError = @props.errors[@props.name]
    errorClass = 'has-error' if hasError

    <div className={[inputClass, errorClass].join(' ')}>
      {@props.children}
      <div className='text-danger'>{hasError if hasError}</div>
    </div>

@CPA.StandardizedWorkEditor.App = AppProvider

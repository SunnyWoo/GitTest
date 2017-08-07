StandardizedWorkStore = Fluxxor.createStore(
  initialize: ->
    @bindActions(
      SET_STANDARDIZED_WORK: @onSetStandardizedWork
      PATCH_STANDARDIZED_WORK: @onPatchStandardizedWork
      ADD_STANDARDIZED_WORK_PREVIEW: @onAddStandardizedWorkPreview
      UPDATE_STANDARDIZED_WORK_PREVIEW: @onUpdateStandardizedWorkPreview
      REMOVE_STANDARDIZED_WORK_PREVIEW: @onRemoveStandardizedWorkPreview
      ADD_STANDARDIZED_WORK_OUTPUT_FILE: @onAddStandardizedWorkOutputFile
      UPDATE_STANDARDIZED_WORK_OUTPUT_FILE: @onUpdateStandardizedWorkOutputFile
      REMOVE_STANDARDIZED_WORK_OUTPUT_FILE: @onRemoveStandardizedWorkOutputFile
      SET_STANDARDIZED_WORK_ERRORS: @onSetStandardizedWorkErrors
    )

  get: -> @work

  getErrors: -> @errors || {}

  onSetStandardizedWork: ({ @work }) ->
    @emitChange()

  onPatchStandardizedWork: ({ attributes }) ->
    @work = _.extend(@work, attributes)
    @emitChange()

  onAddStandardizedWorkPreview: ->
    @work.previews_attributes ||= []
    nextPreview = {_cid: _.uniqueId('preview') }
    @work.previews_attributes.push(nextPreview)
    @reposition()
    @emitChange()

  onUpdateStandardizedWorkPreview: ({ preview, attributes }) ->
    _.assign(preview, attributes)
    @emitChange()

  onRemoveStandardizedWorkPreview: ({ preview }) ->
    if preview._cid
      _.remove(@work.previews_attributes, preview)
    else
      preview._destroy = true
    @reposition()
    @emitChange()

  onAddStandardizedWorkOutputFile: ->
    @work.output_files_attributes ||= []
    nextOutputFile = {_cid: _.uniqueId('outputFile') }
    @work.output_files_attributes.push(nextOutputFile)
    @emitChange()

  onUpdateStandardizedWorkOutputFile: ({ outputFile, attributes }) ->
    _.assign(outputFile, attributes)
    @emitChange()

  onRemoveStandardizedWorkOutputFile: ({ outputFile }) ->
    if outputFile._cid
      _.remove(@work.output_files_attributes, outputFile)
    else
      outputFile._destroy = true
    @emitChange()

  onSetStandardizedWorkErrors: ({ @errors }) ->
    @emitChange()

  reposition: ->
    _.reject(@work.previews_attributes, '_destroy').forEach (preview, index) ->
      preview.position = index + 1

  emitChange: ->
    @emit('change')
)

CPA.fluxxorStores.StandardizedWorkStore = new StandardizedWorkStore()
CPA.fluxxorStoreClasses.StandardizedWorkStore = StandardizedWorkStore

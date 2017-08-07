StandardizedWorkActions =
  setStandardizedWork: (workId) ->
    $.getJSON('/admin/standardized_works/' + (workId || 'new'))
     .success (data) =>
        work = data.standardized_work
        work.previews_attributes = work.previews
        work.output_files_attributes = work.output_files
        @dispatch('SET_STANDARDIZED_WORK', work: work)

  patchStandardizedWork: (attributes) ->
    @dispatch('PATCH_STANDARDIZED_WORK', attributes: attributes)

  addStandardizedWorkPreview: ->
    @dispatch('ADD_STANDARDIZED_WORK_PREVIEW')

  updateStandardizedWorkPreview: (preview, attributes) ->
    @dispatch('UPDATE_STANDARDIZED_WORK_PREVIEW', preview: preview, attributes: attributes)

  removeStandardizedWorkPreview: (preview) ->
    @dispatch('REMOVE_STANDARDIZED_WORK_PREVIEW', preview: preview)

  addStandardizedWorkOutputFile: ->
    @dispatch('ADD_STANDARDIZED_WORK_OUTPUT_FILE')

  updateStandardizedWorkOutputFile: (outputFile, attributes) ->
    @dispatch('UPDATE_STANDARDIZED_WORK_OUTPUT_FILE', outputFile: outputFile, attributes: attributes)

  removeStandardizedWorkOutputFile: (outputFile) ->
    @dispatch('REMOVE_STANDARDIZED_WORK_OUTPUT_FILE', outputFile: outputFile)

  submitStandardizedWork: (work) ->
    promise = if work.id
                $.jsonPUT(CPA.path('/standardized_works/' + work.id), work: work)
              else
                $.jsonPOST(CPA.path('/standardized_works'), work: work)
    promise.success (data) -> Turbolinks.visit CPA.path('/standardized_works')
    promise.error (xhr) =>
      errors = JSON.parse(xhr.responseText)
      @dispatch('SET_STANDARDIZED_WORK_ERRORS', errors: errors)

_.assign(CPA.fluxxorActions, StandardizedWorkActions)

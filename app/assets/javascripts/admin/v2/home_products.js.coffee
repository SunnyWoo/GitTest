#= require select2

jQuery ($) ->
  $(document).on 'ready page:load', ->
    resultFormatter = (work) ->
      "<div class='media'>
        <div class='pull-left'>
          <img class='media-object' src='#{work.remote_cover_image_url}' width='50'>
        </div>
        <div class='media-body'>
          <h4 class='media-heading'>#{work.name} <small>#{work.model}</small></h4>
        </div>
       </div>"

    selectionFormatter = (work) -> work.name

    $('[data-work-selector]').each ->
      $this = $(this)
      $this.select2(
        placeholder: 'Select a work'
        ajax:
          url: $this.data('worksPath')
          dataType: 'json'
          quietMillis: 250
          data: (term, page) -> q: { name_start: term, work_type_eq: 0 }
          results: (data, page) -> results: data.works
        initSelection: (element, callback) ->
          url = $this.data('workPath')
          if url
            $.ajax(
              url: url
              dataType: 'json'
            ).done (data) -> callback(data.work)

        formatResult: resultFormatter
        formatSelection: selectionFormatter

      )

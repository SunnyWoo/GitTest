jQuery ($) ->
  impositionPositionTemplate = null
  impositionPredrillPointTemplate = null

  $(document).on 'ready page:load', ->
    $('.imposition-position-template').each ->
      $this = $(this)
      impositionPositionTemplate = $this.html()
      $this.remove()
    $('.imposition-predrill-point-template').each ->
      $this = $(this)
      impositionPredrillPointTemplate = $this.html()
      $this.remove()

  $(document).on 'click', '.imposition-editor-add-position', (e) ->
    $('.imposition-editor-positions').append(impositionPositionTemplate)
    e.preventDefault()

  $(document).on 'click', '.imposition-editor-remove-position', (e) ->
    $(e.target).parents('.row').first().remove()
    e.preventDefault()

  $(document).on 'click', '.imposition-editor-add-predrill-point', (e) ->
    $('.imposition-editor-predrill-points').append(impositionPredrillPointTemplate)
    e.preventDefault()

  $(document).on 'click', '.imposition-editor-remove-predrill-point', (e) ->
    $(e.target).parents('.row').first().remove()
    e.preventDefault()

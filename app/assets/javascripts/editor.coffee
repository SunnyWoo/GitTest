#= require rollbar-shim
#= require jquery_ujs
#= require plugins/jquery-ui-1.10.3.custom.min
#= require jquery-ui/effect-blind
#= require plugins/jquery.mCustomScrollbar.concat.min
#= require plugins/bootstrap-modal
#= require plugins/dropzone.min
#= require plugins/powerange
#= require plugins/spectrum
#= require plugins/fabric
#= require plugins/lodash.min
#= require plugins/jquery.jeditable
#= require plugins/jquery.charcounter
#= require common/gritter
#= require jquery.tooltipster.min
#= require_tree ./editor/ui_effect
#= require_tree ./editor/init
#= require_tree ./editor/preview
#= require_tree ./editor/app
#= require_tree ./editor/ui_effect
#= require search
#= require_tree ./web
#= require_self

$(document).on 'ready page:before-change', ->
	$('#loading_cover').removeClass('hide').css(
			width: $(window).width() + 'px'
			height: $(window).height() + 'px'
		)
	return

$(document).on 'ready page:load', ->
	$(window).resize ->
		$('#loading_cover').css(
			width: $(window).width() + 'px'
			height: $(window).height() + 'px'
			)
		return
	return

jQuery ($) ->
  $(document).on 'click', '.editable', ->
    $this = $(this)
    url = $this.data('translation-url')
    $this.editable(url,
      width: '180px'
      height: '41px'
      name: 'translator[value]'
      cssclass: 'edit-able'
      method: 'PUT'
      callback: (value, settings) ->
        json = JSON.parse(value)
        $this.text(json.value)
        return
      submit: '<button type="submit"><span class="edittools-check"></span></button>'
    )

    return
  return

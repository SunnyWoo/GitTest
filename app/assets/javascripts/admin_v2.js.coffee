#= require jquery
#= require jquery_ujs
#= require jquery.fancybox
#= require jquery.remotipart
#= require plugins/jquery-ui-1.10.3.custom.min
#= require plugins/jquery.lazyload
#= require nested_form_fields
#= require turbolinks
#= require ace/1.3/bootstrap
#= require ace/1.3/ace
#= require rails_env_favicon
#= require react
#= require react_ujs
#= require plugins/lodash_3.min
#= require immutable
#= require jquery.validate
#= require jquery.validate.additional-methods
#= require i18n
#= require i18n/translations
#= require highcharts/highcharts
#= require_tree ./common
#= require_tree ./admin/v2
#= require_tree ./admin/components


$(document).on 'change', 'fieldset.nested_campaign_campaign_images select', (e) ->
  $this = $(this)
  forArtwork = $this.closest('fieldset.nested_campaign_campaign_images').find('.campaign-image-for-artwork')
  if $this.val() is 'artwork'
    forArtwork.removeClass('hide')
  else
    forArtwork.addClass('hide')

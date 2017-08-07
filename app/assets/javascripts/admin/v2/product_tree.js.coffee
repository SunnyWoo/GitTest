#= require jquery.treeview/jquery.treeview

jQuery ($) ->
  $(document).on 'ready page:load', ->
    $('#product-tree').treeview()

$ ->
  $(document).on 'click', '.search_btn', ->
    $('#search_block').show('blind', {}, 900)
    $('#search_block input#search').focus()
    return false;

  $(document).on 'click', '.close_search', ->
    $('#search_block').hide('blind', {}, 550)

  $(document).on 'click', '#search_block input#search', ->
    return false

  $(document).on 'click', '#search_block', ->
    $('#search_block').hide('blind', {}, 550)

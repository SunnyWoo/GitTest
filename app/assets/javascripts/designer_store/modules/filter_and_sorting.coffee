class FilterAndSorting
  constructor: ($widget, options = { afterRearrange: () -> }) ->
    @$widget = $widget
    @options = options

    @$category = @$widget.find('[data-widget=filter-category]')
    @$model = @$widget.find('[data-widget=filter-model]')
    @$currentModel = @$model.find('[data-current]')
    @$modelOptions = @$model.find('[data-filter]')

    @$sortWidget = @$widget.find('[data-widget-sort]')
    @$sortByTime = @$widget.find('[data-sorting-time]')
    @$sortByPrice = @$widget.find('[data-sorting-price]')

    @$productList = @$widget.find('[data-product-list]')
    @$products = @$productList.find('[data-product]')

    @$time = @$widget.find('[data-widget=sort-time]')
    @$price = @$widget.find('[data-widget=sort-price]')

    @initCategoryFilter()
    @initModelFilter()
    @initSorting()

  initCategoryFilter: ->
    self = this
    $categories = @$category.find('[data-filter]')

    handleClickCategory = ($category) ->
      $categoryKey = $category.data('filter')
      $categories.removeClass('is-active')
      $category.addClass('is-active')
      self.setCategoryFilter($categoryKey)
      self.$modelOptions.hide()
      $categoryModels = self.$model.find("[data-category-key=#{$categoryKey}]")
      $categoryModels.show()
      self.setModelFilter($categoryModels.first().data('filter'))

    handleClickCategory($categories.first())

    $categories.each ->
      $(this).click ->
        handleClickCategory($(this))

  initModelFilter: ->
    self = this

    handleClickModelMenu = ($modelOption) ->
      self.$modelOptions.removeClass('is-active')
      $modelOption.addClass('is-active')
      self.setModelFilter($modelOption.data('filter'))

    @$currentModel.click ->
      isOpen = self.$model.hasClass('is-open')
      if isOpen then self.closeModelMenu() else self.openModelMenu()

    @$modelOptions.each ->
      $(this).click ->
        handleClickModelMenu($(this))
        self.closeModelMenu()

  initSorting: ->
    @setTimeSorting()

    @$sortByTime.click =>
      @setTimeSorting()
    @$sortByPrice.click =>
      @setPriceSorting()

  setCategoryFilter: (filter) ->
    @$widget.attr('data-filter-category', filter)
    @rearrangeItems()

  setModelFilter: (filter) ->
    @$widget.attr('data-filter-model', filter)
    @$currentModel.text(
      @$model.find("[data-filter='#{filter}']").text()
    )

    @rearrangeItems()

  setTimeSorting: ->
    if @sorting() is 'newest'
      @setSorting('mostExpensive')
    else
      @setSorting('newest')

  setPriceSorting: ->
    if @sorting() is 'cheapest'
      @setSorting('mostExpensive')
    else if @sorting() is 'mostExpensive'
      @setSorting('cheapest')
    else
      @setSorting('mostExpensive')

  setSorting: (sorting) ->
    if [ 'newest', 'cheapest', 'mostExpensive' ].indexOf(sorting) is -1
      sorting = 'newest'

    @$widget.attr('data-sorting', sorting)
    @$sortWidget.removeClass('is-newest is-cheapest is-mostExpensive')
    @$sortWidget.addClass("is-#{sorting}")

    @rearrangeItems()

  categoryFilter: ->
    @$widget.attr('data-filter-category')

  modelFilter: ->
    @$widget.attr('data-filter-model')

  sorting: ->
    @$widget.attr('data-sorting')

  openModelMenu: ->
    @$model.addClass('is-open')

  closeModelMenu: ->
    @$model.removeClass('is-open')

  rearrangeItems: ->
    sorting = @sorting()
    @$products.hide()

    visibleProducts = @$products.sort( (first, second) ->
      firstTime = parseInt(first.getAttribute('data-time'))
      secondTime = parseInt(second.getAttribute('data-time'))
      firstPrice = parseInt(first.getAttribute('data-price'))
      secondPrice = parseInt(second.getAttribute('data-price'))

      if sorting is 'mostExpensive'
        return if firstPrice > secondPrice then -1 else 1
      else if sorting is 'cheapest'
        return if firstPrice <= secondPrice then -1 else 1
      else if sorting is 'newest'
        return if firstTime >= secondTime then -1 else 1
      else
        return 0
    )
    .detach().appendTo(@$productList)
    .filter("[data-category='#{@categoryFilter()}']")
    .filter("[data-model='#{@modelFilter()}']")
    .show()

    @options.afterRearrange(visibleProducts)
    visibleProducts

window.FilterAndSorting = FilterAndSorting

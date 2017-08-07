# @cjsx

@CPA.Base.Pagination = React.createClass
  propTypes:
    onClick: React.PropTypes.func

  theFirst: (key="theFirst") ->
    <li key={key} className="click">
      <a href="javascript:void(0)" onClick={@changePage(1).bind(@)}>1</a>
    </li>

  theLast: (key="theLast") ->
    <li key={key} className="click">
      <a href="javascript:void(0)" onClick={@changePage(@props.page.total_pages).bind(@)}>{@props.page.total_pages}</a>
    </li>

  dotHTML: (key="dotHTML") ->
    <li key={key} className="disabled">
      <a href="javascript:void(0)" >...</a>
    </li>

  getPrevList: (max)->
    frontHTML = []
    front = @props.page.current_page - max

    if @props.page.current_page > max + 1
      frontHTML.push(@theFirst())
    if @props.page.current_page > max + 2
      frontHTML.push(@dotHTML('dotHTMLFront'))

    while front < @props.page.current_page
      if front > 0
        obj =
          <li key={front} className="click">
            <a href="javascript:void(0)" onClick={@changePage(front).bind(@)} >{front}</a>
          </li>
        frontHTML.push(obj)
      front++
    frontHTML

  getCurrent: ->
    current =
      <li className="active">
        <a href="javascript:void(0)" >
          {@props.page.current_page}
        </a>
      </li>
    current

  getNextList: (max) ->
    backHTML = []
    backCount = 0
    back = @props.page.current_page + max

    while back > @props.page.current_page
      if back < @props.page.total_pages
        obj =
          <li key={back} className="click">
            <a href="javascript:void(0)" onClick={@changePage(back).bind(@)} > {back} </a>
          </li>
        backHTML.unshift(obj)
        backCount++
      back--

    if @props.page.total_pages - @props.page.current_page > max + 1
      backHTML.push(@dotHTML('dotHTMLBack'))
    if backCount <= max and @props.page.current_page isnt @props.page.total_pages
      backHTML.push(@theLast())
    backHTML

  checkClass: ->
    if @props.page.previous_page or @props.page.prev_page
      prevOk = 'click'
    else
      prevOk = 'disabled'

    if @props.page.next_page
      nextOk = 'click'
    else
      nextOk = 'disabled'

    prevOk: prevOk
    nextOk: nextOk

  changePage: (page, active=true) -> (e) ->
    if active isnt 'disabled'
      @props.onClick?(page: page)

  render: ->
    rows = []

    rows.push(@getPrevList(4))
    rows.push(@getCurrent())
    rows.push(@getNextList(4))

    <nav>
      <ul className="pagination">
        <li key="f" className={@checkClass().prevOk}>
          <a href="javascript:void(0)" onClick={@changePage(@props.page.prev_page, @checkClass().prevOk).bind(@)} > Prev </a>
        </li>
        {rows}
        <li key="b" className={@checkClass().nextOk}>
          <a href="javascript:void(0)" onClick={@changePage(@props.page.next_page, @checkClass().nextOk).bind(@)} > Next </a>
        </li>
      </ul>
    </nav>

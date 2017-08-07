#= require ./cmdp_admin

# 2014-12-20 00:00:00 +0800..2014-12-26 23:59:59 +0800
# setting default filter
window.CmdpAdmin.getLastSevenDaysKey = ->
  now = new Date()
  timeZone = (now.getTimezoneOffset() / 60) * -1
  nYY = now.getFullYear()
  nMM = now.getMonth()+1
  nDD = now.getDate()
  sevenDaysAgo = now - 1000 * 60 * 60 * 24 * 7
  start = new Date(sevenDaysAgo)
  sYY = start.getFullYear()
  sMM = start.getMonth()+1
  sDD = start.getDate()
  key = sYY + '-' + sMM + '-' + sDD + ' 00:00:00 +0800..' + nYY + '-' + nMM + '-' + nDD + ' 23:59:59 +0800'

window.CmdpAdmin.options = [{
                  platform: 'created_at'
                  platformName: 'Created Date'
                  value: CmdpAdmin.getLastSevenDaysKey()
                  valueName: 'Last 7 days'
                }]

# React order search 進入點
window.CmdpAdmin.Filters = React.createClass
  getInitialState: ->
    filterShow: false
    newOptions: CmdpAdmin.options

  onClick: ->
    @setState
      filterShow: true
    return

  onAddFilter: (platformName, platform, valueName, value)->
    data =
      'platformName': platformName
      'platform': platform
      'valueName': valueName
      'value': value
    CmdpAdmin.options.push(data)
    @setState
      filterShow: false
      newOptions: CmdpAdmin.options
    return

  onDelete: (value)->
    CmdpAdmin.options = []
    for x in @state.newOptions
      if x.value isnt value
        data =
          'platformName': x.platformName
          'platform': x.platform
          'valueName': x.valueName
          'value': x.value
        CmdpAdmin.options.push(data)
      @setState
        newOptions: CmdpAdmin.options
    return

  render: ->
    `<ul>
      <CmdpAdmin.FilterDefault name='Order No.' />
      <CmdpAdmin.FilterDefault name='Phone No.' />
      <CmdpAdmin.FilterDefault name='Shipping ID' />
      <CmdpAdmin.FilterDefault name='Email' />
      <CmdpAdmin.AppendOption filters={this.state.newOptions} onDelete={this.onDelete} />
      <CmdpAdmin.AddFilter hasSelected={this.state.newOptions} filterShow={this.state.filterShow} onAddFilter={this.onAddFilter} />
      <CmdpAdmin.AddFilterButton onClick={this.onClick} />
    </ul>`


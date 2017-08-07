#= require d3
#= require c3

$stickerTypeChart = $('#sticker_useage_trend')
columns = $stickerTypeChart.data('columns')
axisX = $stickerTypeChart.data('axisX')
columns.unshift axisX

chartA = c3.generate
  bindto: '#sticker_useage_trend'
  data:
    x: 'x'
    columns: columns
  axis:
    y:
      label:
        text: 'Usage Count'
        position: 'outer-middle'
    x:
      label:
        text: 'Date'
        position: 'outer-middle'
      type : 'timeseries'
      tick:
        format: "%m-%d"

$stickerUsageGrowthTrendChart = $('#sticker_usage_growth_trend')
columns = $stickerUsageGrowthTrendChart.data('columns')
growthOriginalColumns = Object.assign([], columns)
axisX = $stickerUsageGrowthTrendChart.data('axisX')
columns.unshift axisX

chartB = c3.generate
  bindto: '#sticker_usage_growth_trend'
  data:
    columns: columns
  axis:
    y:
      label:
        text: 'Marginal Growth'
        position: 'outer-middle'
    x:
      label:
        text: 'Date Range'
        position: 'outer-middle'
      type : 'category'
      categories: axisX
  grid:
    y:
      lines: [{value: 0, text: 'Slope: 0'}]



$stickerUsageProportionChart = $('#sticker_usage_proportion')
columns = $stickerUsageProportionChart.data('columns')
propotionOriginalColumns = Object.assign([], columns)
axisX = $stickerUsageProportionChart.data('axisX')
columns.unshift axisX

chartC = c3.generate
  bindto: '#sticker_usage_proportion'
  data:
    x: 'x'
    columns: columns
    type: 'bar'
    groups: [(column[0] for column in propotionOriginalColumns)]
  axis:
    y:
      label:
        text: 'Accumulated Useage Count'
        position: 'outer-middle'
    x:
      label:
        text: 'Date'
        position: 'outer-middle'
      type : 'timeseries'
      tick:
        format: "%m-%d"

$stickerUsageCountProportionChart = $('#sticker_usage_count_propotion')
columns = $stickerUsageCountProportionChart.data('columns')

chartD = c3.generate
  bindto: '#sticker_usage_count_propotion'
  data:
    columns: columns
    type: 'pie'

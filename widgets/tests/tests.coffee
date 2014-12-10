class Dashing.Tests extends Dashing.Widget

  @accessor 'passing', ->
    "#{parseInt(@get('passed'))} passing"

  @accessor 'failing', ->
    "#{parseInt(@get('failed'))} failing"

  @accessor 'ignored', ->
    "#{parseInt(@get('not_run'))} ignored"

  @accessor 'difference', ->
    if @get('last_passed')
      last_passed = parseInt(@get('last_passed'))
      passed = parseInt(@get('passed'))
      if last_passed != 0
        diff = Math.abs(Math.round((passed - last_passed) / last_passed * 100))
        "#{diff}%"
    else
      ""

  @accessor 'arrow', ->
    if @get('last_passed')
      if parseInt(@get('passed')) > parseInt(@get('last_passed')) then 'icon-arrow-up' else 'icon-arrow-down'

  ready: ->
    @ctx = $(@node).find('.chart-area')[0].getContext("2d");
    @doughnutData = [

      # Add the passing tests
      value: parseInt(@get('passed'))
      color: "#56BA3A"
      highlight: "#56BA3A"
      label: "Passing"
    ,
      # Add the ignored tests
      value: parseInt(@get('ignored'))
      color: "#E6BB32"
      highlight: "#E6BB32"
      label: "Ignored"
    ,
      # Add the failed tests
      value: parseInt(@get('failed'))
      color:"#EE4042"
      highlight: "#EE4042"
      label: "Failed"
    ,
      # Add the not run if you want a gap
      value: parseInt(@get('not_run'))
      color: "#222222"
      highlight: "#222222"
      label: "Not Run"
    ]

    @myDoughnut = new Chart(@ctx).Doughnut(@doughnutData,
      responsive: true,
      segmentShowStroke : false
    )

    # Set the widget background colour needs to go red when tests fail
    if @get('failed')
      failed = parseInt(@get('failed'))
      if failed != 0
        $(@node).css('background-color', '##EE4042')
      else
        $(@node).css('background-color', '#222222')

    else
      $(@node).css('background-color', '#222222')

  onData: (data) ->

    if @myDoughnut
      @myDoughnut.segments[0].value =  parseInt(@get('passed'))
      @myDoughnut.segments[1].value =  parseInt(@get('ignored'))
      @myDoughnut.segments[2].value =  parseInt(@get('failed'))
      @myDoughnut.segments[3].value =  parseInt(@get('not_run'))
      @myDoughnut.update();

    if data.status
      # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''
      # add new class
      $(@get('node')).addClass "status-#{data.status}"



$("body").on "chocSliderLoaded", (evt) ->
  console.log "LOADED"
  firstChoc = $(".choc-wrapper")[0]
  tour = $("#tourGuide")
  
  tour.find('li').each (idx, ele) ->
    thisId = idx + "____for_tour"
    switch $(ele).data().tour
      when 'slider'
        slider = $(firstChoc).find('.slider-container')[0]
        $(slider).attr('id', thisId)
        $(ele).attr('data-id', thisId)
      when 'editor'
        slider = $(firstChoc).find('.CodeMirror')[0]
        $(slider).attr('id', thisId)
        $(ele).attr('data-id', thisId)
      when 'canvas'
        slider = $(firstChoc).find('.canvas-container')[0]
        $(slider).attr('id', thisId)
        $(ele).attr('data-id', thisId)

  $("#tourGuide").joyride
    'tipLocation': 'bottom'

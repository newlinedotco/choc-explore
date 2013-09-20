$("body").on "chocSliderLoaded", (evt) ->
  firstChoc = $(".choc-wrapper")[0]
  tour = $("#tourGuide")
  window.tourCallbacks = {}
  idPostfix = "____for_tour"

  tour.find('li').each (idx, ele) ->
    thisId = idx + idPostfix
    console.log $(ele).data().tour
    switch $(ele).data().tour
      when 'slider'
        slider = $(firstChoc).find('.slider-container .ui-slider-handle')[0]
        $(slider).attr('id', thisId)
        $(ele).attr('data-id', thisId)
        window.tourCallbacks[thisId] = (idx, tip) ->
          ## Show slider
          handle = $(slider).find('.ui-slider-handle')[0]
      when 'editor'
        slider = $(firstChoc).find('.CodeMirror')[0]
        $(slider).attr('id', thisId)
        $(ele).attr('data-id', thisId)
        window.tourCallbacks[thisId] = (idx, tip) ->
          console.log "editor", $(tip)
      when 'numberslider'
        slider = $(firstChoc).find('.CodeMirror-widget')[1]
        $(slider).attr('id', thisId)
        $(ele).attr('data-id', thisId)
        window.tourCallbacks[thisId] = (idx, tip) ->
          # Here
      when 'canvas'
        slider = $(firstChoc).find('.canvas-container')[0]
        $(slider).attr('id', thisId)
        $(ele).attr('data-id', thisId)
        window.tourCallbacks[thisId] = (idx, tip) ->
          console.log "canvas", idx

  $("#tourGuide").joyride
    'tipLocation': 'bottom'
    'preStepCallback': (idx, tip) ->
      cb = window.tourCallbacks[idx+idPostfix]
      if cb
        cb(idx, tip)
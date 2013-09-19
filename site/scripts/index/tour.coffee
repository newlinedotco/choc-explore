$("body").on "chocSliderLoaded", (evt) ->
  firstChoc = $(".choc-wrapper")[0]
  tour = $("#tourGuide")
  window.tourCallbacks = {}
  idPostfix = "____for_tour"

  tour.find('li').each (idx, ele) ->
    thisId = idx + idPostfix
    switch $(ele).data().tour
      when 'slider'
        slider = $(firstChoc).find('.slider-container')[0]
        $(slider).attr('id', thisId)
        $(ele).attr('data-id', thisId)
        window.tourCallbacks[thisId] = (idx, tip) ->
          console.log "slider", idx
      when 'editor'
        slider = $(firstChoc).find('.CodeMirror')[0]
        $(slider).attr('id', thisId)
        $(ele).attr('data-id', thisId)
        window.tourCallbacks[thisId] = (idx, tip) ->
          console.log "editor", idx
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
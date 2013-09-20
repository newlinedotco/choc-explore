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
        slider = $(firstChoc).find('.slider-container')[0]
        $(slider).attr('id', thisId)
        $(ele).attr('data-id', thisId)
        window.tourCallbacks[thisId] = (idx, tip) ->
          ## Show slider
          handle = $(slider).find('.ui-slider-handle')[0]
          downup = (start, cb) ->
            animate = (percent) ->
              $(handle).animate({
                left: percent
              }, 500, 'linear', () ->
                setTimeout(
                  () -> animate('100%'), 
                500)
              )
            setTimeout(
              () -> 
                animate(start)
                if (cb)
                  cb()
              , 500)
          downup '60%', () ->
            downup '80%', () ->
              # This is not sexy
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
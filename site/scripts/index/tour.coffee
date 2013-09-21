window.__tour_loaded = false
$("body").on "chocSliderLoaded", (evt) ->
  return if (__tour_loaded)
  window.__tour_loaded = true
  firstChoc = $(".choc-wrapper")[0]
  tour = $("#tourGuide")
  window.__tooltipsForTour = {}
  idPostfix = "____for_tour"
  buttonCallbackPostfix = "___on_tour_callback_"

  makeHtml = (ele, idx, last, cb) ->
    html = $(ele).html()
    callbackId = buttonCallbackPostfix + idx
    window[callbackId] = () ->
      thisTip = window.__tooltipsForTour[idx]
      thisTip.hide()
      nextTip = window.__tooltipsForTour[idx + 1]
      if nextTip
        nextTip.show()
      else
        if cb?
          cb()

    html += """
<button value='Next' onclick="#{callbackId}()">Next</button>
    """
    html

  makeTooltip = (ele, target, idx, cb) ->
    opts =
      delay: 500
      showOn: null
      target: $(target)
      tipJoint: $(ele).data('tipjoint') || 'top right'
      targetJoint: $(ele).data('targetjoint') || 'bottom left'
      title: $(ele).data('title') || null
      borderRadius: 5
      style: "dark"
      group: "tourGuide"
      removeElementsOnHide: false
    tip = $(ele).opentip makeHtml(ele, idx, cb), opts
    window.__tooltipsForTour[idx] = tip
    tip.hide()
    tip

  tour.find('li').each (idx, ele) ->
    thisId = idx + idPostfix
    tele = $(firstChoc).find($(ele).data().tour)[0]
    if tele
      makeTooltip ele, tele, idx, () ->

  window.__tooltipsForTour[0].show();
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
        nextTip.onShow()
      else
        if cb?
          cb()

    html += """
<button value='Next' onclick="#{callbackId}()">Next</button>
    """ #"
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
    tipData = $(ele).data()
    tip.onShow = () -> eval(tipData.onshow)
    window.__tooltipsForTour[idx] = tip
    tip.hide()
    tip

  tour.find('li').each (idx, ele) ->
    thisId = idx + idPostfix
    tele = $(firstChoc).find($(ele).data().tour)[0]
    if tele
      makeTooltip ele, tele, idx, () ->

  # window.__tooltipsForTour[0].show()
  # window.__tooltipsForTour[0].onShow()

# $(document).ready () ->
#   editor = window.parabolaEditor
#   console.log "we're ready for everything", editor
#   position = { x : 47 }

#   tween1 = new TWEEN.Tween(position)
#     .to({x: 20}, 4000)
#     .easing(TWEEN.Easing.Quadratic.InOut)
#     .onUpdate () ->
#       frame = Math.round(position.x)
#       editor.onSliderChange({originalEvent: true}, {value: frame})
#       editor.slider.slider('value', frame)
#     .start()
#     .delay(2000)

#   tween2 = new TWEEN.Tween(position)
#     .to({x: 47}, 4000)
#     .easing(TWEEN.Easing.Quadratic.InOut)
#     .onUpdate () ->
#       frame = Math.round(position.x)
#       editor.onSliderChange({originalEvent: true}, {value: frame})
#       editor.slider.slider('value', frame)

#   tween1.chain(tween2)

#   animate = () ->
#     requestAnimationFrame( animate )
#     TWEEN.update()
#   animate()


$(document).ready () ->
  setTourImagePositions = () ->
    slider = $("#choc-editor-for-parabola").find(".controls-container")

    dragThis = $("#drag-this")
    dragThis.css("position", "absolute")
      .css("top", slider.offset().top - 90)
      .css("left", slider.offset().left + slider.width() - 5)

    numberToDrag = $("#choc-editor-for-parabola").find("#interactive_3")
    andDragThis = $("#and-drag-this")
    andDragThis.css("position", "absolute")
      .css("top", numberToDrag.offset().top + 20)
      .css("left", numberToDrag.offset().left - 70)

  $(window).resize () -> setTourImagePositions()
  setTourImagePositions()


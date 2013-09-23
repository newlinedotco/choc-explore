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

    fadeout = _.once(() ->
        dragThis.fadeOut(3000)
        andDragThis.fadeOut(3000))

    editor = window.parabolaEditor
    editor.codemirror.on "mousedown", () ->
      fadeout()

  $(window).resize () -> setTourImagePositions()
  setTourImagePositions()


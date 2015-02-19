Backbone = require "backbone"
Artlist = require "./artlist"

class ReadIntroView extends Backbone.View
  module.exports = this

  el: "div.intro"

  initialize: ->
    @activate()

  events:
    "input div.attribute": "attributeInputWasChanged"
    "submit": "formWasSubmitted"

  render: =>
    template = require "../templates/read_intro.html"
    @el.innerHTML = template()

  activate: =>
    @render()
    @el.style.height = "0px"
    @el.classList.add "activated"
    height = @$("div.read_intro").height()
    Function.delay 0, =>
      @el.classList.add "opening"
      @el.style["height"] = "#{height}px"
      @el.style["transition-duration"] = "#{height}ms"
    $(@el).on "transitionend", (event) =>
      if event.target is @el and event.propertyName is "height"
        $(@el).off "transitionend"
        @el.classList.remove "opening"
        @el.style["height"] = "auto"
        @el.style["transition-duration"] = "0"
        Backbone.history.once "route", @deactivateOnReturnToIndex

  deactivate: =>
    Backbone.history.off "route", @deactivate
    $(@el).off()
    @el.classList.remove "activated"
    @el.innerHTML = ""

  deactivateOnReturnToIndex: (router, destination) =>
    if destination is "index" then @deactivate()

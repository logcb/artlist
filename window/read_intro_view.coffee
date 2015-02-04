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
    @el.classList.add("activated")
    # @el.scrollIntoView()
    $(@el).on "transitionend", (event) =>
      if event.target is @el and event.propertyName is "height"
        $(@el).off "transitionend"
        Backbone.history.once "route", @deactivateOnReturnToIndex

  deactivate: =>
    Backbone.history.off "route", @deactivate
    $(@el).off()
    $(@el).removeClass "activated"

  deactivateOnReturnToIndex: (router, destination) =>
    @deactivate() if destination in ["index", "select"]

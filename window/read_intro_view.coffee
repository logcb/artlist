Backbone = require "backbone"
Artlist = require "./artlist"

class ReadIntroView extends Backbone.View
  module.exports = this

  el: "div.intro"

  initialize: ->
    @activate()
    Function.delay 1, => Backbone.history.once "route", @remove

  events:
    "input div.attribute": "attributeInputWasChanged"
    "submit": "formWasSubmitted"

  render: =>
    template = require "../templates/read_intro.html"
    @el.innerHTML = template()

  activate: =>
    $(@el).addClass "activated"
    @el.scrollIntoView()
    $(@el).on "transitionend", (event) =>
      if event.target is @el and event.propertyName is "height"
        $(@el).off "transitionend"
        @el.querySelector("input[name=title]").focus()

  deactivate: =>
    $(@el).addClass "expired"
    $(@el).on "transitionend", (event) =>
      if event.target is @el and event.propertyName is "height"
        $(@el).off "transitionend"
        @remove()

  remove: =>
    $(@el).off()
    $(@el).remove()
    Backbone.history.off "route", @deactivate

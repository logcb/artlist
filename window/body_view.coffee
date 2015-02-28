Backbone = require "backbone"

class BodyView extends Backbone.View
  module.exports = this

  el: "body"

  initialize: ->
    @render()
    Artlist.operator.on "change:permit", @render

  render: =>
    if Artlist.operator.isPermittedToMakeChanges()
      @el.classList.add("editing")
    else
      @el.classList.remove("editing")

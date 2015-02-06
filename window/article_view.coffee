Backbone = require "backbone"
Artlist = require "./artlist"

class ArticleView extends Backbone.View
  module.exports = this

  initialize: ->
    @activate()

  events:
    "input div.description [contenteditable]": "descriptionInputWasChanged"

  activate: =>
    @el.classList.remove("compacted")
    @el.classList.add("activated")

  descriptionInputWasChanged: (event) ->
    @model.set "description", event.target.innerHTML
    @model.save()

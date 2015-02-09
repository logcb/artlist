Backbone = require "backbone"
Artlist = require "./artlist"

class ArticleView extends Backbone.View
  module.exports = this

  initialize: ->
    @activate()
    @enableEditing() if window.location.hostname is "artlist.dev"

  events:
    "input div.title[contenteditable]": "titleInputWasChanged"
    "input div.description [contenteditable]": "descriptionInputWasChanged"

  activate: =>
    @el.classList.remove("compacted")
    @el.classList.add("activated")

  titleInputWasChanged: (event) ->
    @model.set "title", event.target.innerHTML
    @model.save()

  descriptionInputWasChanged: (event) ->
    @model.set "description", event.target.innerHTML
    @model.save()

  enableEditing: ->
    for editable in @el.querySelectorAll("[contenteditable=false]")
      editable.setAttribute "contenteditable", "plaintext-only"

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
    "input div.time[contenteditable]": "timeInputWasChanged"

  activate: =>
    @el.classList.remove("compacted")
    @el.classList.add("activated")

  titleInputWasChanged: (event) ->
    @model.set "title", event.target.innerText
    @model.save()

  descriptionInputWasChanged: (event) ->
    @model.set "description", event.target.innerText
    @model.save()

  timeInputWasChanged: (event) ->
    @model.set "start_time", @formatInputTimeForModel(event.target.innerText)
    @model.save()

  enableEditing: ->
    for editable in @el.querySelectorAll("[contenteditable=false]")
      editable.setAttribute "contenteditable", "plaintext-only"

  formatInputTimeForModel: (time) ->
    [match, hour, minute, meridian] = /([0-9]+):([0-9]+)(AM|PM)/.exec(time)
    if meridian is "AM"
      hour = "0#{hour}" if hour.length is 1
      "#{hour}:#{minute}"
    else
      hour = String(Number(hour)+12)
      hour = "0#{hour}" if hour.length is 1
      "#{hour}:#{minute}"

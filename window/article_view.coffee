Backbone = require "backbone"
BasicView = require "./basic_view"
Artlist = require "./artlist"

class ArticleView extends BasicView
  module.exports = this

  template: require "../templates/article.html"

  initialize: ->
    @activate()
    @model.on "change", (event) =>
      console.info "Saving article #{@model.id}"
      console.info @model.save()
    @model.on "error", (error) =>
      console.error "Article #{@model.id} error!"
      console.error @model.attributes
      console.error error
    @enableEditing() if window.location.hostname isnt "artlist.website"

  render: ->
    @el.innerHTML = @renderTemplate({article:@model})
    @enableEditing() if window.location.hostname isnt "artlist.website"

  events:
    "input div.title[contenteditable]": "titleInputWasChanged"
    "input div.cost[contenteditable]": "costInputWasChanged"
    "input div.description pre[contenteditable]": "descriptionInputWasChanged"
    "input div.time[contenteditable]": "timeInputWasChanged"
    "change select.one.category": "categoryInputWasChanged"
    "click button.publish": "publishArticle"
    "click button.trash": "moveArticleToTrash"

  publishArticle: (event) ->
    event.preventDefault()
    @model.set "published_at", (new Date).toJSON()

  moveArticleToTrash: (event) ->
    event.preventDefault()
    @model.set "trashed_at", (new Date).toJSON()

  activate: =>
    @el.classList.remove("compacted")
    @el.classList.add("activated")

  categoryInputWasChanged: (event) ->
    console.info(event.target.value)
    @model.set "category", event.target.value
    @render()

  titleInputWasChanged: (event) ->
    @model.set "title", event.target.innerText

  costInputWasChanged: (event) ->
    @model.set "cost", event.target.innerText

  descriptionInputWasChanged: (event) ->
    console.info "descriptionInputWasChanged", event
    @model.set "description", event.target.innerText

  timeInputWasChanged: (event) ->
    @model.set "time", @formatInputTimeForModel(event.target.innerText)

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

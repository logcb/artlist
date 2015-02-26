{debounce} = require "underscore"
Backbone = require "backbone"
BasicView = require "./basic_view"
Artlist = require "./artlist"

class ArticleView extends BasicView
  module.exports = this

  template: require "../templates/article.html"

  initialize: ->
    @activate()
    @model.on "change:title", debounce @saveArticle, 100
    @model.on "change:venue", debounce @saveArticle, 100
    @model.on "change:description", debounce @saveArticle, 100
    @model.on "change:date", debounce @saveArticle, 100
    @model.on "change:time", debounce @saveArticle, 100
    @model.on "change:cost", debounce @saveArticle, 100
    @model.on "error", @articleHasError
    @enableEditing() if window.location.hostname isnt "artlist.website"

  events:
    "input div.title[contenteditable]": "titleInputWasChanged"
    "input div.venue[contenteditable]": "venueInputWasChanged"
    "input div.time[contenteditable]": "timeStringInputWasChanged"
    "input div.cost[contenteditable]": "costInputWasChanged"
    "input div.description pre[contenteditable]": "descriptionInputWasChanged"
    "change select.one.category": "categoryInputWasChanged"
    "change input[type=date]": "dateInputWasChanged"
    "change input[type=time]": "timeInputWasChanged"
    "click button.publish": "publishArticle"
    "click button.pending": "moveArticleToPendingBucket"
    "click button.trash": "moveArticleToTrashBucket"

  render: ->
    @el.innerHTML = @renderTemplate({article:@model})
    @enableEditing() if Artlist.operator.isPermittedToMakeChanges()

  activate: =>
    @el.classList.remove("compacted")
    @el.classList.add("activated")

  categoryInputWasChanged: (event) ->
    console.info(event.target.value)
    @model.set "category", event.target.value
    @render()

  timeInputWasChanged: (event) ->
    console.info(event.target.value)
    @model.set "time", event.target.value
    @render()

  titleInputWasChanged: (event) ->
    @model.set "title", event.target.innerText

  venueInputWasChanged: (event) ->
    @model.set "venue", event.target.innerText

  timeStringInputWasChanged: (event) ->
    @model.set "time", @formatInputTimeForModel(event.target.innerText)

  costInputWasChanged: (event) ->
    @model.set "cost", event.target.innerText

  descriptionInputWasChanged: (event) ->
    console.info "descriptionInputWasChanged", event
    @model.set "description", event.target.innerText

  publishArticle: (event) ->
    event.preventDefault()
    @model.set "published_at", (new Date).toJSON()

  moveArticleToTrashBucket: (event) ->
    console.info "moveArticleToTrashBucket"
    event.preventDefault()
    @model.set "trashed_at", (new Date).toJSON()
    @model.save()

  moveArticleToPendingBucket: (event) ->
    event.preventDefault()
    @model.unset "trashed_at"
    @model.unset "published_at"

  saveArticle: =>
    console.info "Saving article #{@model.id}"
    @model.save()

  articleHasError: (error ) =>
    console.error "Article #{@model.id} error!"
    console.error @model.attributes
    console.error error

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

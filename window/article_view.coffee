BasicView = require "./basic_view"
{debounce} = require "underscore"

class ArticleView extends BasicView
  module.exports = this

  template: require "../templates/article.html"

  initialize: ->
    @activate()
    @model = Artlist.index.get @el.id.replace("ART", "")
    @model.on "change:title", debounce @saveArticle, 100
    @model.on "change:venue", debounce @saveArticle, 100
    @model.on "change:description", debounce @saveArticle, 100
    @model.on "change:date", debounce @saveArticle, 100
    @model.on "change:time", debounce @saveArticle, 100
    @model.on "change:cost", debounce @saveArticle, 100
    @model.on "error", @articleHasError

  events:
    "input div.title[contenteditable]": "titleInputWasChanged"
    "input div.venue[contenteditable]": "venueInputWasChanged"
    "input div.time[contenteditable]": "timeStringInputWasChanged"
    "input div.description pre[contenteditable]": "descriptionInputWasChanged"
    "input div.cost[contenteditable]": "costInputWasChanged"
    "change select.one.category": "categoryInputWasChanged"
    "change input[type=date]": "dateInputWasChanged"
    "click button.publish": "publishArticle"
    "click button.pending": "moveArticleToPendingBucket"
    "click button.trash": "moveArticleToTrashBucket"

  render: ->
    @el.innerHTML = @renderTemplate({article:@model})

  activate: =>
    @el.classList.remove("compacted")
    @el.classList.add("activated")

  categoryInputWasChanged: (event) ->
    console.info(event.target.value)
    @model.set "category", event.target.value
    @model.save()
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
    if time = @parseInputTimeForModel(event.target.innerText)
      @model.set "time", time

  costInputWasChanged: (event) ->
    @model.set "cost", event.target.innerText

  descriptionInputWasChanged: (event) ->
    @model.set "description", event.target.innerText

  publishArticle: (event) ->
    console.info "moveArticleToPublishedBucket"
    event.preventDefault()
    @model.moveToPublishedBucket()

  moveArticleToTrashBucket: (event) ->
    console.info "moveArticleToTrashBucket"
    event.preventDefault()
    @model.moveToTrashBucket()

  moveArticleToPendingBucket: (event) ->
    console.info "moveArticleToPendingBucket"
    event.preventDefault()
    @model.moveToPendingBucket()

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

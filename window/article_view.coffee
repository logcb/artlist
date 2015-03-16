BasicView = require "./basic_view"
{debounce} = require "underscore"

class ArticleView extends BasicView
  module.exports = this

  template: require "../templates/article.html"

  initialize: ->
    @activate()
    $(@el).on("click", @articleContainerWasClicked)
    @model = Artlist.index.get(@el.id)
    @model.on "change:title", debounce @saveArticle, 100
    @model.on "change:venue", debounce @saveArticle, 100
    @model.on "change:description", debounce @saveArticle, 100
    @model.on "change:time", debounce @saveArticle, 100
    @model.on "change:cost", debounce @saveArticle, 100
    @model.on "error", @articleHasError

  events:
    "keypress div[contenteditable]": "blurIfEnterKeyWasPressed"
    "input div.title[contenteditable]": "titleInputWasChanged"
    "input div.venue[contenteditable]": "venueInputWasChanged"
    "input div.time[contenteditable]": "timeStringInputWasChanged"
    "input div.description pre[contenteditable]": "descriptionInputWasChanged"
    "input div.cost[contenteditable]": "costInputWasChanged"
    "change select.one.category": "categoryInputWasChanged"
    "change div.date input": "dateInputWasChanged"
    "click button.publish": "publishArticle"
    "click button.pending": "moveArticleToPendingBucket"
    "click button.trash": "moveArticleToTrashBucket"

  render: ->
    @el.innerHTML = @renderTemplate({article:@model})

  blurIfEnterKeyWasPressed: (event) ->
    if event.keyIdentifier is "Enter"
      event.preventDefault()
      event.target.blur()

  articleContainerWasClicked: (event) =>
    return if $(event.target).is("a[href]")
    event.preventDefault()
    event.stopPropagation()
    if Artlist.operator.isPermittedToMakeChanges()
      @deactivate() if event.target is @el
    else
      @deactivate()

  activate: =>
    @el.classList.add("activated")

  deactivate: =>
    @el.classList.remove("activated")
    @off()
    $(@el).off()

  categoryInputWasChanged: (event) ->
    @model.set "category", event.target.value
    @model.save()
    @render()

  titleInputWasChanged: (event) ->
    @model.set "title", event.target.innerText

  venueInputWasChanged: (event) ->
    @model.set "venue", event.target.innerText

  dateInputWasChanged: (event) ->
    if date = @parseInputDateForModel event.target.value
      @model.set "date", date
      @model.save()
    else
      @render()
      @el.querySelector("div.date input").focus()

  timeStringInputWasChanged: (event) ->
    if time = @parseInputTimeForModel event.target.innerText
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

Backbone = require "backbone"
Artlist = require "./artlist"

class PostArticleView extends Backbone.View
  module.exports = this

  initialize: ->
    @model = new Artlist.Article
    console.info(this.el)

  events:
    "submit": "formWasSubmitted"
    "input div.attribute": "modelAttributeWasChanged"

  render: =>
    articlesGroupedByDate = @collection.groupBy (article) -> article.date
    sections = []
    template = require "../templates/day_of_articles.html"
    for date, articles of articlesGroupedByDate
      articles = (article.toJSON() for article in articles)
      sections.push template({date, articles: articles})
    @el.innerHTML = sections.join("")


  click: ->
    console.info "click"

  commit: (event) ->
    console.info "commit"
    # Artlist.index.add(@model)
    # Artlist.index.create(@model)

    console.info @model.attributes
    console.info @model

    @model.save()
    @model.once "sync", =>
      console.info @model.attributes
      console.info @model
      console.info Artlist.index.length
      console.info Artlist.index.add(@model)
      console.info Artlist.index.length
      # console.info("sync")
    # @model.once "sync", =>
    # @model.once "sync", => console.info(@model.toJSON())
    # @model.once "sync", => Artlist.index.add(@model)

  modelAttributeWasChanged: (event) ->
    @model.set event.target.name, event.target.value

  formWasSubmitted: (event) ->
    event.preventDefault()
    @commit(event)

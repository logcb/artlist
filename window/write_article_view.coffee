Backbone = require "backbone"
Artlist = require "./artlist"

class WriteArticleView extends Backbone.View
  module.exports = this

  el: "div.write"

  initialize: ->
    @article = new Artlist.Article
    @activate()

  events:
    "input div.attribute": "attributeInputWasChanged"
    "submit": "formWasSubmitted"

  render: =>
    template = require "../templates/write_article.html"
    @el.innerHTML = template({article: @article.toJSON()})

  activate: =>
    Function.delay 1, => Backbone.history.once "route", @deactivateOnReturnToIndex
    @render()
    @el.scrollIntoView()
    $(@el).addClass "activated"
    $(@el).on "transitionend", (event) =>
      if event.target is @el and event.propertyName is "height"
        @el.querySelector("input[name=title]").focus()

  deactivate: =>
    Backbone.history.off "route", @deactivateOnReturnToIndex
    $(@el).off()
    @el.innerHTML = ""
    $(@el).removeClass "activated"

  commit: (event) ->
    @article.save()
    @article.once "sync", => Artlist.index.add(@article)
    @article.once "sync", => window.router.navigate("/", {trigger: yes})

  attributeInputWasChanged: (event) ->
    @article.set event.target.name, event.target.value

  formWasSubmitted: (event) ->
    event.preventDefault()
    @commit(event)

  deactivateOnReturnToIndex: (router, destination) =>
    @deactivate() if destination is "index"

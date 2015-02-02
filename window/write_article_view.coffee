Backbone = require "backbone"
Artlist = require "./artlist"

class WriteArticleView extends Backbone.View
  module.exports = this

  el: "div.write"

  initialize: ->
    @article = new Artlist.Article
    @render()
    @activate()
    Function.delay 1, => Backbone.history.once "route", @deactivate

  events:
    "input div.attribute": "attributeInputWasChanged"
    "submit": "formWasSubmitted"

  render: =>
    template = require "../templates/write_article.html"
    @el.innerHTML = template({article: @article.toJSON()})

  activate: =>
    $(@el).addClass "activated"
    @el.scrollIntoView()
    $(@el).on "transitionend", (event) =>
      if event.target is @el and event.propertyName is "height"
        @el.querySelector("input[name=title]").focus()

  deactivate: =>
    $(@el).removeClass "activated"
    $(@el).off()
    @el.innerHTML = ""
    Backbone.history.off "route", @deactivate

  commit: (event) ->
    @article.save()
    @article.once "sync", => Artlist.index.add(@article)
    @article.once "sync", => window.router.navigate("/", {trigger: yes})

  attributeInputWasChanged: (event) ->
    @article.set event.target.name, event.target.value

  formWasSubmitted: (event) ->
    event.preventDefault()
    @commit(event)

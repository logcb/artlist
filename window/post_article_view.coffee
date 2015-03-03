Backbone = require "backbone"
Artlist = require "./artlist"

class PostArticleView extends Backbone.View
  module.exports = this

  el: "body > div.post"

  initialize: ->
    @article = new Artlist.Article
    @render()
    @activate()

  events:
    "input div.string.attribute": "stringInputWasChanged"
    "input div.time.attribute": "timeInputWasChanged"
    "submit": "formWasSubmitted"

  render: =>
    template = require "../templates/post_article.html"
    @el.innerHTML = template({@formatModelTimeForInput, article: @article.toJSON()})

  activate: =>
    @el.classList.add("activated")
    # @el.scrollIntoView()
    $(@el).on "transitionend", (event) =>
      if event.target is @el and event.propertyName is "height"
        @el.querySelector("input[name=title]").focus()
        Backbone.history.once "route", @deactivateOnReturnToIndex
        @article.on "invalid", @focusInvalidAttribute

  deactivate: =>
    Backbone.history.off "route", @deactivateOnReturnToIndex
    $(@el).off()
    @article.off "invalid", @focusInvalidAttribute
    # @el.innerHTML = ""
    $(@el).removeClass "activated"

  commit: (event) ->
    @article.save()
    @article.once "sync", => Artlist.index.add(@article)
    @article.once "sync", => Artlist.router.navigate("/", {trigger: yes})

  stringInputWasChanged: (event) ->
    @article.set event.target.name, event.target.value.trim()

  timeInputWasChanged: (event) ->
    @article.set event.target.name, @formatInputTimeForModel(event.target.value.trim())

  formWasSubmitted: (event) ->
    event.preventDefault()
    @commit(event)

  deactivateOnReturnToIndex: (router, destination) =>
    @deactivate() if destination is "index"

  focusInvalidAttribute: (article, error) =>
    [attributeName, message] = error
    console.error "Article #{attributeName} #{message}."
    @el.querySelector("input[name=#{attributeName}]").focus()

  formatModelTimeForInput: (time) ->
    [hour, minute] = time.split(":")
    if hour < 12
      "#{hour}:#{minute}AM"
    else
      "#{Number(hour)-12}:#{minute}PM"

  formatInputTimeForModel: (time) ->
    [match, hour, minute, meridian] = /([0-9]+):([0-9]+)(AM|PM)/.exec(time)
    if meridian is "AM"
      hour = "0#{hour}" if hour.length is 1
      "#{hour}:#{minute}"
    else
      hour = String(Number(hour)+12)
      hour = "0#{hour}" if hour.length is 1
      "#{hour}:#{minute}"

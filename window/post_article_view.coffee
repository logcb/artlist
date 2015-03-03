Backbone = require "backbone"
Artlist = require "./artlist"

class PostArticleView extends Backbone.View
  module.exports = this

  el: "body > div.post"

  initialize: ->
    @article = new Artlist.Article
    @render()
    # @activate()

  events:
    "input div.attribute": "attributeInputWasChanged"
    "submit": "formWasSubmitted"

  render: =>
    template = require "../templates/post_article.html"
    @el.innerHTML = template({@formatModelTimeForInput, article: @article.toJSON()})

  activate: =>
    @el.classList.add("activated")
    $(@el).on "transitionend", (event) =>
      if event.target is @el and event.propertyName is "height"
        @el.querySelector("input[name=title]").focus()
        @article.on "invalid", @focusInvalidAttribute

  deactivate: =>
    Backbone.history.off "route", @deactivateOnReturnToIndex
    $(@el).off()
    @article.off "invalid", @focusInvalidAttribute
    $(@el).removeClass "activated"

  commit: (event) ->
    @article.save()
    @article.once "sync", => Artlist.index.add(@article)
    @article.once "sync", => Artlist.router.navigate("/", {trigger: yes})

  attributeInputWasChanged: (event) ->
    value = event.target.value.trim()
    value = @formatInputTimeForModel(value) if event.target.name is "time"
    @article.set event.target.name, value

  formWasSubmitted: (event) ->
    event.preventDefault()
    @commit(event)

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

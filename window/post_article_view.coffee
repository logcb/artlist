Backbone = require "backbone"
Article = require "./article"

class PostArticleView extends Backbone.View
  module.exports = this

  initialize: ->
    @model = new Article
    console.info(this.el)

  events:
    "submit": "formWasSubmitted"
    "input div.attribute": "modelAttributeWasChanged"

  click: ->
    console.info "click"

  commit: (event) ->
    console.info "commit"
    console.info @model.save()

  modelAttributeWasChanged: (event) ->
    @model.set event.target.name, event.target.value

  formWasSubmitted: (event) ->
    event.preventDefault()
    @commit(event)

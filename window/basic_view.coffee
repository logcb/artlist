Backbone = require "backbone"
Moment = require "moment"

class BasicView extends Backbone.View
  module.exports = this

  renderTemplate: (params) ->
    params.render = @renderHTML
    params.moment = Moment
    @template(params)

  renderHTML: (templateName, params={}) ->
    params.render = BasicView::renderHTML
    params.moment = Moment
    templateFunction = require "./templates/#{templateName}.html"
    templateFunction(params)

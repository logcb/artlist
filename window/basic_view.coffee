Backbone = require "backbone"

class BasicView extends Backbone.View
  module.exports = this

  renderHTML: (templateName, params={}) ->
    params.render = @renderHTML
    templateFunction = require "../templates/#{templateName}.html"
    templateFunction(params)

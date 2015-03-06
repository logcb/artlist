Backbone = require "backbone"
Moment = require "moment"

class BasicView extends Backbone.View
  module.exports = this

  renderTemplate: (params) ->
    params.render = @renderHTML
    params.moment = Moment
    params.mutable = mutableElementAttribute
    @template(params)

  renderHTML: (templateName, params={}) ->
    params.render = BasicView::renderHTML
    params.moment = Moment
    params.mutable = mutableElementAttribute
    templateFunction = require "./templates/#{templateName}.html"
    templateFunction(params)

  formatModelTimeForInput: (time) ->
    [hour, minute] = time.split(":")
    if Number(hour) < 12
      "#{hour}:#{minute}AM"
    else
      "#{Number(hour)-12}:#{minute}PM"

  parseInputTimeForModel: (time) ->
    pattern = /([0-9]+):([0-9]+)(AM|PM)/i
    if pattern.test(time)
      [match, hour, minute, meridian] = pattern.exec(time)
      if meridian is "AM"
        hour = "0#{hour}" if hour.length is 1
        "#{hour}:#{minute}"
      else
        hour = String(Number(hour)+12) unless hour is "12"
        hour = "0#{hour}" if hour.length is 1
        "#{hour}:#{minute}"
    else
      undefined


mutableElementAttribute = ->
  "contenteditable=true" if Artlist.operator.isPermittedToMakeChanges()

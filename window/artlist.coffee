Backbone = require "backbone"
Moment = require "moment"

class Article extends Backbone.Model
  urlRoot: "/articles"

  defaults: ->
    date: Moment().format("YYYY/MM/DD")
    start_time: "16:30"
    category: "Community"

  validate: (attributes, options) ->
    if attributes.title is undefined
      return ["title", "can’t be blank"]
    if attributes.venue is undefined
      return ["venue", "can’t be blank"]
    if attributes.address is undefined
      return ["address", "can’t be blank"]
    if attributes.date is undefined
      return ["date", "can’t be blank"]
    if attributes.start_time is undefined
      return ["start_time", "can’t be blank"]


class Article.Collection extends Backbone.Collection
  model: Article

module.exports =
  Article: Article
  index: new Article.Collection
  selection: new Article.Collection

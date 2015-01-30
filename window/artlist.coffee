Backbone = require "backbone"

class Article extends Backbone.Model
  urlRoot: "/articles"

class Article.Collection extends Backbone.Collection
  model: Article

module.exports =
  Article: Article
  index: new Article.Collection
  selection: new Article.Collection

Artlist = require "./artlist"
Backbone = require "backbone"

class ArticleListView extends Backbone.View
  module.exports = this

  events:
    "mousedown article[id]": "editArticle"

  initialize: ->
    @collection = Artlist.index
    @collection.on "add", @render
    @collection.on "remove", @render
    @render()

  render: =>
    articlesGroupedByDate = @collection.groupBy (article) -> article.date
    sections = []
    template = require "../templates/day_of_articles.html"
    for date, articles of articlesGroupedByDate
      articles = (article.toJSON() for article in articles)
      sections.push template({date, articles: articles})
    @el.innerHTML = sections.join("")

  editArticle: (event) ->
    id = event.currentTarget.id
    Backbone.history.navigate("articles/#{id}")

  getArticlesGroupedByDay: ->
    @collection.groupBy (article) -> article.date

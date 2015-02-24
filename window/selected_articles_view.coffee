BasicView = require "./basic_view"
ArticleView = require "./article_view"

class SelectedArticlesView extends BasicView
  module.exports = this

  el: "div.selected_articles"

  template: require "../templates/selected_articles.html"

  events:
    "mousedown article.compacted[id]": "activateArticle"

  initialize: ->
    @collection.on "add", @render
    @collection.on "remove", @render
    @render()

  render: =>
    @el.innerHTML = @renderTemplate({dates: @getArticlesGroupedByDate()})

  activateArticle: (event) ->
    id = event.currentTarget.id
    article = @collection.get(id)
    new ArticleView {model: article, el: event.currentTarget}

  getArticlesGroupedByDate: ->
    @collection.groupBy (article) -> article.get("date")

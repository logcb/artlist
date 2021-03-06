BasicView = require "./basic_view"
ArticleView = require "./article_view"
Moment = require "moment"

class DayOfArticlesView extends BasicView
  module.exports = this
  tagName: "section"
  className: "day"
  template: require "../templates/day_of_articles.html"

  initialize: (@date, options={}) ->
    @collection = new Artlist.Article.DateCollection @date, options
    @collection.on "add remove", @render
    Artlist.selection.on "add remove", @render
    @render()
    @insertIntoDocument()

  events:
    "click article:not(.activated)": "activateArticle"

  selectionContainsDate: ->
    Artlist.selection.detect (article) => article.get("date") is @date

  render: =>
    @el.id = @sectionID()
    @el.classList[if @selectionContainsDate() then "remove" else "add"]("empty")
    @el.innerHTML = @renderTemplate({
      date: @date
      articles: @collection.toArray()
    })

  insertIntoDocument: ->
    containerElement = document.querySelector("div.current_articles")
    referenceElement = containerElement.querySelector("#{@nextSectionID()}")
    containerElement.insertBefore(@el, referenceElement)

  activateArticle: (event) ->
    new ArticleView el: event.currentTarget

  nextSectionID: ->
    @sectionID Moment(@date, "YYYY-MM-DD").add(1, "day")

  sectionID: (date=@date) ->
    "#" + Moment(date, "YYYY-MM-DD").format("MMMDD")

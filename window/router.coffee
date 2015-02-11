Backbone = require "backbone"
Artlist = require "./artlist"
ListView = require "./list_view"
ListControlsView = require "./list_controls_view"
ReadIntroView = require "./read_intro_view"
WriteArticleView = require "./write_article_view"

class Router extends Backbone.Router
  module.exports = this

  routes: {"": "index", "intro": "intro", "post": "post"}

  initialize: ->
    @on "route", (bookmark, p) -> console.info "Routed to #{bookmark}", p
    @filters = new Backbone.Model {query: undefined, categories: []}
    @articles = new Artlist.Article.Collection
    @filters.on "change", => @articles.set Artlist.search(@filters.toJSON()), {remove:yes}
    @articles.set Artlist.search(@filters.toJSON()), {remove:yes}
    @listControlsView = new ListControlsView el: "div.list.controls", model: @filters
    @listView = new ListView el: "div.list_view", collection: @articles

  index: ->
    $(document).off "scroll", @returnToIndexWhenListIsInView
    document.title = "THE ARTLIST"
    document.body.className = "index"
    document.body.querySelector("h1").innerHTML = """THE ARTLIST"""

  intro: ->
    document.title = "THE ARTLIST: INFORMATION"
    document.body.className = "intro"
    document.body.querySelector("h1").innerHTML = """<a href="/">THE ARTLIST</a>: INFORMATION"""
    new ReadIntroView
    $(document).on "scroll", @returnToIndexWhenListIsInView

  post: () ->
    document.title = "Post an event to THE ARTLIST"
    document.body.className = "write article"
    document.body.querySelector("h1").innerHTML = """<a href="/">THE ARTLIST</a>: SHARE YOUR EVENT"""
    article = new Artlist.Article
    new WriteArticleView model: article
    $(document).on "scroll", @returnToIndexWhenListIsInView

  params: (url=window.location) ->
    params = {}
    if url.search
      for pair in url.search.replace("?", "").split("&")
        [name, value] = pair.split("=")
        params[name] = decodeURIComponent value
    return params

  returnToIndexWhenListIsInView: (event) =>
    if window.scrollY > ($("div.list_container").offset().top - $("body > header").height())
      event.preventDefault()
      Artlist.router.navigate "/", {trigger: yes}
      window.scrollTo(0,0)

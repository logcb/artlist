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
    @filters = new Backbone.Model {query: undefined, categories: []}
    @articles = new Artlist.Article.Collection
    @filters.on "change", => @articles.set Artlist.search(@filters.toJSON()), {remove:yes}
    @articles.set Artlist.search(@filters.toJSON()), {remove:yes}
    @listControlsView = new ListControlsView el: "div.list.controls", model: @filters
    @listView = new ListView el: "div.list_view", collection: @articles
    $(document).on "click", "a[href^='/']", @localHyperlinkWasActivated
    @on "route", (bookmark) -> console.info "Routed to #{bookmark}"
    Artlist.index.on "all", -> console.info "Article.index", arguments
    console.info "THE ARTLIST is ready at #{location.hostname}:#{location.port}"

  index: ->
    console.info "Rendering index", @params()
    document.title = "THE ARTLIST"
    document.body.className = "index"
    document.body.querySelector("h1").innerHTML = """THE ARTLIST"""
    $(document).off "scroll", @returnToIndexWhenListIsInView
    window.scrollTo(0,0)

  intro: ->
    console.info "Rendering intro"
    document.title = "THE ARTLIST: INFORMATION"
    document.body.className = "intro"
    document.body.querySelector("h1").innerHTML = """<a href="/">THE ARTLIST</a>: INFORMATION"""
    new ReadIntroView
    window.scrollTo(0,0)
    $(document).on "scroll", @returnToIndexWhenListIsInView

  post: () ->
    console.info "Rendering post an event", @params()
    document.title = "Post an event to THE ARTLIST"
    document.body.className = "write article"
    document.body.querySelector("h1").innerHTML = """<a href="/">THE ARTLIST</a>: SHARE YOUR EVENT"""
    article = new Artlist.Article
    new WriteArticleView model: article
    window.scrollTo(0,0)
    $(document).on "scroll", @returnToIndexWhenListIsInView

  params: (url=window.location) ->
    params = {}
    if url.search
      for pair in url.search.replace("?", "").split("&")
        [name, value] = pair.split("=")
        params[name] = decodeURIComponent value
    return params

  localHyperlinkWasActivated: (event) =>
    event.preventDefault()
    @navigate event.currentTarget.getAttribute("href"), {trigger: yes}

  returnToIndexWhenListIsInView: (event) =>
    if window.scrollY > ($("div.list_container").offset().top - $("body > header").height())
      event.preventDefault()
      $(document).off "scroll", @returnToIndexWhenListIsInView
      @navigate "/", {trigger: yes}

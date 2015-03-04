Backbone = require "backbone"
Artlist = require "./artlist"
# ReadIntroView = require "./read_intro_view"
# WriteArticleView = require "./write_article_view"

class Router extends Backbone.Router
  module.exports = this

  routes: {"": "index", "intro": "intro", "post": "post"}

  initialize: ->

    $(document).on "click", "a[href^='/']", @localHyperlinkWasActivated
    $(document).on "scroll", @documentWasScrolled
    @on "route", (bookmark) -> console.info "Routed to #{bookmark}"
    @once "route", -> document.body.classList.remove("loading")

  index: ->
    document.body.classList.remove("index", "intro", "post")
    document.body.classList.add("index")
    @scrollTo("div.current_articles") unless @scrolling

  intro: ->
    document.body.classList.remove("index", "intro", "post")
    document.body.classList.add("intro")
    @scrollTo("section.intro") unless @scrolling

  post: ->
    document.body.classList.remove("index", "intro", "post")
    document.body.classList.add("post")
    @scrollTo("section.post") unless @scrolling

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

  documentWasScrolled: (event) =>
    @bookmarks ?= $("section.intro, section.post, div.current_articles").toArray().reverse()
    filtered = @bookmarks.filter (bookmark) ->
      window.scrollY >= ($(bookmark).offset().top - $("body > header").height())
    destination = switch filtered[0].className
      when "intro" then "/intro"
      when "post" then "/post"
      else "/"
    @scrolling = yes
    @navigate destination, trigger: yes
    @scrolling = no

  scrollTo: (section) ->
    window.scrollTo 0, $(section).offset().top - $("body > header").height()

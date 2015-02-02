Backbone = require "backbone"
Artlist = require "./artlist"
ListView = require "./list_view"
ReadIntroView = require "./read_intro_view"
WriteArticleView = require "./write_article_view"

class Router extends Backbone.Router
  module.exports = this

  initialize: ->
    @articles = Artlist.selection
    @listView ?= new ListView el: "div.list_view"


  routes:
    "": "index"
    "search?query": "search"
    "intro": "intro"
    "post": "post"
    "editor": "editArtList"
    "editor/articles/new": "postArticle"
    "editor/articles/:id": "editArticle"

  index: ->
    document.title = "THE ARTLIST"
    document.body.className = "public index"
    document.body.querySelector("h1").innerHTML = """THE ARTLIST"""
    @articles.set Artlist.index.toArray()


  intro: ->
    document.title = "THE ARTLIST: INFORMATION"
    document.body.className = "public intro"
    document.body.querySelector("h1").innerHTML = """<a href="/">THE ARTLIST</a>: INFORMATION"""
    new ReadIntroView

  search: ->
    document.title = "THE ARTLIST"
    document.body.className = "public search"
    document.body.querySelector("h1").innerHTML = """<a href="/">THE ARTLIST</a>: SEARCH"""
    @articles.set Artlist.index.search(query)


  post: () ->
    document.title = "Post an event to THE ARTLIST"
    document.body.className = "public write new article"
    document.body.querySelector("h1").innerHTML = """<a href="/">THE ARTLIST</a>: SHARE YOUR EVENT"""
    article = new Artlist.Article
    new WriteArticleView model: article

  editArtList: ->
    document.title = "Edit THE ARTLIST"
    document.body.className = "editor index"
    @articles.set Artlist.index.toArray()

  postArticle: ->
    document.title = "Adding new event to THE ARTLIST"
    document.body.className = "editor write new article"
    article = new Artlist.Article
    new WriteArticleView model: article

  editArticle: (id) ->
    document.title = "Editing event: #{id}"
    document.body.className = "editor write article"
    article = Artlist.index.get(id)
    new EditArticleView model: article

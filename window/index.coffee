Backbone = require "backbone"
Backbone.$ = window.$

Artlist = window.Artlist = require "./artlist"

ListView        = require "./list_view"
PostArticleView = require "./post_article_view"

$(document).ready (event) ->
  new PostArticleView el: $("form.post_an_event").get(0)
  # new ListView el: $("body > div.articles").get(0), collection: Artlist.index
  console.info "THE ARTLIST IS READY"

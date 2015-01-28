Artlist = window.Artlist = {}
Artlist.index = new Backbone.Collection
Artlist.selection = new Backbone.Collection


$(document).ready (event) ->
  console.info "THE ARTLIST"
  new HeaderView el: $("body > header")
  new ListView el: $("body > div.list"), collection: Artlist.selection


class HeaderView extends Backbone.View
  events:
    "click label.post_an_event": "startPostEventActivity"
    "click label.search": "startSearchActivity"
    "click label.introduction": "showIntroduction"

  startPostEventActivity: (event) ->
    console.info "startPostEventActivity"
    new PostEventView el: $("form.make_event")

  startSearchActivity: (event) ->
    console.info "startPostEventActivity"
    new SearchInputView el: $("form.search")



class ListView extends Backbone.View
  events:
    ""

class PostEventView extends Backbone.View
  initialize:
    $(@el).find("input").focus()

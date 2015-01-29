Backbone = require "backbone"

module.exports =
  index: new Backbone.Collection
  selection: new Backbone.Collection




# class HeaderView extends Backbone.View
#   events:
#     "click label.post_an_event": "startPostEventActivity"
#     "click label.search": "startSearchActivity"
#     "click label.introduction": "showIntroduction"
#
#   startPostEventActivity: (event) ->
#     console.info "startPostEventActivity"
#     new PostEventView el: $("form.make_event")
#
#   startSearchActivity: (event) ->
#     console.info "startPostEventActivity"
#     new SearchInputView el: $("form.search")

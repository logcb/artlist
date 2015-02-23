Backbone = require "backbone"

class BodyView extends Backbone.View
  module.exports = this

  el: "body"

  initialize: ->
    Artlist.operator.on "change:permit", @render
    if permitIdentifier = @el.getAttribute("data-permit-id")
      permit = new Artlist.Permit id:permitIdentifier
      Artlist.operator.grantPermissionToMakeChanges(permit)

  render: =>
    if Artlist.operator.isPermittedToMakeChanges()
      @el.classList.add("editing")
    else
      @el.classList.remove("editing")

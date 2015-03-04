Backbone = require "backbone"

class FilterControlsView extends Backbone.View
  module.exports = this

  el: "div.filter.controls"

  events:
    "input [name=query]": "queryInputWasChanged"
    "change input[type=checkbox]": "categoryInputWasChanged"

  initialize: ->
    @model.on "change", @classifyCategoryElements
    @render()

  render: =>
    template = require "../templates/filter_controls.html"
    @el.innerHTML = template(@model.toJSON())

  queryInputWasChanged: (event) ->
    @model.set "query", @el.querySelector("input[name=query]").value

  categoryInputWasChanged: (event) ->
    categories = $("div.categories input:checked").toArray().map((input) -> input.value)
    @model.set "categories", categories

  classifyCategoryElements: =>
    $("div.categories label").removeClass("excluded")
    $("div.categories label").removeClass("included")
    if @model.get("categories").length
      $("div.categories label").addClass("excluded")
      for category in @model.get("categories")
        $("div.categories label input[value='#{category}']").closest("label").removeClass("excluded").addClass("included")

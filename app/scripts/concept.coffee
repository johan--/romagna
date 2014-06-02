class @Concept
  constructor: (c) ->
    _.each(c, (v, k) => @[k] = v)

  hasAttributes: () ->
    true if @attributeContingent.attributeRef or @attributeContingent.attribute

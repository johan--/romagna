class @Concept
  constructor: (c, @schema = {}) ->
    _.each(c, (v, k) => @[k] = v)

  hasAttributes: () ->
    true if @attributeContingent.attributeRef or @attributeContingent.attribute
  getAttributes: () ->
    if @attributeContingent.attributeRef
      attribute = _.find(@schema.context.attribute, (d) =>
        d.props.id == @attributeContingent.attributeRef["#text"]
      )
    else
      attribute = @attributeContingent.attribute
    return attribute

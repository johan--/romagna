class @Concept
  constructor: (c, @schema = {}) ->
    _.each(c, (v, k) => @[k] = v)

  hasAttributes: () ->
    true if @attributeContingent.attributeRef or @attributeContingent.attribute
  hasObjects: () ->
    true if @objectContingent.objectRef or
            @objectContingent.object

  objectCount: () ->
    switch
      when @objectContingent.objectRef?.length then @objectContingent.objectRef.length
      when @objectContingent.objectRef?["#text"] then 1
      when @objectContingent.object?.length then @objectContingent.object.length
      when @objectContingent.object?["#text"] then 1
  getAttributes: () ->
    if @attributeContingent.attributeRef
      attribute = new Attribute(_.find(@schema.context.attribute, (d) =>
        d.props.id == @attributeContingent.attributeRef["#text"]
      ))
    else
      attribute = _.map(@attributeContingent.attribute, (a) -> new Attribute(a))
    return attribute

class @TJ04Concept extends Concept
class @TJ10Concept extends Concept

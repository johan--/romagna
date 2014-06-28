class @Concept
  constructor: (c = {}) ->
    _.each(c, (v, k) => @[k] = v)

    @visual =
      position: {}
      attributeLabel: {}
      objectLabel: {}

  hasAttributes: () ->
    true if @attributes.attributeRef or @attributes.attribute

  hasObjects: () ->
    @objects.length

  objectCount: () ->
    switch
      when @objects.length then @objects.length
      when @objects.objectRef?.length then @objects.objectRef.length
      when @objects.objectRef?["#text"] then 1

  getAttributes: () ->
    if @attributes.attributeRef
      attribute = new Attribute(_.find(@schema.context.attribute, (d) =>
        d.props.id == @attributes.attributeRef["#text"]
      ))
    else
      attribute = _.map(@attributes.attribute, (a) -> new Attribute(a))
    return attribute

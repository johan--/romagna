class @Concept
  constructor: (c = {}, @schema = {}) ->
    _.each(c, (v, k) => @[k] = v)

  hasAttributes: () ->
    true if @attributes.attributeRef or @attributes.attribute
  hasObjects: () ->
    true if @objects.objectRef or
            @objects.object

  objectCount: () ->
    switch
      when @objects.objectRef?.length then @objects.objectRef.length
      when @objects.objectRef?["#text"] then 1
      when @objects.object?.length then @objects.object.length
      when @objects.object?["#text"] then 1
  getAttributes: () ->
    if @attributes.attributeRef
      attribute = new Attribute(_.find(@schema.context.attribute, (d) =>
        d.props.id == @attributes.attributeRef["#text"]
      ))
    else
      attribute = _.map(@attributes.attribute, (a) -> new Attribute(a))
    return attribute

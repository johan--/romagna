class @ConceptualSchema
  constructor: (schema) ->
    @diagrams = schema.diagrams
    @attributes = schema.attributes
    @objects = schema.objects
    console.log "new conceptual schema"

  getAttribute: (id) ->
    attribute = _(@context.attribute).find((d) ->
      d.props.id == id
    )
    return attribute


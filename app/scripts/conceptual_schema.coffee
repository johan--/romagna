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



class @ConceptualSchemaTJ04 extends ConceptualSchema
  constructor: (schema) ->
    @context = schema.context
    @attributes = @context.attribute
    @objects = @context.object
    @diagrams = _.map(schema.diagram, (d) => new TJ04Diagram(d, this))
  


class @ConceptualSchema
  constructor: (schema) ->
    console.log "new conceptual schema with version #{@version}"

  getAttribute: (id) ->
    attribute = _(@context.attribute).find((d) ->
      d.props.id == id
    )
    return attribute

class @ConceptualSchemaTJ10 extends ConceptualSchema

  constructor: (schema) ->
    @diagrams = _.map(schema.diagram, (d) => new TJ10Diagram(d, this))
    @objects = @extractObjects()
    @attributes = @extractAttributes()

  extractAttributes: () ->
    attributes = []
    _.each(@diagrams, (diagram) ->
      _.each(diagram.node, (n) ->
        attr = _.map(n.attributeContingent.attribute, (o) -> o["#text"])
        attributes = _.union(attributes, attr)
      )
    )
    return attributes

  extractObjects: () ->
    objects = []

    _.each(@diagrams, (diagram) ->
      _.each(diagram.node, (n) ->
        obj = _.map(n.objectContingent.object, (o) -> o["#text"])
        objects = _.union(objects, obj)
      )
    )
    return objects

class @ConceptualSchemaTJ04 extends ConceptualSchema
  constructor: (schema) ->
    @context = schema.context
    @attributes = @context.attribute
    @objects = @context.object
    @diagrams = _.map(schema.diagram, (d) => new TJ04Diagram(d, this))
  


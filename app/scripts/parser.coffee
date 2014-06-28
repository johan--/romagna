
tj04SchemaParser =
  extractObjects: (schema) ->
    return schema.context.object

  extractAttributes: (schema) ->
    return schema.context.attribute

tj10SchemaParser =
  extractAttributes: (schema) ->
    attributes = []
    _.each(schema.diagrams, (diagram) ->
      _.each(diagram.node, (n) ->
        attr = _.map(n.attributeContingent.attribute, (o) -> o["#text"])
        attributes = _.union(attributes, attr)
      )
    )
    return attributes

  extractObjects: (schema) ->
    objects = []

    _.each(schema.diagrams, (diagram) ->
      _.each(diagram.node, (n) ->
        obj = _.map(n.objectContingent.object, (o) -> o["#text"])
        objects = _.union(objects, obj)
      )
    )
    return objects

  extractDiagrams: (schema) ->
    return _.map schema.diagram, (d) ->
      diagram = new Diagram(d)
      diagram.edges = _.pluck(d.edge, 'props')
      diagram.concepts = _.map d.node, (node) ->
        concept = new Concept()
        concept.attributes = node.concept.attributeContingent
        concept.objects = node.concept.objectContingent
        concept.id = node.props.id
        concept.visual =
          position:
            x: parseFloat(node.position.props.x, 10)
            y: parseFloat(node.position.props.y, 10)
          objectLabel: node.objectLabelStyle ? {}
          attributeLabel: node.attributeLabelStyle ? {}

        return concept
      diagram.computeExtent()
      return diagram

class @ContextParser
  parsers:
    'TJ0.4': tj04SchemaParser
    'TJ1.0': tj10SchemaParser
  constructor: () ->

  parse: (schema, version) ->
    parser = @parsers[version]
    result = {}
    result.objects = parser.extractObjects(schema)
    result.attributes = parser.extractAttributes(schema)
    result.diagrams = parser.extractDiagrams(schema)
    return result


  createSchema: (schema, version) ->
    intermediate = @parse(schema, version)
    console.log intermediate
    finalSchema = new ConceptualSchema(intermediate)
    return finalSchema


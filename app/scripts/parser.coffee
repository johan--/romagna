
tj04SchemaParser =
  extractAllObjects: (schema) ->
    return schema.context.object

  extractAllAttributes: (schema) ->
    return schema.context.attribute

tj10SchemaParser =
  extractAllAttributes: (schema) ->
    attributes = []
    _.each(schema.diagrams, (diagram) ->
      _.each(diagram.node, (n) ->
        attr = _.map(n.attributeContingent.attribute, (o) -> o["#text"])
        attributes = _.union(attributes, attr)
      )
    )
    return attributes

  extractObjects: (node) ->
    _.compact(_.map(node.concept.objectContingent.object, (o) -> o["#text"]))

  extractAllObjects: (schema) ->
    objects = []

    _.each(schema.diagrams, (diagram) =>
      _.each(diagram.node, (n) =>
        obj = @extractObjects(n)
        objects = _.union(objects, obj)
      )
    )
    return objects

  parseLabelInfo: (label = {}) ->
    labelInfo =
      offset:
        x: parseFloat label.offset?.props.x ? 0, 10
        y: parseFloat label.offset?.props.y ? 0, 10
      bgColor: label.backgroundColor?['#text'].convertToRGBA() ? "#fff"
      textColor: label.textColor?['#text'].convertToRGBA() ? "#000"
      textAlignment: label.textAlignment?['#text'] ? "middle"

  extractVisualInfo: (node) ->
    visual =
      position:
        x: parseFloat(node.position.props.x, 10)
        y: parseFloat(node.position.props.y, 10)
      objectLabel: @parseLabelInfo node.objectLabelStyle
      attributeLabel:@parseLabelInfo node.attributeLabelStyle


  extractDiagrams: (schema) ->
    return _.map schema.diagram, (d) =>
      diagram = new Diagram(d)
      diagram.edges = _.pluck(d.edge, 'props')
      diagram.concepts = _.map d.node, (node) =>
        concept = new Concept()
        concept.attributes = node.concept.attributeContingent
        concept.objects = @extractObjects(node)
        concept.id = node.props.id

        concept.visual = @extractVisualInfo(node)
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
    result.objects = parser.extractAllObjects(schema)
    result.attributes = parser.extractAllAttributes(schema)
    result.diagrams = parser.extractDiagrams(schema)
    return result


  createSchema: (schema, version) ->
    intermediate = @parse(schema, version)
    console.log intermediate
    finalSchema = new ConceptualSchema(intermediate)
    return finalSchema



App.TJ04SchemaParser = Ember.Object.extend(
  extractAllObjects: (schema) ->
    return schema.context.object

  extractAllAttributes: (schema) ->
    return schema.context.attribute
)

App.TJ10SchemaParser =
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
    #console.log node
    _.compact(_.map(node.concept.objectContingent.object, (o) -> o["#text"]))

  extractAllObjects: (schema) ->
    objects = []

    _.each(schema.diagrams, (diagram) =>
      _.each(diagram.node, (n) =>
        obj = @extractObjects(n)
        objects = _.union(objects, obj)
      )
    )
    #console.log objects
    return objects

  parseLabelInfo: (label = {}) ->
    labelInfo =
      offset:
        x: parseFloat label.offset?.x ? 0, 10
        y: parseFloat label.offset?.y ? 0, 10
      bgColor: label.backgroundColor?['#text'].convertToRGBA() ? "#fff"
      textColor: label.textColor?['#text'].convertToRGBA() ? "#000"
      textAlignment: label.textAlignment?['#text'] ? "middle"

  extractVisualInfo: (node) ->
    visual =
      position:
        x: parseFloat(node.position.x, 10)
        y: parseFloat(node.position.y, 10)
      objectLabel: @parseLabelInfo node.objectLabelStyle
      attributeLabel:@parseLabelInfo node.attributeLabelStyle

  extractDiagram: (d, i) ->
    diagram = @store.findByIdOrCreate('diagram', i,
      id: _.uniqueId('dia')
      title: d._title
    )

    unless diagram.get 'parsed'
      diagram.set 'parsed', true

      concepts = _.map d.node, (n) =>
        concept = @store.createRecord('concept_node',
        id: _.uniqueId('node')
        inDiagramId: n._id
        position:
          x: parseFloat n.position._x, 10
          y: parseFloat n.position._y, 10
        )

        if Ember.isArray n.concept.attributeContingent.attribute
          attributes = _.map n.concept.attributeContingent.attribute, (a) =>
            attribute = @store.findByIdOrCreate 'attribute', a,
              id: _.uniqueId('attr')
              value: a
        else
          attributes = []
          if _.isObject  n.concept.attributeContingent
            attribute = @store.findByIdOrCreate('attribute', n.concept.attributeContingent.attribute, {
                id: _.uniqueId('attr')
                value: n.concept.attributeContingent.attribute
              })
              #attribute.get('concepts').pushObject concept
            attributes.push attribute

        #console.log attributes
        concept.get('attributes').pushObjects attributes

        if Ember.isArray n.concept.objectContingent.object
          objects = _.map n.concept.objectContingent.object, (o) =>
            object = @store.findByIdOrCreate 'object', o,
              id: _.uniqueId('obj')
              value: o
        else
          objects = []
          if _.isObject n.concept.objectContingent
            #console.log n.concept.objectContingent
            object = @store.findByIdOrCreate('object', n.concept.objectContingent.object, {
                id: _.uniqueId('obj')
                value: n.concept.objectContingent.object
              })
            objects.push object
        #console.log objects

        concept.get('objects').pushObjects objects

        return concept

      diagram.get('concepts').pushObjects concepts

        #concept.visual = @extractVisualInfo(node)
        #return concept

      edges = _.map d.edge, (e) =>
        edge = @store.createRecord('edge',
          id: _.uniqueId("edge")
        )
        inboundNode = diagram.get('concepts').findBy('inDiagramId', e._to)
        outboundNode = diagram.get('concepts').findBy('inDiagramId', e._from)
        edge.set 'to', inboundNode
        edge.set 'from', outboundNode
        edge.set 'diagram', diagram
        inboundNode.get('inboundEdges').pushObject edge
        outboundNode.get('outboundEdges').pushObject edge

        return edge

      diagram.get('edges').pushObjects edges
    return diagram


  extractDiagrams: (schema, schemaName) ->
    return _.map schema.diagram, @extractDiagram

  extractDiagramNames: (schema, schemaName) ->

    diagrams = _.map schema.diagram, (d, i) =>
      @store.createRecord 'diagram',
        id: _.uniqueId('dia')
        title: d._title

App.ContextParser = Ember.Object.extend(
  parsers:
    'TJ0.4': App.TJ04SchemaParser
    'TJ1.0': App.TJ10SchemaParser

  #cursory means the parser just extracts diagram names and database information (if it exists)
  parse: (schema, version, store, schemaName, cursory = true) ->
    @parser = @parsers[version]
    result = store.createRecord 'conceptual_schema',
      name: schemaName
      version: version
    @parser.store = store
    if cursory
      diagrams = @parser.extractDiagramNames(schema, schemaName)
    else
      diagrams = @parser.extractDiagrams(schema, schemaName)
    console.log 'finished parsing'
    result.get('diagrams').pushObjects diagrams
    return result

  parseSingleDiagram: (schema, title, id) ->
    console.log schema, title, schema.diagram.findBy('_title', title)
    return @parser.extractDiagram(schema.diagram.findBy('_title', title), id)
)

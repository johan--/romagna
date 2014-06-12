class @Diagram

  constructor: (diagram, schema = {}) ->
    @title = diagram.props.title
    console.log "NEW DIAGRAM CONSTRUCTOR for #{@title}"
    @edges = diagram.edge
    @schema = schema
    @computeExtent()

  display: () ->
    @drawEdges()
    @drawConcepts()
    @drawLabels()

  computeExtent: () ->
    @extent = {}
    positions = _.map @concepts, (c) -> c.position.props
    @extent.x = d3.extent(_.map(positions,((p) -> parseFloat(p.x, 10))))
    @extent.y = d3.extent(_.map(positions,((p) -> parseFloat(p.y, 10))))

class @TJ04Diagram extends Diagram
  constructor: (diagram, schema = {}) ->
    console.log "NEW TJ 0.4 DIAGRAM CONSTRUCTOR"
    @concepts = _.map(diagram.concept, (c) -> new Concept(c, @schema))
    super

  drawEdges: () ->
  drawConcepts: () ->


class @TJ10Diagram extends Diagram
  constructor: (diagram, schema = {}) ->
    console.log "NEW TJ 1.0 DIAGRAM CONSTRUCTOR"
    @concepts = _.map(diagram.node, (n) ->
      n.objectContingent = n.concept.objectContingent
      n.attributeContingent = n.concept.attributeContingent
      return new Concept(n, @schema)
    )
    super

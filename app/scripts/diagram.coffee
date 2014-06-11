class @Diagram

  extent:
    x: [0, 0]
    y: [0, 0]

  constructor: (diagram, schema = {}) ->
    console.log "NEW DIAGRAM CONSTRUCTOR"
    @title = diagram.props.title
    @edges = diagram.edge
    @schema = schema
    @computeExtent()

  display: () ->
    @drawEdges()
    @drawConcepts()
    @drawLabels()

  computeExtent: () ->
    positions = _.map @concepts, (c) -> c.position.props
    @extent.x = d3.extent(_.map positions, (p) -> parseInt(p.x, 10))
    @extent.y = d3.extent(_.map positions, (p) -> parseInt(p.y, 10))

class @TJ04Diagram extends Diagram
  constructor: (diagram, schema = {}) ->
    console.log "NEW TJ 0.4 DIAGRAM CONSTRUCTOR"
    @concepts = _.map(diagram.concept, (c) -> new Concept(c))
    super

  drawEdges: () ->
  drawConcepts: () ->


class @TJ10Diagram extends Diagram
  constructor: (diagram, schema = {}) ->
    console.log "NEW TJ 1.0 DIAGRAM CONSTRUCTOR"
    @concepts = _.map(diagram.node, (n) ->
      n.objectContingent = n.concept.objectContingent
      n.attributeContingent = n.concept.attributeContingent
      return new Concept(n)
    )
    super

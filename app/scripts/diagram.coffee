class @Diagram

  options:
    fontSize: 12
    lineHeight: 15

  constructor: (diagram) ->
    @title = diagram.props.title
    #console.log "NEW DIAGRAM CONSTRUCTOR for #{@title}"
    @computeExtent()

  display: () ->
    @drawEdges()
    @drawConcepts()
    @drawLabels()

  computeExtent: () ->
    @extent ?= {}
    positions = _.map @concepts, (c) -> c.visual.position
    @extent.x = d3.extent(_.pluck(positions, 'x'))
    @extent.y = d3.extent(_.pluck(positions, 'y'))


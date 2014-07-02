loadedContext = null

@loadContext = (csx) ->
  loadedContext = xml2json(csx)
  schemaVersion = loadedContext.conceptualSchema.props.version
  contextParser = new ContextParser()
  App.schema = contextParser.createSchema(loadedContext.conceptualSchema, schemaVersion)
  diagrams = d3.selectAll('#diagrams')
                .selectAll('option')
                  .data(App.schema.diagrams, (d) -> d.get('title'))

  diagrams.enter()
    .append('option').attr('value', (d, i) -> i)
    .text (d) -> d.title
  diagrams.exit().remove()
  dispatch = d3.dispatch('load', 'change')
  dispatch.on 'load', () -> displayDiagram(0)
  dispatch.on 'change', displayDiagram
  dispatch.load 0
  d3.selectAll('#diagrams').on 'change', -> dispatch.change()
  loadedContext

$(document).ready () ->

displayDiagram = (d) ->
  
  d ?= d3.event.target.value
  #console.log app.schema

  diagram = app.schema.diagrams[+d]
  #console.log "NEW DIAGRAM", diagram
  svg = d3.select('svg#default-diagram')

  diagramGroup = svg.selectAll('g.diagram').data([diagram], (d) -> d.title)

  diagramGroup.exit().remove()
  diagramGroup.enter().append('g').attr('class', 'diagram')

  #add the edges
  edges = diagramGroup.selectAll('line').data(diagram.edges, (d) ->
    return "#{diagram.title}-#{d.from}-#{d.to}"
  )

  edges.exit().remove()
  edges.enter().append('line')
    .style('stroke', (d) -> return  if diagram.title then 'black' else '#333')
    .style('stroke-width', 2)
    .attr('x1', (d) ->
      from = d.from - 1
      pos = diagram.concepts[from].visual.position.x
      return pos
    ).attr('x2', (d) ->
      to = d.to - 1
      pos = diagram.concepts[to].visual.position.x
      return pos
    ).attr('y1', (d) ->
      from = d.from - 1
      pos = diagram.concepts[from].visual.position.y
      return pos
    ).attr('y2', (d) ->
      to = d.to - 1
      pos = diagram.concepts[to].visual.position.y
      return pos
    )
  
  #add the concepts!
  concepts = diagramGroup.selectAll('g.concept').data(diagram.concepts, (d) ->
    diagram.title + d.id
  )
  r = d3.scale.linear().domain([0, d3.max(diagram.concepts, (d) ->
    d.objects.objectRef?.length || 0
  )]).range([15, 30])

  concepts.exit().remove()

  concepts.enter()
    .append('g')
    .attr('class', 'concept')

  circles = concepts.append('circle')
  circles.style('fill', () -> return if diagram.title == "Status" then 'steelblue' else 'red')
        .attr('stroke', "#000")
        .attr('cy', (d) -> d.visual.position.y)
        .attr('cx', (d) -> d.visual.position.x)
        .attr('r',  (d) ->
          if d.hasObjects() then 10 else 3
        )
  circles.on('click', (d) ->
    console.log 'clicked a circle', d.id
    d.selected = not d.selected
    selection = d3.select(@)
    connectedEdges = edges.filter((e) -> e.from is d.id or e.to is d.id)
    console.log connectedEdges
    connectedEdges.transition()
                  .style('stroke-width', () -> if d.selected then 4 else 2)
    d3.select(@).transition()
                  .style('fill', (d) ->  if d.selected then 'blue' else 'red')
                  .style('stroke-width', (d) -> if d.selected then 2 else 1)
  )


  concepts.each((d) ->
    concept = d3.select(this)
    if d.hasAttributes()
      attrLabel = concept
        .append('g')
          .attr('class', 'concept-attribute-label')
          .attr('transform', (d) ->
            x = d.visual.position.x + d.visual.attributeLabel.offset.x - 100/2
            y = d.visual.position.y + d.visual.attributeLabel.offset.y - diagram.options.fontSize - diagram.options.lineHeight
            "translate(#{x}, #{y})"
          )
          
      attrLabel.append('rect')
          .attr('height', (d) ->
            attrs = d.attributes.attributeRef or d.attributes.attribute
            num = if Array.isArray attrs then attrs.length else 1
            return 15 * num
          )
          .attr('fill', (d) -> d.visual.attributeLabel.bgColor)
          .attr('stroke', "#000")
      attrLabel.append('text') .attr('fill', '#000')
          .each((d) ->
            attrs = d.getAttributes()
            unless Array.isArray attrs
              d3.select(@).text(attrs.name)
              d.textLength = @.getComputedTextLength()
            else
              for i, e of _.pluck(attrs, 'name')
                d3.select(@).append('tspan')
                            .attr('dx', 0)
                            .attr('dy', i * diagram.options.fontSize).text(() -> e)
                d.textLength = @.getComputedTextLength()
          )
            .attr('text-anchor', 'middle')
            .attr('x', () -> d3.max([@.getComputedTextLength()/2, 50]))
            .attr('y', 12)
      attrLabel.select('rect').attr('width', (d) -> d3.max([d.textLength + 10, 100]))
    if d.hasObjects()
      objLabel = concept
        .append('g')
          .attr('class', 'concept-object-label')
          .attr('transform', (d) ->
            x = parseInt(d.visual.position.x) + d.visual.objectLabel.offset.x - 20/2
            y = parseInt(d.visual.position.y) + d.visual.objectLabel.offset.y + diagram.options.fontSize + 3
            "translate(#{x}, #{y})"
          )
      objLabel.append('rect')
              .attr('width', 20)
              .attr('height', 15)
              .attr('fill', (d) -> d.visual.objectLabel.bgColor)
              .attr('stroke', "#000")
      objLabel.append('text').attr('fill', (d) -> d.visual.objectLabel.textColor)
        .text((d) -> d.objectCount() || 0)
          .attr('text-anchor', 'middle')
          .attr('x', 10)
          .attr('y', 12)
  )

  $('svg').attr('width', $('svg').parent().width())
  $('svg').attr('height', $('svg').parent().height())
  svg.attr('viewBox', () ->
    boundingClientRect = @getBBox()
    minY = diagram.extent.y[0] - 50
    minX = diagram.extent.x[0] - 50
    window.positions = _.map diagram.concepts, (c) -> c.visual.position
    #console.log diagram.extent , positions
    maxY = boundingClientRect.height + 50
    #console.log "EXTENT IS: #{diagram.extent.x[0]} #{diagram.extent.y[0]}"
    "#{minX} #{minY} #{boundingClientRect.width} #{maxY}"
  )


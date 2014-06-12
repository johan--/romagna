class App
  schemas:
    'TJ0.4': ConceptualSchemaTJ04
    'TJ1.0': ConceptualSchemaTJ10
  constructor: () ->
    console.log 'initialized app'


app = new App
loadedContext = null


$(document).ready ->

  $('#csx-file').change((e) ->
    reader = new FileReader()
    reader.readAsText(e.target.files[0])
    reader.onload = ((e) -> console.log e.target.result)

  )
  $('#sql-file').change((e) ->
    console.log 'added sql file'
  )

  d3.xml 'pctest.csx', 'application/xml', (resp) ->
    loadedContext = xml2json(resp)
    schemaVersion = loadedContext.conceptualSchema.props.version
    app.schema = new app.schemas[schemaVersion](loadedContext.conceptualSchema)
    console.log "NEW CONTEXT", loadedContext, xml2json(resp)
    diagrams = d3.selectAll('#diagrams').selectAll('option')

    diagrams.data(app.schema.diagrams)
    .enter()
      .append('option').attr('value', (d, i) -> i)
      .text (d) -> d.title
    dispatch = d3.dispatch('load', 'change')
    dispatch.on 'load', () -> displayDiagram(0)
    dispatch.on 'change', displayDiagram
    dispatch.load 0
    d3.selectAll('#diagrams').on 'change', -> dispatch.change()
    loadedContext

  , (err) ->
    console "ups, gvnr"
displayDiagram = (d) ->
  
  d ?= d3.event.target.value
  console.log app.schema

  diagram = app.schema.diagrams[+d]
  console.log "NEW DIAGRAM", diagram
  svg = d3.select('svg#default-diagram')

  diagramGroup = svg.selectAll('g.diagram').data([diagram], (d) -> d.title)

  diagramGroup.exit().remove()
  diagramGroup.enter().append('g').attr('class', 'diagram')

  #add the edges
  edges = diagramGroup.selectAll('line').data(diagram.edges, (d) ->
    return "#{diagram.title}-#{d.props.from}-#{d.props.to}"
  )

  edges.exit().remove()
  edges.enter().append('line')
    .style('stroke', (d) -> return  if diagram.title then 'black' else '#333')
    .style('stroke-width', 2)
    .attr('x1', (d) ->
      from = parseInt(d.props['from'], 10) - 1
      pos = parseInt(diagram.concepts[from].position.props.x)
      return pos
    ).attr('x2', (d) ->
      to = parseInt(d.props['to']) - 1
      pos = parseInt(diagram.concepts[to].position.props.x)
      return pos
    ).attr('y1', (d) ->
      from = parseInt(d.props['from'], 10) - 1
      pos = parseInt(diagram.concepts[from].position.props.y)
      return pos
    ).attr('y2', (d) ->
      to = parseInt(d.props['to'], 10) - 1
      pos = parseInt(diagram.concepts[to].position.props.y, 10)
      return pos
    )

  
  
  #add the concepts!
  concepts = diagramGroup.selectAll('g.concept').data(diagram.concepts, (d) ->
    #console.log diagram.title + d.props.id
    diagram.title + d.props.id
  )
  r = d3.scale.linear().domain([0, d3.max(diagram.concepts, (d) ->
    d.objectContingent.objectRef?.length || 0
  )]).range([15, 30])

  concepts.exit().remove()

  concepts.enter()
    .append('g')
    .attr('class', 'concept')

  circles = concepts.append('circle')
  circles.style('fill', () -> return if diagram.title == "Status" then 'steelblue' else 'red')
        .attr('stroke', "#000")
        .attr('cy', (d) -> +d.position.props.y)
        .attr('cx', (d) -> +d.position.props.x)
        .attr('r',  (d) ->
          if d.hasObjects() then 10 else 3
        )


  concepts.each((d) ->
    
    concept = d3.select(this)
    if (d.hasAttributes())
      attrLabel = concept
        .append('g')
          .attr('class', 'concept-attribute-label')
          .attr('transform', (d) ->
            x = parseInt(d.position.props.x) + parseInt(d.attributeContingent.labelStyle?.offset?.props.x || 0) - 100/2
            y = parseInt(d.position.props.y) + parseInt(d.attributeContingent.labelStyle?.offset?.props.y || 0) - 12 - 15
            "translate(#{x}, #{y})"
          )
          
      attrLabel.append('rect')
          .attr('width', 100)
          .attr('height', (d) ->
            attrs = d.attributeContingent.attributeRef or d.attributeContingent.attribute
            num = if Array.isArray attrs then attrs.length else 1
            return 15 * num
          )
          .attr('fill', (d) -> d.attributeContingent.labelStyle?.bgColor?["#text"] || "#fff")
          .attr('stroke', "#000")
      attrLabel.append('text') .attr('fill', '#000')
          .text((d) ->
            attrs = d.getAttributes()
            unless Array.isArray attrs
              attrs.name
            else
              _.pluck(attrs, 'name')
          )
            .attr('text-anchor', 'middle')
            .attr('x', 50)
            .attr('y', 12)
      if d.objectContingent.object?.length
        objLabel = concept
          .append('g')
            .attr('class', 'concept-object-label')
            .attr('transform', (d) ->
              x = parseInt(d.position.props.x) + parseInt(d.objectContingent.labelStyle?.offset?.props.x || 0) - 20/2
              y = parseInt(d.position.props.y) + parseInt(d.objectContingent.labelStyle?.offset?.props.y || 0) + 12 + 15
              "translate(#{x}, #{y})"
            )
        objLabel.append('rect')
                .attr('width', 20)
                .attr('height', 15)
                .attr('fill', (d) -> d.objectContingent.labelStyle?.bgColor["#text"] || '#fff')
                .attr('stroke', "#000")
        objLabel.append('text').attr('fill', "#000")
          .text((d) -> d.objectContingent.object?.length || 0)
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
    window.positions = _.map diagram.concepts, (c) -> c.position.props
    console.log diagram.extent , positions
    maxY = boundingClientRect.height + 50
    console.log "EXTENT IS: #{diagram.extent.x[0]} #{diagram.extent.y[0]}"
    "#{minX} #{minY} #{boundingClientRect.width} #{maxY}"
  )


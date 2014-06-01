lang = 'coffeescript'

loadedContext = null

offsetX = 250
offsetY = 300

getAttribute = (id) ->
  context = loadedContext.conceptualSchema.context
  attribute = _(context.attribute).find((d) ->
    d.keyAttributes.id == id
  )
  return attribute


$(document).ready ->

  $('#csx-file').change((e) ->
    reader = new FileReader()
    reader.readAsText(e.target.files[0])
    reader.onload = ((e) -> console.log e.target.result)


  )
  $('#sql-file').change((e) ->
    console.log 'added sql file'
  )

  d3.xml 'fam.csx', 'application/xml', (resp) ->
    loadedContext = xml2json(resp)
    schema = loadedContext.conceptualSchema
    console.log loadedContext, xml2json(resp)
    diagrams = d3.selectAll('#diagrams').selectAll('option')

    diagrams.data(schema.diagram)
    .enter()
    .append('option').attr('value', (d, i) -> i)
    .text (d) -> d.keyAttributes.title
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
  diagram = loadedContext.conceptualSchema.diagram[+d]
  console.log "NEW DIAGRAM", diagram
  svg = d3.select('svg#default-diagram')

  diagramGroup = svg.selectAll('g.diagram').data([diagram], (d) -> d.keyAttributes.title)

  diagramGroup.exit().remove()
  diagramGroup.enter().append('g').attr('class', 'diagram')

  
  #add the edges
  edges = diagramGroup.selectAll('line').data(diagram.edge, (d) ->
    return "#{diagram.keyAttributes.title}-#{d.keyAttributes.from}-#{d.keyAttributes.to}"
  )

  edges.exit().remove()
  edges.enter().append('line')
    .style('stroke', (d) -> return  if diagram.keyAttributes.title then 'black' else '#333')
    .style('stroke-width', 2)
    .attr('x1', (d) ->
      from = parseInt(d.keyAttributes['from'], 10) - 1
      pos = parseInt(diagram.concept[from].position.keyAttributes.x) + offsetX
      return pos
    ).attr('x2', (d) ->
      to = parseInt(d.keyAttributes['to']) - 1
      pos = parseInt(diagram.concept[to].position.keyAttributes.x) + offsetX
      return pos
    ).attr('y1', (d) ->
      from = parseInt(d.keyAttributes['from'], 10) - 1
      pos = parseInt(diagram.concept[from].position.keyAttributes.y) + offsetY
      return pos
    ).attr('y2', (d) ->
      to = parseInt(d.keyAttributes['to'], 10) - 1
      pos = parseInt(diagram.concept[to].position.keyAttributes.y, 10) + offsetY
      return pos
    )

  
  
  #add the concepts!
  concepts = diagramGroup.selectAll('g.concept').data(diagram.concept, (d) ->
    console.log diagram.keyAttributes.title + d.keyAttributes.id
    diagram.keyAttributes.title + d.keyAttributes.id
  )
  r = d3.scale.linear().domain([0, d3.max(diagram.concept, (d) ->
    d.objectContingent.objectRef?.length || 0
  )]).range([15, 30])

  concepts.exit().remove()

  concepts.enter()
    .append('g')
    .attr('transform', (d) -> "translate(#{offsetX}, #{offsetY})")
    .attr('class', 'concept')

  circles = concepts.append('circle')
  circles.style('fill', () -> return if diagram.keyAttributes.title == "Status" then 'steelblue' else 'red')
        .attr('cy', (d) -> +d.position.keyAttributes.y)
        .attr('cx', (d) -> +d.position.keyAttributes.x)
        .attr('r',  30)


  concepts.each((d) ->
    concept = d3.select(this)
    if (d.attributeContingent.attributeRef)
      label = concept
        .append('g')
          .attr('class', 'concept-label')
          .attr('transform', (d) ->
            x = parseInt(d.position.keyAttributes.x) + parseInt(d.attributeContingent.labelStyle?.offset?.keyAttributes.x || 0) - 100/2
            y = parseInt(d.position.keyAttributes.y) + parseInt(d.attributeContingent.labelStyle?.offset?.keyAttributes.y || 0) - 30 - 15
            "translate(#{x}, #{y})"
          )
          
      label.append('rect')
          .attr('width', 100)
          .attr('height', 15)
          .attr('fill', (d) -> d.attributeContingent.labelStyle?.bgColor?["#text"] || "#fff")
          .attr('stroke', "#000")
      label.append('text') .attr('fill', '#000')
          .text((d) ->
            if (d.attributeContingent.attributeRef)
              attribute = getAttribute d.attributeContingent.attributeRef["#text"]
              attribute.keyAttributes.name
          )
            .attr('text-anchor', 'middle')
            .attr('x', 50)
            .attr('y', 12)
  )


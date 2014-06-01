lang = 'coffeescript'

loadedContext = null

offsetX = 250
offsetY = 300

getAttribute = (id) ->
  context = loadedContext.conceptualSchema.context
  console.log context
  attribute = _(context.attribute).find((d) ->
    console.log d
    d.keyAttributes.id == id
  )
  console.log 'getting attribute',id, attribute
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
    dispatch.on 'load', () -> displayDiagram(1)
    dispatch.on 'change', displayDiagram

    dispatch.load 0
    d3.selectAll('#diagrams').on 'change', -> dispatch.change()
    loadedContext

  , (err) ->
    console "ups, gvnr"

displayDiagram = (d) ->
  
  d ?= d3.event.target.value
  svg = d3.select('svg#default-diagram')

  diagram = loadedContext.conceptualSchema.diagram[+d]
  #add the concepts!
  concepts = svg.selectAll('circle').data(diagram.concept, (d) ->
    console.log diagram.keyAttributes.title + d.keyAttributes.id
    diagram.keyAttributes.title + d.keyAttributes.id
  )
  r = d3.scale.linear().domain([0, d3.max(diagram.concept, (d) ->
    d.objectContingent.objectRef?.length || 0
  )]).range([15, 30])

  concepts.exit().remove()
  concepts.enter()
    .append('circle')
    .style('fill', () -> return if diagram.keyAttributes.title == "Status" then 'steelblue' else 'red' )
    .attr('cy', (d) -> +d.position.keyAttributes.y + offsetY)
    .attr('cx', (d) -> +d.position.keyAttributes.x + offsetX)
    .attr('r',  30)


  edges = svg.selectAll('line').data(diagram.edge, (d) ->
    return "#{diagram.keyAttributes.title}-#{d.keyAttributes.from}-#{d.keyAttributes.to}"
  )

  edges.enter().append('line')
    .style('stroke', (d) -> return  if diagram.keyAttributes.title then 'black' else '#333')
    .style('stroke-width', 2)
    .attr('x1', (d) ->
      from = parseInt(d.keyAttributes['from'], 10) - 1
      console.log from, diagram.concept
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

  
  edges.exit().remove()


console.log "'Allo from #{lang}!"

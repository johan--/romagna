App.DiagramView = Ember.View.extend(

  tagName: 'svg'
  elementId: 'default-diagram'
  model: Ember.computed.alias('controller.model')
  attributeBindings: [ "preserveAspectRatio"]
  preserveAspectRatio: "xMidYMid meet"
  insertedElement: false
  viewBox: (() ->
    #if @get 'insertedElement'
      #boundingClientRect = @$()[0].getBBox()
    minX = @get('model.minX')
    minY = @get('model.minY')
    maxY = @get('model.maxY')
    maxX = @get('model.maxX')

    "#{minX} #{minY} #{maxX} #{maxY}"

  ).property('model.minX', 'model.minY', 'model.maxY', 'insertedElement')

  width: (() ->
    if @get('insertedElement')
      @$().parent().width()
  ).property('insertedElement')

  height: (() ->
    if @get('insertedElement')
      @$().parent().height()
  ).property('insertedElement')

  viewBoxObserver: ( () ->
  ).observes('viewBox', 'insertedElement')

  _updateDimensions: () ->
    @$().removeAttr('viewBox')
    @$().removeAttr('viewbox')
    @$().attr('width', @$().parent().width())
    @$().attr('height', @$().parent().height())
    d3.select(@$()[0]).attr('viewBox', @get('viewBox'))


  didInsertElement: ->
    @_super()
    @set('insertedElement', true)
    @_updateDimensions()
    Ember.run.once this, @get('draw')

  draw: () ->
    diagram = @get 'model'
    conceptModels = diagram.get('concepts.content')
    edgeModels = diagram.get('edges.content')
    svg = d3.select(@$()[0])

    diagramGroup = svg.selectAll('g.diagram').data([diagram], (d) -> d.get('title'))

    diagramGroup.exit().remove()
    diagramGroup.enter().append('g').attr('class', 'diagram')

    #add the edges
    edges = diagramGroup.selectAll('line').data(edgeModels, (d) -> d.get('id'))
    edges.exit().remove()
    edges.enter().append('line')
      .style('stroke', 'black')
      .style('stroke-width', 2)
      .attr('x1', (d) -> d.get('from.position.x'))
      .attr('x2', (d) -> d.get('to.position.x'))
      .attr('y1', (d) -> d.get('from.position.y'))
      .attr('y2', (d) -> d.get('to.position.y'))
    
    #add the concepts!
    concepts = diagramGroup.selectAll('g.concept')
              .data(conceptModels, (d) -> d.get('id'))

    concepts.exit().remove()

    concepts.enter()
      .append('g')
      .attr('class', 'concept')

    circles = concepts.append('circle')
    circles.style('fill', 'steelblue')
          .attr('stroke', "#000")
          .attr('cy', (d) -> d.get('position.y'))
          .attr('cx', (d) -> d.get('position.x'))
          .attr('r',  (d) -> if d.get('objects.length') then 10 else 3
          )
    #circles.on('click', (d) ->
      #console.log 'clicked a circle', d.id
      #d.selected = not d.selected
      #selection = d3.select(@)
      #connectedEdges = edges.filter((e) -> e.from is d.id or e.to is d.id)
      #console.log connectedEdges
      #connectedEdges.transition()
                    #.style('stroke-width', () -> if d.selected then 4 else 2)
      #d3.select(@).transition()
                    #.style('fill', (d) ->  if d.selected then 'blue' else 'red')
                    #.style('stroke-width', (d) -> if d.selected then 2 else 1)
    #)


    concepts.each((d) ->
      concept = d3.select(this)
      unless Ember.isEmpty d.get('attributes')
        attrLabel = concept
          .append('g')
            .attr('class', 'concept-attribute-label')
            .attr('transform', (d) ->
              x = d.get("position.x") + d.get("attributeLabel.offset.x") - 100/2
              y = d.get("position.y") + d.get("attributeLabel.offset.y") - diagram.get("fontSize") - diagram.get("lineHeight")
              "translate(#{x}, #{y})"
            )
            
        attrLabel.append('rect')
            .attr('height', (d) -> return 15 * d.get('attributes.length'))
            #.attr('fill', (d) -> d.get("attributeLabel.bgColor"))
            .attr('fill', '#fff')
            .attr('stroke', "#000")

        attrLabel.append('text').attr('fill', '#000')
          .each((d) ->
            attrs = d.get('attributes.content')
            d.get('attributes').forEach((attr, i) =>
              d3.select(@).append('tspan')
                          .attr('dx', 0)
                          .attr('dy', i * diagram.get("fontSize"))
                          .text(() -> attr.get('value'))
              d.set("textLength", @.getComputedTextLength())
            ))
            .attr('text-anchor', 'middle')
            .attr('x', () -> d3.max([@.getComputedTextLength()/2, 50]))
            .attr('y', 12)
        attrLabel.select('rect').attr('width', (d) -> d3.max([d.get("textLength") + 10, 100]))
      unless Ember.isEmpty d.get('objects')
        objLabel = concept
          .append('g')
            .attr('class', 'concept-object-label')
            .attr('transform', (d) ->
              x = d.get("position.x") + d.get("objectLabel.offset.x") - 20/2
              y = d.get("position.y") + d.get("objectLabel.offset.y") + diagram.get("fontSize") + 3
              "translate(#{x}, #{y})"
            )
        objLabel.append('rect')
                .attr('width', 20)
                .attr('height', 15)
                #.attr('fill', (d) -> d.get("objectLabel.bgColor"))
                .attr('fill', "#fff")
                .attr('stroke', "#000")
        objLabel.append('text').attr('fill', (d) -> d.get("objectLabel.textColor"))
          .text((d) -> d.get('objects.length'))
            .attr('text-anchor', 'middle')
            .attr('x', 10)
            .attr('y', 12)
    )
)

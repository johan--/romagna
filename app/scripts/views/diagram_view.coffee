App.DiagramView = Ember.View.extend(

  model: Ember.computed.alias('controller.model')
  didInsertElement: ->
    @_super()
    #@_updateDimensions()
    Ember.run.once this, @get('draw')

  draw: () ->
    diagram = @get 'model'
    nodeModels = diagram.get('nodes.content')
    edgeModels = diagram.get('edges.content')
    svg = d3.select('svg#default-diagram')

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
              .data(nodeModels, (d) -> d.get('id'))

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


    #concepts.each((d) ->
      #concept = d3.select(this)
      #if d.hasAttributes()
        #attrLabel = concept
          #.append('g')
            #.attr('class', 'concept-attribute-label')
            #.attr('transform', (d) ->
              #x = d.visual.position.x + d.visual.attributeLabel.offset.x - 100/2
              #y = d.visual.position.y + d.visual.attributeLabel.offset.y - diagram.options.fontSize - diagram.options.lineHeight
              #"translate(#{x}, #{y})"
            #)
            
        #attrLabel.append('rect')
            #.attr('height', (d) ->
              #attrs = d.attributes.attributeRef or d.attributes.attribute
              #num = if Array.isArray attrs then attrs.length else 1
              #return 15 * num
            #)
            #.attr('fill', (d) -> d.visual.attributeLabel.bgColor)
            #.attr('stroke', "#000")
        #attrLabel.append('text') .attr('fill', '#000')
            #.each((d) ->
              #attrs = d.getAttributes()
              #unless Array.isArray attrs
                #d3.select(@).text(attrs.name)
                #d.textLength = @.getComputedTextLength()
              #else
                #for i, e of _.pluck(attrs, 'name')
                  #d3.select(@).append('tspan')
                              #.attr('dx', 0)
                              #.attr('dy', i * diagram.options.fontSize).text(() -> e)
                  #d.textLength = @.getComputedTextLength()
            #)
              #.attr('text-anchor', 'middle')
              #.attr('x', () -> d3.max([@.getComputedTextLength()/2, 50]))
              #.attr('y', 12)
        #attrLabel.select('rect').attr('width', (d) -> d3.max([d.textLength + 10, 100]))
      #if d.hasObjects()
        #objLabel = concept
          #.append('g')
            #.attr('class', 'concept-object-label')
            #.attr('transform', (d) ->
              #x = parseInt(d.visual.position.x) + d.visual.objectLabel.offset.x - 20/2
              #y = parseInt(d.visual.position.y) + d.visual.objectLabel.offset.y + diagram.options.fontSize + 3
              #"translate(#{x}, #{y})"
            #)
        #objLabel.append('rect')
                #.attr('width', 20)
                #.attr('height', 15)
                #.attr('fill', (d) -> d.visual.objectLabel.bgColor)
                #.attr('stroke', "#000")
        #objLabel.append('text').attr('fill', (d) -> d.visual.objectLabel.textColor)
          #.text((d) -> d.objectCount() || 0)
            #.attr('text-anchor', 'middle')
            #.attr('x', 10)
            #.attr('y', 12)
    #)
)

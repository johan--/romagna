App.DiagramView = Ember.View.extend(

  tagName: 'svg'
  elementId: 'default-diagram'
  model: Ember.computed.alias('controller.model')
  attributeBindings: [ "preserveAspectRatio", "width", "height"]
  preserveAspectRatio: "xMidYMid meet"
  insertedElement: false
  defaultViewBox: "0 0 300 300"

  minX: Ember.computed.alias('model.minX')
  minY: Ember.computed.alias('model.minY')
  maxY: Ember.computed.alias('model.maxY')
  maxX: Ember.computed.alias('model.maxX')

  margin: 50
  boundingBox: ( ->
    @get('element')?.getBBox() or {width: 0, height: 0}
  ).property('insertedElement', 'model.id')

  viewBox: (() ->
    if @get 'insertedElement'
      minX = @get('minX') - @get('margin')
      minY = @get('minY') - @get('margin')
      maxY = @get('boundingBox.height') + @get('margin')
      maxX = @get('boundingBox.width')

      "#{minX} #{minY} #{maxX} #{maxY}"
    else @get  'defaultViewBox'

  ).property('minX', 'minY', 'boundingBox', 'insertedElement')

  width: (() ->
    if @get('insertedElement')
      @$().parent().width()
  ).property('element')

  height: (() ->
    if @get('insertedElement')
      @$().parent().height()
  ).property('element')

  viewBoxObserver: ( () ->
  ).observes('viewBox', 'insertedElement')

  _updateDimensions: ( ->
    elem = @$()
    elem.removeAttr('viewBox')
    elem.removeAttr('viewbox')
    elem.attr('width', @get('width'))
    elem.attr('height', @get('height'))
    console.log @get('element.getBBox.width'), @get('element').getBBox().width
    d3.select(@get('element')).attr('viewBox', @get('viewBox'))
  )

  didInsertElement: ->
    @_super()
    @_updateDimensions()
    $(window).on 'resize', Ember.run.bind(@, @_updateDimensions)
    Ember.run.once this, @get('draw')
    @set('insertedElement', true)
    Ember.run.next @, @get('_updateDimensions')

  willDestroyElement: ->
    $(window).off 'resize', Ember.run.bind(@, @_updateDimensions)


  modelObserver: (->
    d3.select(@get('element')).attr('viewBox', @get('defaultViewBox'))
    Ember.run.once this, @get('draw')
    Ember.run.next @, @get('_updateDimensions')
  ).observes('model.id')


  drawEdges: (diagram, diagramGroup)->

    edgeModels = diagram.get('edges.content')
    edges = diagramGroup.selectAll('line').data(edgeModels, (d) -> d.get('id'))
    edges.exit().remove()
    edges.enter().append('line')
      .style('stroke', 'black')
      .style('stroke-width', 2)
      .attr('x1', (d) -> d.get('from.position.x'))
      .attr('x2', (d) -> d.get('to.position.x'))
      .attr('y1', (d) -> d.get('from.position.y'))
      .attr('y2', (d) -> d.get('to.position.y'))

    return edges

  drawConcepts: (diagram, group)->

    conceptModels = diagram.get('concepts.content')

    concepts = group.selectAll('g.concept')
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
    return concepts

  drawLabels: (diagram, group, concepts) ->
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

  draw: () ->
    diagram = @get 'model'
    svg = d3.select(@get('element'))

    diagramGroup = svg.selectAll('g.diagram').data([diagram], (d) -> d.get('id'))

    diagramGroup.exit().remove()
    diagramGroup.enter().append('g').attr('class', 'diagram')

    @drawEdges(diagram, diagramGroup)
    concepts = @drawConcepts(diagram, diagramGroup)
    @drawLabels(diagram, diagramGroup, concepts)
    
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

)

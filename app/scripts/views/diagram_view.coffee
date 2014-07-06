App.DiagramView = Ember.View.extend(

  tagName: 'svg'
  elementId: 'default-diagram'
  model: Ember.computed.alias('controller.model')
  objectFilter: Ember.computed.alias('controller.objectFilter')
  attributeBindings: [ "preserveAspectRatio", "width", "height"]
  preserveAspectRatio: "xMidYMid meet"
  insertedElement: false
  defaultViewBox: "0 0 300 300"

  objectLabelDisplay: Ember.computed.alias('objectLabelDisplay')

  minX: Ember.computed.alias('model.minX')
  minY: Ember.computed.alias('model.minY')
  maxY: Ember.computed.alias('model.maxY')
  maxX: Ember.computed.alias('model.maxX')

  selectedNode: null
  selectedNodes: ( ->
    nodes = @get('selectedNode.connectedNodes') ? []
    unless Ember.isEmpty nodes
      nodes.pushObject @get('selectedNode')
    return nodes
  ).property('selectedNode')
  selectedEdges: ( ->
    @get('selectedNodes')?.map((n) -> n.get('allEdges.content')) ? []
  ).property('selectedNodes')

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

  width: ( ->
    if @get 'insertedElement'
      @$().parent().width()
  ).property('element', 'insertedElement')

  height: ( ->
    if @get 'insertedElement'
      @$().parent().height()
  ).property('element', 'insertedElement')

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
    d3.select(@get('element')).selectAll('rect.overlay')
                              .attr('width', @get('width'))
                              .attr('height', @get('height'))
                              .attr('transform', "translate(#{@get('minX') - 50}, #{@get('minY')- 50})")
  )

  didInsertElement: ->
    @_super()
    @_updateDimensions()
    $(window).on 'resize', Ember.run.bind(@, @_updateDimensions)
    Ember.run.once this, @get('draw')
    @set('insertedElement', true)
    Ember.run.next @, @get('_updateDimensions')
    Ember.run.next @, @get('_insertOverlay')

  willDestroyElement: ->
    $(window).off 'resize', Ember.run.bind(@, @_updateDimensions)


  modelObserver: (->
    d3.select(@get('element')).attr('viewBox', @get('defaultViewBox'))
    Ember.run.once @, @get('draw')
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

  drawConcepts: (diagram, group, edges)->

    conceptModels = diagram.get('concepts.content')
    view = @

    concepts = group.selectAll('g.concept')
              .data(conceptModels, (d) -> d.get('id'))

    concepts.exit().remove()

    concepts.enter()
      .append('g')
      .attr('class', 'concept')
      .attr('id', (d) -> "node-#{d.get('inDiagramId')}")

    circles = concepts.append('circle')
    circles.style('fill', 'steelblue')
          .attr('stroke', "#000")
          .attr('cy', (d) -> d.get('position.y'))
          .attr('cx', (d) -> d.get('position.x'))
          .attr('r',  (d) -> if d.intersectedObjects(view.get('objectFilter')).get('length') then 10 else 3
          )

    circles.on('click', (d) ->
      console.log 'clicked a circle', d.get('id'), d.get('connectedNodes')
      
      selection = d3.select(@)

      unless Ember.isEqual view.get('selectedNode'), d
        view.set 'selectedNode', d
      else
        view.set 'selectedNode', null

      connectedEdgeModels = view.get 'selectedEdges'
       
      connectedEdges = edges.filter (e) ->
        view.get('selectedEdges').contains(e)
      connectedNodes = circles.filter (c) ->
        view.get('selectedNodes').contains(c)

      edges.transition().style('stroke-width', (e) ->
        if view.get('selectedEdges').contains(e) then 5 else 2
      )
      circles.transition().style('fill', (d) ->
        if view.get('selectedNodes').contains(d) then 'red' else 'steelblue'
      ).style('stroke-width', (d) ->
        if view.get('selectedNodes').contains(d) then 3 else 1
      )
    )

    circles.on('dblclick', (d, e) ->
      d3.event.preventDefault()
      d3.event.stopImmediatePropagation?()
      d3.event.stopPropagation?()
      console.log 'trying to drill down, huh'
      view.get('controller').send('filterByConcept', d)
    )

    circles.on('mouseover', (d, e) ->
      console.log 'over a concept'
      view.get('controller').send('focusConcept', d)
    )

    return concepts

  drawLabels: (diagram, group, concepts) ->
    view = @
    concepts.each((d) ->
      concept = d3.select(this)
      unless Ember.isEmpty d.get('attributes')
        attrLabel = concept
          .append('g')
            .attr('class', 'concept-attribute-label')
            
        attrLabel.append('rect')
            .attr('height', (d) ->
              diagram.get('lineHeight') * d.get('attributes.length')
            )
            .attr('fill', (d) -> d.get("attributeLabel.bgColor"))
            .attr('stroke', "#000")

        spanWidths = []
        attrLabel.append('text')
                 .attr('fill', d.get('attributeLabel.textColor'))
          #.style('font-size', diagram.get('fontInPX'))
          .each((d) ->
            attrs = d.get('attributes.content')
            d.get('attributes').forEach((attr, i) =>
              d3.select(@).append('tspan')
                          .text(() -> attr.get('value'))
                          .attr('text-anchor', 'left')
                          .attr('x',3)
                          .attr('dy', i * diagram.get("lineHeight"))
                          .attr('text-anchor', ->
                            spanWidths.push @.getComputedTextLength()
                          )
              #d.set("textLength", @.getComputedTextLength())
            ))
            .attr('text-anchor', 'left')
            .attr('x', -> 3)
            .attr('y', diagram.get('lineHeight') - 1)
        attrLabel.select('rect').attr('width', (d) ->
          max = d3.max(spanWidths)
          d.set('textLength', max)
          max + 10
        )
        attrLabel.attr('transform', (d) ->
              x = d.get("position.x") +
                  d.get("attributeLabel.offset.x") -
                  d.get('textLength') + 10
              y = d.get("position.y") +
                  d.get("attributeLabel.offset.y") -
                  diagram.get("fontSize") -
                  diagram.get("lineHeight")
              "translate(#{x}, #{y})"
            )

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
                .attr('height', diagram.get('lineHeight'))
                .attr('fill', (d) -> d.get("objectLabel.bgColor"))
                .attr('stroke', "#000")
        objLabel.append('text').attr('fill', (d) -> d.get("objectLabel.textColor"))
          .text((d) -> d.intersectedObjects(view.get('objectFilter')).get('length'))
            .attr('text-anchor', 'middle')
            .attr('x', 10)
            .attr('y', -> diagram.get('lineHeight') - 2)
    )

  draw: () ->
    diagram = @get 'model'
    svg = d3.select(@get('element'))
    zoom = d3.behavior.zoom()
                      .scaleExtent([1, 6])
                      .on('zoom', Ember.run.bind(@, @_zoom))

    diagramGroup = svg.selectAll('g.diagram').data([diagram], (d) -> d.get('id'))
    diagramGroup.exit().remove()
    diagramGroup.enter().append('g').attr('class', 'diagram').call(zoom)

    overlay = diagramGroup.append('rect')
    overlay.classed({overlay: true})


    edges = @drawEdges(diagram, diagramGroup)
    concepts = @drawConcepts(diagram, diagramGroup, edges)
    @drawLabels(diagram, diagramGroup, concepts)
    
  _zoom: () ->
    d3.select(@get('element')).select('g.diagram').attr("transform", "translate(#{d3.event.translate})scale(#{d3.event.scale})")

  _insertOverlay : ->

)

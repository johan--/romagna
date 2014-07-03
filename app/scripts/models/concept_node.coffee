App.ConceptNode = DS.Model.extend(
  inDiagramId:          DS.attr('string')
  position:             DS.attr('dimension')
  objects:              DS.hasMany('object')
  attributes:           DS.hasMany('attribute')

  objectLabel:          DS.belongsTo('label_info')
  attributeLabel:       DS.belongsTo('label_info')

  inboundEdges:         DS.hasMany('edge', {inverse: 'to'})
  outboundEdges:        DS.hasMany('edge', {inverse: 'from'})

  allEdges:             Ember.computed.union('inboundEdges', 'outboundEdges')
  connectedNodes:       Ember.computed.union('filteredNodes', 'idealNodes')

  idealNodes: ( ->
    nodes = []

    inboundNodes = @get('inboundEdges').map((d) -> d.get('from'))

    while inboundNodes.get('length')
      nodes.pushObjects inboundNodes
      newInboundEdges = _.flatten inboundNodes.map (d) ->
        d.get 'inboundEdges.content'
      
      newInboundNodes = newInboundEdges.mapBy('from')
      inboundNodes = newInboundNodes

    return nodes
  ).property('inboundEdges')

  filteredNodes: ( ->
    nodes = []

    outboundNodes = @get('outboundEdges').map((d) -> d.get 'to')

    while outboundNodes.get('length')
      nodes.pushObjects outboundNodes
      newOutboundEdges = _.flatten(outboundNodes.map((d) ->
        d.get 'outboundEdges.content')
      )
      newOutboundNodes = newOutboundEdges.mapBy('to')
      outboundNodes = newOutboundNodes

    return nodes
  ).property('outboundEdges')

  allObjects: ( ->
    @get('filteredNodes').reduce((previousValue, item) ->
      previousValue.pushObjects item.get('objects.content')
      return previousValue.uniq()
    , @get('objects.content').copy())
  ).property('filteredNodes')

  allAttributes: ( ->
    @get('idealNodes').reduce((previousValue, item) ->
      previousValue.pushObjects item.get('attributes.content')
      return previousValue.uniq()
    , @get('attributes.content').copy())
  ).property('idealNodes')

)

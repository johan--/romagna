App.Edge = DS.Model.extend(
  to: DS.belongsTo('concept_node', {inverse: 'inboundEdges'})
  from: DS.belongsTo('concept_node', {inverse: 'outboundEdges'})

)

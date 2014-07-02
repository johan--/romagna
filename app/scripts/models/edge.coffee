App.Edge = DS.Model.extend(
  to: DS.belongsTo('node', {inverse: 'inboundEdges'})
  from: DS.belongsTo('node', {inverse: 'outboundEdges'})

)

App.Node = DS.Model.extend(
  position:             DS.attr('dimension')
  concept:              DS.belongsTo('concept')
  objectLabel:          DS.belongsTo('label_info')
  attributeLabel:       DS.belongsTo('label_info')
  inboundEdges:         DS.hasMany('edge', {inverse: 'to'})
  outboundEdges:        DS.hasMany('edge', {inverse: 'from'})
)

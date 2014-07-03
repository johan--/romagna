App.ConceptNode = DS.Model.extend(
  position:             DS.attr('dimension')
  objects:            DS.hasMany('object')
  attributes:         DS.hasMany('attribute')
  objectLabel:          DS.belongsTo('label_info')
  attributeLabel:       DS.belongsTo('label_info')
  inboundEdges:         DS.hasMany('edge', {inverse: 'to'})
  outboundEdges:        DS.hasMany('edge', {inverse: 'from'})
)

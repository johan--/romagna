App.Concept = DS.Model.extend(

  objects:            DS.hasMany('object')
  attributes:         DS.hasMany('attribute')
  context:            DS.belongsTo('context')
  node:               DS.belongsTo('node')

)

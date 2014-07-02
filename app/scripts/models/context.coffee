App.Context = DS.Model.extend(
  objects:    DS.hasMany('object')
  attributes: DS.hasMany('attribute')
  schema:     DS.belongsTo('conceptual_schema')
)

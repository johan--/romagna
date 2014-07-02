App.ConceptualSchema = DS.Model.extend(
  name:       DS.attr('string')
  version:    DS.attr('string')
  diagrams:   DS.hasMany('diagrams')
  context:    DS.belongsTo('context')
  concepts:   DS.hasMany('concept')
)


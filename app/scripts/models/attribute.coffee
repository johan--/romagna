App.Attribute = DS.Model.extend(
  value: DS.attr('string')
  concepts: DS.hasMany('concept_node')
)

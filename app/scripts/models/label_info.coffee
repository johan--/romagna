App.LabelInfo = DS.Model.extend(
  offset:     DS.attr('dimension')
  bgColor:    DS.attr('string')
  textColor:  DS.attr('string')
  concept: DS.belongsTo('concept')
)

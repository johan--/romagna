App.Diagram = DS.Model.extend(
  title:        DS.attr('string')
  fontSize:     DS.attr('number', {defaultValue: 10})
  lineHeight:   DS.attr('number', {defaultValue: 11})

  fontInPX:   (-> "#{@get('fontSize')}px").property('fontSize')
  positionsX: Ember.computed.mapBy('concepts', 'position.x')
  positionsY: Ember.computed.mapBy('concepts', 'position.y')

  minX: Ember.computed.min('positionsX')
  minY: Ember.computed.min('positionsY')
  maxX: Ember.computed.max('positionsX')
  maxY: Ember.computed.max('positionsY')

  extentX: Ember.computed.collect('minX', 'maxX')
  extentY: Ember.computed.collect('minY', 'maxY')

  concepts:      DS.hasMany('concept_node')
  edges:         DS.hasMany('edge')
)

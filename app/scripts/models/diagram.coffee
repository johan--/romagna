App.Diagram = DS.Model.extend(
  title:        DS.attr('string')
  fontSize:     DS.attr('number', {defaultValue: 12})
  lineHeight:   DS.attr('number', {defaultValue: 15})

  min:        DS.attr('dimension', {defaultValue: {x: 0, y: 0}})
  max:        DS.attr('dimension', {defaultValue: {x: 0, y: 0}})

  nodes:      DS.hasMany('node')
  edges:      DS.hasMany('edge')


  computeExtent: () ->
    @extent ?= {}
    positions = _.map @concepts, (c) -> c.visual.position
    @extent.x = d3.extent(_.pluck(positions, 'x'))
    @extent.y = d3.extent(_.pluck(positions, 'y'))
)

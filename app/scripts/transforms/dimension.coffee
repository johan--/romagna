App.DimensionTransform = DS.Transform.extend(
  serialize: (value) ->
    {x: value.x, y: value.y}
  deserialize: (value) ->
    Ember.create {x: value.x, y: value.y}
)

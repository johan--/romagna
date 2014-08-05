App.DiagramOptionView = Ember.SelectOption.extend(
  doubleClick: (e) ->
    @_super()
    value = @$().val()
    model = @get('parentView.content').findBy('id', value)
    @get('controller').send('addToQueue', model)
)

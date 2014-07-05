App.DiagramOptionView = Ember.SelectOption.extend(
  doubleClick: (e) ->
    @_super()
    value = @$().val()
    model = @get('parentView.content').findBy('id', value)
    console.log 'ce cacat', @$().val(), model, @get('parentView.content')
    @get('controller').send('addToQueue', model)
)

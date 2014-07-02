@App = Ember.Application.create()

Ember.Application.initializer(
  name: 'test'
  initialize: (container, application) ->
    console.log 'initialized app'
    container.lookup('store:main').reopen(
      findByIdOrCreate: (type, id, attr) ->
        @getById(type, id) ? @createRecord type, attr
    )
)

App.ApplicationStore = DS.Store.extend(
  adapter: 'DS.FixtureAdapter'
)

App.getStore = () ->
  return @.__container__.lookup('store:main')


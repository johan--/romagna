App.DiagramRoute = Ember.Route.extend(

  afterModel: (model) ->
    console.log arguments
    if model is null
      @transitionToRoute 'application'
  setupController: (controller, model) ->
    console.log 'hai guyz!', model.get('title')
    @controllerFor('application').get('contextParser').parseSingleDiagram(@controllerFor('application').get('csxJSON.conceptualSchema'), model.get('title'), model.get('id'))
    controller.set 'model', model

  actions:
    error: () ->
      @transitionTo 'application'
)

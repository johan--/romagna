App.DiagramRoute = Ember.Route.extend(

  afterModel: (model) ->
    if model is null
      @transitionToRoute 'application'
  setupController: (controller, model) ->
    @controllerFor('application').get('contextParser').parseSingleDiagram(@controllerFor('application').get('csxJSON.conceptualSchema'), model.get('title'), model.get('id'))
    controller.set 'model', model


  actions:
    error: () ->
      @transitionTo 'application'

    willTransition: (transition) ->
      controller = @controllerFor('diagram')
      console.log transition.params.diagram.diagram_id, controller.get('diagramQueue'), controller.get('queueIndex'), controller.get('diagramQueue')[controller.get('queueIndex') - 2].get('id')


      if controller.get('queueIndex') >= 2
        if transition.params.diagram?.diagram_id == controller.get('diagramQueue')[controller.get('queueIndex') - 2].get('id')
          controller.get('pastConcepts').popObject()
)

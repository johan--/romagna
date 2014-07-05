App.DiagramRoute = Ember.Route.extend(

  setupController: (controller, model) ->
    console.log 'hai guyz!', model.get('title')
    @controllerFor('application').get('contextParser').parseSingleDiagram(@controllerFor('application').get('csxJSON.conceptualSchema'), model.get('title'), model.get('id'))
    controller.set 'model', model
)

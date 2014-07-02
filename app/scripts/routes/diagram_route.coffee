App.DiagramRoute = Ember.Route.extend(
  model: (params, transition, queryParams) ->
    diagram = @store.getById('diagram', params.diagram_id)
    console.log diagram.get('title')


  setupController: (controller, model) ->
    console.log 'hai guyz!', model.get('title')
    @controllerFor('application').get('contextParser').parseSingleDiagram(@controllerFor('application').get('csxJSON.conceptualSchema'), model.get('title'))
    controller.set 'model', model
)

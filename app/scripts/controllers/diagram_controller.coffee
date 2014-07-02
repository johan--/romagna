App.DiagramController = Ember.ObjectController.extend(
  needs: ['application']
  parser: Ember.computed.alias 'controllers.application.contextParser'

  extractDiagram: () ->
    @get('parser').parseSingleDiagram(@get('controllers.application.csxJSON.conceptualSchema'), @get('model.title'))
)

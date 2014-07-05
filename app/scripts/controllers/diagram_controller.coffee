App.DiagramController = Ember.ObjectController.extend(
  needs: ['application', 'sidebar']
  pastConcepts: []
  parser: Ember.computed.alias 'controllers.application.contextParser'
  objectLabelDisplay: 'count'

  extractDiagram: () ->
    @get('parser').parseSingleDiagram(@get('controllers.application.csxJSON.conceptualSchema'), @get('model.title'))

  actions:
    filterByConcept: (concept) ->
      @pastConcepts.pushObject concept
      @get('controllers.sidebar').send('advanceInQueue')

  availableObjects: ( ->
    if @get('pastConcepts.length') >= 1
      @get('pastConcepts').reduce((previousValue, item, index) ->
        Ember.EnumerableUtils.intersection(previousValue, item.get('objects'))
      ,@get('pastConcepts.firstObject.objects'))
    else
      return null
  ).property('pastConcepts.@each')
)

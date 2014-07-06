App.DiagramController = Ember.ObjectController.extend(
  needs: ['application', 'sidebar']
  parser: Ember.computed.alias 'controllers.application.contextParser'
  pastConcepts: Ember.computed.alias 'controllers.sidebar.pastConcepts'
  objectLabelDisplay: 'count'

  extractDiagram: () ->
    @get('parser').parseSingleDiagram(@get('controllers.application.csxJSON.conceptualSchema'), @get('model.title'))

  objectFilter: ( ->
    if @get('pastConcepts.length') >= 1
      @get('pastConcepts').reduce((previousValue, item, index) ->
        Ember.EnumerableUtils.intersection(previousValue, item.get('objects'))
      ,@get('pastConcepts.firstObject.objects'))
    else
      return null
  ).property('pastConcepts.@each')

  actions:
    filterByConcept: (concept) ->
      @get('pastConcepts').pushObject concept
      @get('controllers.sidebar').send('advanceInQueue')

    focusConcept: (concept) ->
      @set('controllers.sidebar.focusedConcept', concept)

)

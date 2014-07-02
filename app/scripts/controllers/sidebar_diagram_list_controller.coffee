App.SidebarDiagramListController = Ember.ArrayController.extend(
  needs: ['application']

  currentDiagram: null
  content: Ember.computed.alias 'controllers.application.diagrams'
  currentDiagramObserver: (() ->
    console.log "changed current diagram"
    @transitionToRoute('diagram', @get('currentDiagram'))
  ).observes('currentDiagram')
)

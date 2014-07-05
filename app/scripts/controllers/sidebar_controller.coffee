App.SidebarController = Ember.Controller.extend(
  needs: ['application', 'diagram']

  needsSQL: false
  csx: Ember.computed.alias 'controllers.application.csx'
  csxFileName: Ember.computed.alias 'controllers.application.csxFileName'
  diagramList: Ember.computed.alias 'controllers.application.diagrams'
  objectLabelDisplay: Ember.computed.alias 'controllers.diagram.objectLabelDisplay'
  currentDiagram: null

  diagramQueue: []
  currentQueuedDiagram: null

  objectLabelDisplayOptions: [
    {label: "Display count", value: "count"}
    {label: "Display list", value: "list"}
  ]

  diagramQueueObserver: ( ->
    console.log  'changed first object of the diagram queue', @get('diagramQueue.firstObject')
    unless @get('diagramQueue.firstObject') is undefined or
           @get('diagramQueue.firstObject') is null
      @set 'currentQueuedDiagram', @get('diagramQueue.firstObject')
  ).observes('diagramQueue.firstObject')

  currentQueuedDiagramObserver: (() ->
    console.log "changed current diagram", @get('currentQueuedDiagram.title')
    unless @get('currentQueuedDiagram') is undefined or
           @get('currentQueuedDiagram') is null
      @transitionToRoute('diagram', @get('currentQueuedDiagram'))
  ).observes('currentQueuedDiagram')

  actions:
    parseCSX: (uploadedFile, fileName) ->
      console.log 'pretty neat actually ^_^', fileName
      @set 'csxFileName', fileName
      @set 'csx', uploadedFile

    addToQueue: (diagram) ->
      @get('diagramQueue').pushObject diagram
)

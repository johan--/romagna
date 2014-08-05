App.ApplicationController = Ember.Controller.extend(
  csx: null
  csxFileName: null
  domParser: new DOMParser()
  xmlParser: new X2JS()
  contextParser: App.ContextParser.create()
  parsedCSX: null
  diagrams: []

  schemaName: (() ->
    return @get('csxFileName').split('.')[0] or ''
  ).property('csxFileName')

  csxObserver: (() ->
    console.log 'changed csx file', @get 'csxFileName'
    dom = @get('domParser').parseFromString(@get('csx'), 'text/xml')
    jsonCSX = @get('xmlParser').xml2json dom
    @send 'parseCSX', jsonCSX
  ).observes('csx')

  actions:
    parseCSX: (csx) ->
      version = csx.conceptualSchema._version
      @set 'csxJSON', csx
      schema = csx.conceptualSchema
      
      @set 'conceptualSchema', @get('contextParser').parse(schema, version, @store, @get('schemaName'))
      @set 'diagrams', @get ('conceptualSchema.diagrams')

)

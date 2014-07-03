App.SidebarController = Ember.Controller.extend(
  needs: ['application']
  needsSQL: false
  csx: Ember.computed.alias 'controllers.application.csx'
  csxFileName: Ember.computed.alias 'controllers.application.csxFileName'
  objectLabelDisplay: 'count'

  objectLabelDisplayOptions: [
    {label: "Display count", value: "count"}
    {label: "Display list", value: "list"}
  ]

  actions:
    parseCSX: (uploadedFile, fileName) ->
      console.log 'pretty neat actually ^_^', fileName
      @set 'csxFileName', fileName
      @set 'csx', uploadedFile
)

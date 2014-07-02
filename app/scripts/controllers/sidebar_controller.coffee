App.SidebarController = Ember.Controller.extend(
  needs: ['application']
  csx: Ember.computed.alias 'controllers.application.csx'
  csxFileName: Ember.computed.alias 'controllers.application.csxFileName'

  actions:
    parseCSX: (uploadedFile, fileName) ->
      console.log 'pretty neat actually ^_^', fileName
      @set 'csxFileName', fileName
      @set 'csx', uploadedFile
)

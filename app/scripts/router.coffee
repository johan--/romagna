#App.Router.reopen
  #location: 'history'

App.Router.map ->
  @resource 'diagram', {path: '/:diagram_id'}

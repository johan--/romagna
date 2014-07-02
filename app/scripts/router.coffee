#App.Router.reopen
  #location: 'history'

App.Router.map ->
  @resource 'diagram', {path: '/diagram/:diagram_id'}

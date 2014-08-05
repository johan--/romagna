App.ApplicationRoute = Ember.Route.extend(


  renderTemplate: () ->
    @render()
    @render 'sidebar', outlet: 'sidebar', into: 'application'

  setupController: (controller) ->

    #d3.xml 'pctest.csx', 'application/xml', loadContext
    #, (err) ->
      #console "ups, gvnr"
)

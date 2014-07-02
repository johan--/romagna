App.ApplicationRoute = Ember.Route.extend(


  renderTemplate: () ->
    @render()
    @render 'sidebar', outlet: 'sidebar', into: 'application'

  setupController: (controller) ->
    console.log 'here with my homie', controller

    #d3.xml 'pctest.csx', 'application/xml', loadContext
    #, (err) ->
      #console "ups, gvnr"
)

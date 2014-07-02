App.Object = DS.Model.extend(
  value: DS.attr('string')
  #query: DS.attr('string') #maybe we have a query...
  concepts: DS.hasMany('concept')
)

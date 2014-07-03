App.RadioButton = Ember.Component.extend(
  tagName : "input"
  type : "radio"
  attributeBindings : [ "name", "type", "value", "checked:checked" ]
  click : ->
    @set("selection", @().val())
  
  checked: (->
    @get("value") == this.get("selection")
  ).property('selection')
)



App.LabelRadioComponent = Ember.Component.extend(
  name: 'radio'
)

Ember.Handlebars.helper('radio-button',App.RadioButton)

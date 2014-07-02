App.FileUploadComponent = Ember.TextField.extend(
  type: 'file'
  attributeBindings: 'name'
  change: (ev) ->
    console.log 'Changed file'
    input = ev.target
    if input.files and input.files[0]
      reader = new FileReader()
      reader.onload = (e) =>
        console.log 'We read the file!', input.files[0].name
        uploaded = e.target.result
        @sendAction 'action', uploaded, input.files[0].name
      
      reader.readAsText(input.files[0])
)

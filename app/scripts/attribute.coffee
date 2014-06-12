class @Attribute
  constructor: (options) ->
    if typeof options is 'string'
      @name = options
    else
      @name = options.props?.name
      @id = options.props?.id

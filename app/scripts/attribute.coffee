class @Attribute
  constructor: (options) ->
    if options["#text"]
      @name = options["#text"]
    else
      @name = options.props?.name
      @id = options.props?.id

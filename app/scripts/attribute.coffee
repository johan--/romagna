class @Attribute
  constructor: (options) ->
    switch
      when typeof options is 'string' then @name = options
      when options["#text"] then @name = options["#text"]
      else
        @name = options.props?.name
        @id = options.props?.id

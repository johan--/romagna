if(!Array.isArray)
  Array.isArray = (arg) ->
    return Object.prototype.toString.call(arg) == '[object Array]'

String::convertToRGBA = () ->
  hex = @.replace '#', ''
  switch hex.length
    when 3
      r = parseInt(hex.substring(0, 1), 16)^2
      g = parseInt(hex.substring(1, 2), 16)^2
      b = parseInt(hex.substring(2, 3), 16)^2
      a = 1
    when 4
      a = parseInt(hex.substring(0, 1), 16)^2 / 256
      r = parseInt(hex.substring(1, 2), 16)^2
      g = parseInt(hex.substring(2, 3), 16)^2
      b = parseInt(hex.substring(3, 4), 16)^2
    when 8
      a = parseInt(hex.substring(0, 2), 16) / 256
      r = parseInt(hex.substring(2, 4), 16)
      g = parseInt(hex.substring(4, 6), 16)
      b = parseInt(hex.substring(6, 8), 16)
    when 6
      r = parseInt(hex.substring(0, 2), 16)
      g = parseInt(hex.substring(2, 4), 16)
      b = parseInt(hex.substring(4, 6), 16)
      a = 1
  "rgba(#{r}, #{g}, #{b}, #{a})"



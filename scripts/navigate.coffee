# Description:
#   Get directions between two locations
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   nav <origin> to <destination> - Find a route (the 'to' can changed to a '...')
#
# Author:
#   sleekslush

routeMe = (msg, origin, destination) ->
  msg.http("http://maps.googleapis.com/maps/api/directions/json")
    .query({
      origin: origin,
      destination: destination,
      sensor: false})
    .get() (err, res, body) ->
      msg.send parse_directions body

parse_directions = (body) ->
  directions = JSON.parse body
  first_route = directions.routes[0]
  
  if not first_route
    return "Couldn't find directions, sorry :("

  final_directions = []

  for leg in first_route.legs
    do (leg) ->
      final_directions.push leg.start_address + " -> " + leg.end_address + ":"
  
      for step in leg.steps
        do (step) ->
          instructions = step.html_instructions.replace /<[^>]+>/g, ''
          if /continue/i.test(instructions)
            return

          instructions = instructions.replace /\band\b/i, '&'
          instructions = instructions.replace /\bthe\b ?/i, ''
          instructions = instructions.replace /\btoward\b/i, 'twrd'
          instructions = instructions.replace /\bmerge onto\b/i, 'merge on'
          instructions = instructions.replace /( )onto\b/i, ':'
          instructions = instructions.replace /\bfollow signs for\b/i, 'signs for'

          instructions = instructions.replace /\bstreet\b/i, 'st'
          instructions = instructions.replace /\broad\b/i, 'rd'
          instructions = instructions.replace /\bplace\b/i, 'plc'
          instructions = instructions.replace /\bdrive\b/i, 'dr'
          instructions = instructions.replace /\bcounty\b/i, 'cnty'

          instructions = instructions.replace /^Turn /i, ''
          instructions = instructions.replace /^Take Exit /i, 'Exit on '
          instructions = instructions.replace /^Head /i, ''
          instructions = instructions.replace /^Keep /i, ''

          instructions = instructions.replace /north/i, 'N'
          instructions = instructions.replace /east/i, 'E'
          instructions = instructions.replace /south/i, 'S'
          instructions = instructions.replace /west/i, 'W'

          instructions = instructions.replace /left/i, 'L'
          instructions = instructions.replace /right/i, 'R'

          instructions = instructions.replace /^./i, (x) -> x.toUpperCase()

          instructions = instructions.replace /\bexit on (.+) to merge on/i, "Exit $1 ->"
          instructions = instructions.replace /Destination .*$/i, ''

          final_directions.push instructions + " (#{step.distance.text})"

  x = final_directions.join("\n")
  return x

module.exports = (robot) ->
  robot.respond /nav(?:igate)? (.+)\b *\.\.\. *\b(.+)/i, (msg) ->
    [origin, destination] = msg.match[1..2]
    routeMe(msg, origin, destination)

  robot.respond /nav(?:igate)?(?: from)? (.+)\b to \b(.+)/i, (msg) ->
    [origin, destination] = msg.match[1..2]
    routeMe(msg, origin, destination)

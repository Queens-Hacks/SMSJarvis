# Description
#   Grabs the current forecast from Dark Sky
#
# Dependencies
#   None
#
# Configuration
#   HUBOT_DARK_SKY_API_KEY
#
# Commands:
#   weather <location> - Get the weather for <location>
#
# Author:
#   kyleslattery
#   awaxa
module.exports = (robot) ->
  robot.respond /weather (.+)/i, (msg) ->
    location = msg.match[1]

    msg.http("http://maps.googleapis.com/maps/api/geocode/json")
      .query({
        sensor: false
        address: location
      })
      .get() (err, res, body) ->
        result = JSON.parse(body)

        if result.results.length > 0
          lat = result.results[0].geometry.location.lat
          lng = result.results[0].geometry.location.lng
          darkSkyMe msg, lat,lng , (darkSkyText) ->
            msg.send "Weather for #{result.results[0].formatted_address}\n#{darkSkyText}"
        else
          msg.send "Couldn't find a location for '#{location}'"

darkSkyMe = (msg, lat, lng, cb) ->
  url = "https://api.forecast.io/forecast/#{process.env.HUBOT_DARK_SKY_API_KEY}/#{lat},#{lng}/?units=si"
  msg.http(url)
    .get() (err, res, body) ->
      result = JSON.parse(body)

      if result.error
        cb "#{result.error}"
        return

      cb """Now: #{result.currently.summary} #{result.currently.temperature}°C
            Today: #{result.hourly.summary}
            Tomorrow: #{result.daily.data[1].summary}"""

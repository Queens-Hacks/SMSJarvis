# Description:
#   Provides dictionary definitions from Glosbe and urban dictionary
#
# Commands:
#   define <query> - definition
#   udefine <query> - Urban dictionary definition
#

module.exports = (robot) ->
  robot.respond /(u)?define (.+)/i, (msg) ->
    word = msg.match[2]
    if msg.match[1]
      msg.http("http://api.urbandictionary.com/v0/define?term=#{word}")
        .get() (err, res, body) ->
          result = JSON.parse(body)
          if result.list.length
            msg.send result.list[0].definition
          else
           msg.send "No urban definition found"
    else
      msg.http("http://glosbe.com/gapi/translate?from=eng&dest=eng&format=json&phrase=#{word}")
        .get() (err, res, body) ->
          results = JSON.parse(body)
          try
            msg.send results["tuc"][0]["meanings"][0]["text"]
          catch
            msg.send "No definition found"

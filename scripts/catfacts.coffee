# Description:
#   Retrieves random cat facts.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Author:
#   scottmeyer

module.exports = (robot) ->
  robot.respond /catfact/i, (msg) ->
    msg.http('http://catfacts-api.appspot.com/api/facts?number=1')
      .get() (error, response, body) ->
        # passes back the complete reponse
        response = JSON.parse(body)
        if response and response.success == "true"
          msg.send response.facts[0]
        else
          msg.send "Sorry, unable to get cat facts right now."
				
				

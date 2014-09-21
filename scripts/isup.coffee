# Description:
#   Uses isitup.org to check if a site is up
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   isup <domain> - Checks if <domain> is up
#
# Author:
#   jmhobbs

module.exports = (robot) ->
  robot.respond /isup (?:http\:\/\/)?(.*)/i, (msg) ->
    domain = msg.match[1]
    msg.http("http://isitup.org/#{domain}.json")
      .header('User-Agent', 'Hubot')
      .get() (err, res, body) ->
        response = JSON.parse(body)
        if response.status_code is 1
          msg.send "#{response.domain} looks up from here."
        else if response.status_code is 2
          msg.send "#{response.domain} looks down from here."
        else if response.status_code is 3
          msg.send "'#{response.domain}' is not a valid domain."
        else
          msg.send "#{response.domain} returned an error."

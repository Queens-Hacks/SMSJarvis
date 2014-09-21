# Description:
#   sandbox - run javascript in a sandbox!
#
# Dependencies:
#   "sandbox": "0.8.3"
#
# Configuration:
#   None
#
# Commands:
#
# Author:
#   ajacksified

Sandbox = require('sandbox')

module.exports = (robot) ->
  robot.respond /js (.+)/i, (msg) ->
    sandbox = new Sandbox
    sandbox.run(msg.match[1], (output) ->
      msg.send output.result
    )

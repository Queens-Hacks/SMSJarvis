# Description:
#   Send an error message when no command can be found
#

module.exports = (robot) ->
  robot.catchAll (msg) ->
    msg.send "I'm sorry, I don't know how to respond to that."

# Description:
#   Send an error message when no command can be found
#

sayings = [
    "I'm sorry, I don't know how to respond to that.",
    "Those words render me speechless.",
    "Sorry, I didn't understand that.",
    "DOES NOT COMPUTE\n\n...Sorry. My robotic side comes out sometimes.",
    "Why would ask that?",
    "That doesn't make any sense...",
    "I'm sorry, I can't help you with that.",
    "I didn't understand that. Would you like to try turning me off and on again?"
]

module.exports = (robot) ->
  robot.catchAll (msg) ->
    text = msg.message.text.trim()
    if not text.length
      return
    msg.send msg.random sayings

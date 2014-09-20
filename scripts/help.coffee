# Description:
#   Generates help commands for Hubot.
#
# Commands:
#   ? - Display all help commands
#   ? <query> - Display details on command <query>
#
# Notes:
#   These commands are grabbed from comment blocks at the top of each file.

module.exports = (robot) ->
  robot.respond /(hello|hi|hey|yo|sup|good evening|good morning|greetings)\b.*/i, (msg) ->
    msg.send """Greetings human, I'm Jarvis, your SMS assistant.
                Ask me what I can do by sending me a '?'"""

  robot.respond /\?\s*(.*)?$/i, (msg) ->
    cmds = robot.helpCommands()
    filter = msg.match[1]

    if filter
      cmds = cmds.filter (cmd) ->
        cmd.match new RegExp(filter, 'i')
      if cmds.length == 0
        msg.send "No available commands match #{filter}"
        return

    prefix = robot.alias or robot.name
    cmds = cmds.map (cmd) ->
      cmd = cmd.replace /hubot/ig, robot.name
      cmd = cmd.replace new RegExp("^#{robot.name}"), prefix
      # Only display extended help for help helps (yo dawg)
      cmd.replace(/(\?.*)|(.+) - .*/i, "$1$2")

    emit = cmds.join "\n"

    msg.send emit

# Description:
#   Allows Hubot to roll dice
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   roll <x>d<y> - roll <x> dice with <y> sides
#
# Author:
#   ab9

module.exports = (robot) ->
  robot.respond /roll (\d+)d?(\d*)/i, (msg) ->
    dice = parseInt msg.match[1]
    sides = parseInt msg.match[2] || 6
    answer = if sides < 1
      "I don't know how to roll a zero-sided die."
    else if sides > 100
      "Unfortunately I don't have any dice with more than 100 sides."
    else if dice > 100
      "I'm not going to roll more than 100 dice for you."
    else
      report roll dice, sides
    msg.send answer

report = (results) ->
  if results?
    switch results.length
      when 0
        "I didn't roll any dice."
      when 1
        "I rolled a #{results[0]}."
      else
        total = results.reduce (x, y) -> x + y
        finalComma = if (results.length > 2) then "," else ""
        last = results.pop()
        "I rolled #{results.join(", ")}#{finalComma} and #{last}, making #{total}."

roll = (dice, sides) ->
  rollOne(sides) for i in [0...dice]

rollOne = (sides) ->
  1 + Math.floor(Math.random() * sides)

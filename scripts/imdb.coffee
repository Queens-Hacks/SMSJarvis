#
# Description:
#   Get the synposis for a given movie/tv show/episode
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot imdb days of future past
#
# Author:
#   pR0Ps

API = "http://omdbapi.com/"

module.exports = (robot) ->
  robot.respond /(imdb|movie) (.*)/i, (msg) ->
    query = msg.match[2]
    msg.http(API)
      .query({s: query})
      .get() (err, res, body) ->
        results = JSON.parse(body)["Search"]
        if results
          imdbID = results[0]["imdbID"]
          msg.http(API)
            .query({i: imdbID})
            .get() (err, res, body) ->
              movie = JSON.parse(body)
              msg.send "#{movie.Title} (#{movie.Year}): #{movie.Plot}"
        else
          msg.send "Couldn't find anything matching that."

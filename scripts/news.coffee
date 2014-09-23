# Description:
#   Returns the latest news headlines from Google, Reddit, and HN
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   news <google/reddit/hn> - Get the latest headlines from a site
#
# Author:
#   pR0Ps

NUM = 5
  
getDomain = (url) ->
  url = url.replace(/https?:\/\/(?:www\.)?([^/]+).*/, "($1)")
  return url

formatTitle = (title) ->
  title = title.replace(/&#39;/g, "'").replace(/`/g, "'").replace(/&quot;/g, "\"")
  return title

makeLine = (story) ->
  return formatTitle(story.title) + " " + getDomain(story.url)

module.exports = (robot) ->
  robot.respond /news ?(.*)/i, (msg) ->
    source = msg.match[1] or "hn"
    query msg, source, (err, name, results) ->
      return msg.send err if err

      msg.send "Latest news headlines from #{name}:\n-" +
                (results.map (story) ->
                  return makeLine(story)).slice(0, NUM).join('\n-')

  query = (msg, source, cb) ->
    lower = source.toLowerCase()
    if lower == "google"
      msg.http("https://ajax.googleapis.com/ajax/services/search/news?v=1.0&topic=h&rsz=#{NUM}")
        .get() (err, res, body) ->
          try
            response = JSON.parse body
            cb(err, "Google", response.responseData.results.map (story) ->
              return {title: story.titleNoFormatting, url: story.unescapedUrl})
          catch err
            cb(err, "Google")
    else if lower == "reddit"
      msg.http("https://www.reddit.com/r/worldnews/hot.json")
        .get() (err, res, body) ->
          try
            response = JSON.parse body
            cb(err, "Reddit", response.data.children.map (story) ->
              return {title: story.data.title, url: story.data.url})
          catch err
            cb(err)
    else if lower == "hn"
      msg.http("http://api.ihackernews.com/page")
        .get() (err, res, body) ->
          try
            response = JSON.parse body
            cb(err, "HackerNews", response.items.map (story) ->
              return {title: story.title, url: story.url})
          catch err
            cb(err, "HackerNews")
    else
      cb("Error: News source #{source} is unknown to me.", source, null)

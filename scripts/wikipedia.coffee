# Description:
#   None
#
# Dependencies:
#   "htmlparser": "1.7.6"
#   "soupselect": "0.2.0"
#   "underscore": "1.3.3"
#   "underscore.string": "2.3.0"
#
# Configuration:
#   None
#
# Commands:
#   wiki <query> - Searches for <query> on Wikipedia.
#
# Author:
#   h3h

_          = require("underscore")
_s         = require("underscore.string")
Select     = require("soupselect").select
HTMLParser = require "htmlparser"

module.exports = (robot) ->
  robot.respond /(wiki) (.+)/i, (msg) ->
    wikiMe robot, msg.match[2], (text, url) ->
      msg.send text

wikiMe = (robot, query, cb) ->
  articleURL = makeArticleURL(makeTitleFromQuery(query))

  robot.http(articleURL)
    .header('User-Agent', 'Hubot Wikipedia Script')
    .get() (err, res, body) ->
      return cb "Sorry, couldn't access Wikipedia" if err

      if res.statusCode is 301
        return cb res.headers.location

      if /does not have an article/.test body
        return cb "No page for '#{query}' found on Wikipedia"

      paragraphs = parseHTML(body, "p")

      bodyText = findBestParagraph(paragraphs) or "No paragraphs found, probably a disambiguation page. Try a more specific query."
      cb bodyText

# Utility Methods

childrenOfType = (root, nodeType) ->
  return [root] if root?.type is nodeType

  if root?.children?.length > 0
    return (childrenOfType(child, nodeType) for child in root.children)

  []

findBestParagraph = (paragraphs) ->
  return null if paragraphs.length is 0

  childs = _.flatten childrenOfType(paragraphs[0], 'text')

  # Gross hack to get around parsing weirdness
  text = (textNode.data for textNode in childs).join '_'
  text = text.replace(/(\w)_(\w)/ig, '$1 $2')
  text = text.replace(/_/g, '')

  # remove parentheticals (even nested ones)
  text = text.replace(/\s*\([^()]*?\)/g, '').replace(/\s*\([^()]*?\)/g, '')
  text = text.replace(/\s{2,}/g, ' ')               # squash whitespace
  text = text.replace(/\[[\d\s]+\]/g, '')           # remove citations
  text = _s.unescapeHTML(text)                      # get rid of nasties

  # if non-letters are the majority in the paragraph, skip it
  if text.replace(/[^a-zA-Z]/g, '').length < 35
    findBestParagraph(paragraphs.slice(1))
  else
    text

makeArticleURL = (title) ->
  "https://en.wikipedia.org/wiki/#{encodeURIComponent(title)}"

makeTitleFromQuery = (query) ->
  strCapitalize(_s.trim(query).replace(/[ ]/g, '_'))

parseHTML = (html, selector) ->
  handler = new HTMLParser.DefaultHandler((() ->),
    ignoreWhitespace: true
  )
  parser  = new HTMLParser.Parser handler
  parser.parseComplete html

  Select handler.dom, selector

strCapitalize = (str) ->
  return str.charAt(0).toUpperCase() + str.substring(1);

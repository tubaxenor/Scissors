express = require 'express'
socketio = require 'socket.io'
http = require 'http'
model = require './model.coffee'
child_process = 'child_process'
fs = require 'fs'
ghm = require 'github-flavored-markdown'
browser = require 'zombie'
app = express()
cheerio = require 'cheerio'
app.configure ->
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.set 'view engine', 'jade'
    app.set 'views', __dirname + '/views'
    app.set 'view options', { layout: false }
    app.use app.router
    app.use express.static __dirname + '/public'
    return


readme = fs.readFileSync "./README.md", "utf8"
app.locals { md : (text) -> ghm.parse text }

io = socketio.listen http.createServer(app), { 'log level': 1 }

io.sockets.on 'connection', (socket) ->
  socket
    .on 'load', (path) ->
      model.load path
      return
    .on 'success', (file) ->
      socket.emit 'file', { path: path, error: null, file: file }
      return
    .on 'error', (err) ->
      socket.emit 'file', { path: path, error: err, file: null }
      return
  return

app.get '/', (req, res) -> res.render 'index', {"readme": readme}

app.get '/new', (req, res) -> res.render 'new'

app.get '/res', (req, res) ->
  file = req.param "domain"
  res.render 'tmp/'+file+"_cut.jade"

app.get '/phan', (req, res) ->
  url = req.param "url"
  servername = url.split(/\/+/g)[0]+"//"+url.split(/\/+/g)[1]
  console.log "processing..."
  browser.visit url, (e, browser)->
    console.log "open url..."
    $ = cheerio.load browser.html()
    $("head link").each ->
      $(this).attr "href", servername+$(this).attr('href') unless $(this).attr('href').indexOf("http") == 0
    $("a").each (i, el) ->
      $(this).attr "href", ""
    $("head script").each (i, el) ->
      $(this).attr "src", servername+$(this).attr('src') unless $(this).attr('src').indexOf("http") == 0
    $("img").each (i, el) ->
      $(this).attr "src", servername+$(this).attr('src') unless $(this).attr('src').indexOf("http") == 0
    $("script").html "" if $("script").text().indexOf("//<![CDATA[")
    console.log $.html()
    console.log "writing file..."
    fs.writeFileSync "./views/tmp/"+url.split(/\/+/g)[1]+"_cut.jade", $.html(), "utf8"
    res.send url.split(/\/+/g)[1]

app.listen "3030"
console.log "running scissors on port 3030!"

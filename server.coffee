express = require 'express'
sockeio = require 'socket.io'
cons = require 'consolidate'
http = require 'http'
model = require './model.coffee'
child_process = 'child_process'
fs = require 'fs'
stylus = require 'stylus'
ghm = require 'github-flavored-markdown'
phantom = require 'phantom'
app = express()
jsdom = require 'jsdom'
html2jade = require 'html2jade'
app.configure ->
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.set 'view engine', 'jade'
    app.set 'views', __dirname + '/views'
    app.set 'view options', { layout: false }
    app.use stylus.middleware { src: __dirname + '/public' }
    app.use app.router
    app.use express.static __dirname + '/public'
    return


readme = fs.readFileSync "./README.md", "utf8"
app.locals { md : (text) -> ghm.parse text }

io = sockeio.listen http.createServer(app), { 'log level': 1 }

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

  phantom.create (ph) ->
    ph.createPage (page) ->
      page.open url, (status) ->
        console.log "opened site? ", status
        page.injectJs 'http://code.jquery.com/jquery.min.js', ->
          setTimeout ->
            page.evaluate ->
              $("html").html()
            ,(result) ->
              jsdom.env result, ['http://code.jquery.com/jquery.min.js', '/js/blockui.js'], (err, window) ->
                $ = window.$
                $("head link").each ->
                  $(this).attr "href", servername+$(this).attr('href') unless $(this).attr('href').indexOf("http") == 0
                  return
                $("a").each ->
                  $(this).attr "href", ""
                  return
                $("head script").each ->
                  $(this).attr "src", servername+$(this).attr('src') unless $(this).attr('src').indexOf("http") == 0
                  return
                $("img").each ->
                  $(this).attr "src", servername+$(this).attr('src') unless $(this).attr('src').indexOf("http") == 0
                  return
                $("script").html "" if $("script").text().indexOf("//<![CDATA[")
                html2jade.convertHtml $("html").html(), {}, (err, jade) ->
                  fs.writeFileSync "./views/tmp/"+url.split(/\/+/g)[1]+"_cut.jade", jade, "utf8"
                  return

                res.send url.split(/\/+/g)[1]
                ph.exit()
              return
            return
          ,5000
          return
        return

app.listen "3030"
console.log "running scissors on port 3030!"

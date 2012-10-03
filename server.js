var express = require('express'),
    sockeio = require('socket.io'),
    cons = require('consolidate'),
    http = require('http'),
    model = require('./model.js')
    child_process = require('child_process'),
    fs = require('fs'),
    stylus = require('stylus'),
    ghm = require("github-flavored-markdown"),
    phantom = require('phantom'),
    app = express();

app.configure(function(){
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.set('view engine', 'jade');
  app.set('views', __dirname + '/views');
  app.set('view options', { layout: false });
  app.use(stylus.middleware({
    src: __dirname + '/public',
  }));
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});


readme = fs.readFileSync("./README.md", "utf8");
app.locals({ md : function(text){
  return ghm.parse(text);
}});

app.locals({ md : function(text){
  return ghm.parse(text);
}});

var io = sockeio.listen(http.createServer(app), { 'log level': 1 });
io.sockets.on('connection', function(socket) {
  socket.on('load', function(path) {
    model.load(path)
    .on('success', function(file) {
      socket.emit('file', { path: path, error: null, file: file })
    })
    .on('error', function(err) {
      socket.emit('file', { path: path, error: err, file: null })
    })
  })
});
app.get('/', function(req, res){ res.render('index', {"readme": readme}) });

app.get('/new', function(req, res){
  res.render('new');
});

app.get('/phan', function(req, res){
  url = req.param("url")
  phantom.create(function(ph) {
    return ph.createPage(function(page){
      return page.open(url, function(status){
        console.log("opened site? ", status);
          page.injectJs('http://code.jquery.com/jquery.min.js', function() {
            setTimeout(function() {
              return page.evaluate(function() {
                  $(function(){
                    return $("html").html();
                  })
              }, function(result) {
                  res.send(result);
                  ph.exit();
              });
          }, 5000);
        })
      })
    })
  })
})


app.listen("3030");
console.log("running scissors on port 3030!");

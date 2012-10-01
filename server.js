var express = require('express');
var sockeio = require('socket.io'),
    cons = require('consolidate'),
    http = require("http"),
    child_process = require('child_process'),
    app = express(),
    bootstrap = require('bootstrap-stylus'),
       stylus = require('stylus');

function compile(str, path) {
  return stylus(str)
    .set('filename', path)
    .use(bootstrap());
}

app.configure(function(){
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.set('view engine', 'jade');
  app.set('views', __dirname + '/views');
  app.set('view options', { layout: false });
  app.use(stylus.middleware({
    src: __dirname + '/public',
    compile: compile
  }));
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});


app.get('/', function(req, res){ res.render('index') });


//var io = sockeio.listen(http.createServer(app), { 'log level': 1 })

app.listen("3030");
console.log("running scissors on port 3030!");

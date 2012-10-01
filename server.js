var express = require('express');
var sockeio = require('socket.io'),
    cons = require('consolidate'),
    http = require("http"),
    child_process = require('child_process'),
    app = express();

app.engine('haml', cons.haml);
app.set('view engine', 'haml');
app.set('views', __dirname + '/views');

app.get('/', function(req, res){
  res.render('index');
});


var io = sockeio.listen(http.createServer(app), { 'log level': 1 })

http.createServer(app).listen("3030");
console.log("running scissors on port 3030!");

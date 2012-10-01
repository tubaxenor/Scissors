var restify = require('restify');
var server = restify.createServer();
var mongoose = require('mongoose');
var db = mongoose.connect("127.0.0.1", "scissors", 12356);
var Schema = mongoose.Schema;

var Pages = new Schema({
  name: String,
  title: String,
  date: Date,
  content: String
})

mongoose.model('Page', Pages);
var Page = mongoose.model('Page');


//routing
function getPages(req, res, next){
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "X-Requested-With");
  Page.find().sort('date', -1).execFind(function (arr,data) {
    res.send(data);
  });
}

function postPage(req, res, next){
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "X-Requested-With");

  var page = new Page();
  page.name = req.params.name;
  page.date = new Date();
  page.title = req.params.title;
  page.content = req.params.content;
  page.save(function(){
    res.send(req.body);
  });

}

server.get('/pages', getPageges);
server.post('/pages', postPagege);

server.use(restify.bodyParser());
server.listen(8080, function() {
  console.log('%s listening at %s', server.name, server.url);
});

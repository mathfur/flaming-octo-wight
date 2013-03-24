
/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes')
  , http = require('http')
  , path = require('path')
  , scraper = require('scraper')
  , fs = require('fs')
  , _und = require('./lib/underscore');

var app = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'ejs');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser('your secret here'));
  app.use(express.session());
  app.use(app.router);
  app.use(express.static(path.join(__dirname, 'public')));
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

app.get('/words', function(req, resp, next){
  var url = req.param('url');
  var loaded_pages = [];

  fs.readFile('data/dictionary.txt', 'utf8', function(err, data){
    var dictionary_lines = data.split("\n");

    scraper(url, function(err, $){
      if (err) {throw err;}
      var words = $('html body').text().split(/\s+/)
      var words_ = _und.filter(_und.uniq(words.sort()), function(s){ return s.match(/^[a-z]+$/) });
      var send_lines = _und.map(words_, function(word){
        return _und.find(dictionary_lines, function(line){ return line.match("^"+word+" ") })
      })

      resp.send(_und.compact(send_lines).join("\n"));
    })
  })
});

app.get('/', routes.index);

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});

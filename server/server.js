const express = require('express')
const app = express()
var path = require('path');
var bodyParser = require('body-parser');


var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/testris');


var Piece = require('./models/piece');

app.use(bodyParser.urlencoded({extended : true}));
app.use(bodyParser.json());

var port = process.env.PORT || 8080;

//ROUTES
var router = express.Router();


router.use(function(req, res, next){
  console.log('Something is happening.');
  next();

});


app.get('/', function (req, res){
    res.sendFile(path.join(__dirname + '/index.html'));
});

router.route('/pieces')
    .post(function(req, res){

        var piece          = new Piece();
        piece.room_id      = req.body.room_id;
        piece.submitted_by = req.body.submitted_by;
        piece.quote        = req.body.quote;
        piece.piece_array = req.body.piece_array;
        console.log("piece_array: " + req.body.piece_array);
        console.log("quote: " + req.body.quote);

        piece.save(function(err){
            if (err){
                res.send("No");
            }
            else{
                res.json({message : 'succes'});
            }
        });

    })
    .get(function(req, res){
        Piece.find(function(err, pieces){
            if(err){
                res.send(err);
            }
            else{
                res.json(pieces);
            }
        });
    });



router.route('/pieces/:room_id')
  .get(function(req, res){
      Piece.find({room_id: req.params.room_id}, function(err,  pieces){
          if(err){
              res.send(err);
          }
          else{
              res.json(pieces);
          }
      });
  })

app.use('/api', router);

app.listen(port, function () {
  console.log('Listening on Port ' + port)
})

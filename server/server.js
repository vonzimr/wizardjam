const express = require('express')
const app = express()
var path = require('path');
var bodyParser = require('body-parser');


var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/testris');


var Room = require('./models/room');

app.use(bodyParser.urlencoded({extended : true}));
app.use(bodyParser.json());

app.use(express.static('assets'))
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

//Create a new Room
router.route('/room/create')
    .post(function(req, res){
        var room = new Room();

        room.save(function(err){
            if(err){
                res.status(400)
                res.send("Not Valid");
            } else{
                res.location('/api/room/id/' + room.room_id);
                res.status(201);
                res.send();
            }

        })
    });

router.route('/room/id/:room_id')
    .post(function(req, res){

        Room.update({room_id: req.params.room_id}, 
            {$push: 
                {"submissions": 
                    {
                        submitted_by : req.body.submitted_by, 
                            quote : req.body.quote,
                            shape : req.body.shape
                    }
                }
            }, 

            function(err){
                if (err){
                    res.status(400)
                    res.send("Not valid");
                }
                else{
                    res.json({message : 'succes'});
                }
            });

    });
router.route('/room/id/:room_id/submissions/:count')
    .get(function(req, res){
        Room.aggregate([
            {$match: {room_id: req.params.room_id}},
            {$unwind: "$submissions"},
            {$limit: parseInt(req.params.count)},
            {$project: 
                {
                    _id: 1, 
                    "shape":"$submissions.shape", 
                    "submitted_by":"$submissions.submitted_by",
                    "quote":"$submissions.quote"}
            },
        ], function(err, submissions){

            if(err){
                res.status(400)
                res.json(err);
            }
            else{
                res.json(submissions);
            }
        }) 
    });

app.use('/api', router);

app.listen(port, function () {
  console.log('Listening on Port ' + port)
})

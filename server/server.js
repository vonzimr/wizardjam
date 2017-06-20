const express = require('express')
const app = express()
var path = require('path');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');

var config = require('./config');

var jwt = require('jsonwebtoken');
var token = require('rand-token');
var isValidMove = require('./middleware/validmove.js');

//Database
mongoose.connect(config.database);
var Room = require('./models/room');
app.set('secretKey', config.secretKey);

//Express
app.use(bodyParser.urlencoded({extended : false}));
app.use(bodyParser.json());

app.use(express.static('assets'))


var port = process.env.PORT || 80;

//ROUTES
var router = express.Router();

app.get('/', function (req, res){
    res.sendFile(path.join(__dirname + '/index.html'));
});


function isAuthenticated(req, res, next) {
    var token = req.body.token || req.query.token || req.headers['x-access-token'];
    
    if (token){
        // verifies secret and checks exp
        jwt.verify(token, app.get('secretKey'), function(err, decoded) {      
            if (err) {
                return res.json({ success: false, message: 'Failed to authenticate token.' });    
            } else {
                // if everything is good, save to request for use in other routes
                req.decoded = decoded;    
                next();
            }
        });
    }
    else{
        res.status(403);
        res.json({success: 0,
            message: "Not Authenticated",
        });
    }
}


//Create a new Room
router.route('/room/create')
    .post(function(req, res){
        var room = new Room();

        room.save(function(err){
            if(err){
                res.status(400)
                res.send("Not Valid");
            } else{
                var token = jwt.sign({room_id: room.room_id}, app.get('secretKey'), {
                    expiresIn: 60*60*24 // expires in 24 hours
                });
                res.location('/api/room/id/' + room.room_id);
                res.status(201);
                res.json(
                    {success: true,
                     message: "Have fun!",
                     token: token});
            }

        })
    });

router.route('/room/id/:room_id')
  .post(isValidMove, function(req, res){

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
    .delete(isAuthenticated, function(req, res){
        Room.aggregate([
            {$match: {room_id: req.params.room_id}},
            {$unwind: "$submissions"},
            {$limit: parseInt(req.params.count)},
            {$project: 
                {
                    _id: 0, 
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
                for(var i = 0; i < req.params.count; i++){
                    Room.update({room_id: req.params.room_id}, 
                        {$pop: { "submissions": -1}}, 
                        function(err, sub){
                            if(err){
                                res.status(400);
                                res.json(err);
                            }
                        })
                }
                res.status(200);
                res.json(submissions);
            }
        }) 
    });


app.use('/api', router);

app.listen(port, function () {
  console.log('Listening on Port ' + port)
})

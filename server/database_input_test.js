
axios = require('axios')
var base_url = "http://localhost:8080"

var names = ["Bob", "Jeffrey", "Mr. Man", "Cool Kid", "Rocker Fan", "Goldblum",
    "Nico", "Paul", "Robert", "Angry Kid 420", "Mr. Rad Socks", "ICP4EVR", 
    "Tetris Sux", "Insensitive Jeb", "Narco", "Rat Man", "Cave Man", "Curry Fan"]

var quotes = ["Killin' It", "Metroid Prime 4 First Look wasn't really a look",
    "I did it", "You're gonna get it", "Why am I here", "Who is the best?", "I ate chicken last week", "Swiss rolls 4 lyfe", "fuck everything"]

function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min)) + min;
}


function create_piece(){
    board = [];
    for(var i = 0; i < 16; i++){
        board.push(getRandomInt(0, 2) == 1);
    }
    return board;
}

function create_data(){
    var json = {
        submitted_by: names[getRandomInt(0, names.length)],
        quote: quotes[getRandomInt(0, quotes.length)],
        shape: create_piece()};
    return json;
}
function send_block(data, room_url){

    axios.post(base_url + room_url, data)
    .then(function (response) {
    })
    .catch(function (error) {
        console.log(error);
    });
}

function create_room_send_data(n){
    var resp = axios.post(base_url + '/api/room/create')
        .then(function (response) {
            var room_url = response['headers']['location']
            console.log("Posting data to: " + room_url);
            for(var i = 0; i < n; i++){
                send_block(create_data(), room_url);
            }
            console.log("Sent " + n + " items.");
            console.log(response['data']['token']);
        })
        .catch(function (error) {
            console.log(error);
        });
}

create_room_send_data(5);

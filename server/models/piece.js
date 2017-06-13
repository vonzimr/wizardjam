var mongoose = require('mongoose');

var pieceSchema = new mongoose.Schema({
    room_id: Number,
    submitted_by: String,
    quote: String,
    piece_array: [Number]

});

module.exports = mongoose.model('Piece', pieceSchema);


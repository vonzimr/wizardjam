var mongoose = require('mongoose');

var pieceSchema = new mongoose.Schema({
    room_id: {type: Number, required: true},
    submitted_by: {type: String, required: true},
    quote: {type: String, required: true},
    piece_array: {type: [Boolean], required: function(){return this.piece_array.length == 16}}

});


module.exports = mongoose.model('Piece', pieceSchema);


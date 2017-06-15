var mongoose = require('mongoose');
var shortid = require('shortid32');

var roomSchema = new mongoose.Schema({
    room_id: {type: String, 'default': shortid.generate, required: true},
    submissions: [
                {
                    submitted_by: {type: String, required: true},
                    quote: {type: String, required: true},
                    shape: {type: [Boolean], required: function(){return this.piece_array.length == 16}}
                }
            ]

});


module.exports = mongoose.model('Room', roomSchema);


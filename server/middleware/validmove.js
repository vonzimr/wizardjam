

function isValidMove(req, res, next) {
    if (validMove(req.body.shape)){
        next()
    }
    else{
        res.status(400);
        res.json({success: 0,
            message: "invalid Block",
        });
    }
}



function validMove(array) {
    var count = 0;
    for (var k = 0; k < 16; k++) {
        if (array[k]) {
            count++;
        }
    }

    if(count < 2){
        return false
    }
    else{
        return true
    }

}



/*
maze solver to see if a path can be found between each checked cell
*/
function path(array, checked, curr, dest) {
    var up    = [curr[0], curr[1]-1];
    var right = [curr[0]+1, curr[1]];
    var down  = [curr[0], curr[1]+1];
    var left  = [curr[0]-1, curr[1]];

    if (curr[0] < 0 || curr[0] > 3 ||curr[1] < 0 || curr[1] > 3) return false;
    if (array[curr[0]][curr[1]] == 0) return false;
    if (checked[curr[0]][curr[1]] == 1) return false;

    checked[curr[0]][curr[1]] = 1;

    if (curr[0] == dest[0] && curr[1] == dest[1]) return true;

    if (path(array, checked, up,    dest)) return true;
    if (path(array, checked, down,  dest)) return true;
    if (path(array, checked, left,  dest)) return true;
    if (path(array, checked, right, dest)) return true;

    return false;
}


module.exports = isValidMove;

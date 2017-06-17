

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

    if (count > 6) {
        console.log("Too many cells");
        return false;
    } else if (count < 2) {
        console.log("Too few cells filled");
        return false;
    }
    for (var i = 0; i < 16; i++) {
        var curr = [i%4, Math.floor(i/4)];
        if (array[curr[0]][curr[1]]) {
            for (var j = 0; j < 16; j++) {
                var dest = [j%4, Math.floor(j/4)];
                if (array[dest[0]][dest[1]]) {
                    var checked = [];
                    for (var k = 0; k < 4; k++) {
                        checked[k] = [0, 0, 0, 0];
                    }
                    if (!path(array, checked, curr, dest)) {
                        console.log("Cells not connected");
                        return false;
                    }
                }
            }
            return true;
        }
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

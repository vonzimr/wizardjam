

var grid = clickableGrid(4,4,function(el,row,col,i){
    if (el.className == "clicked") {
        el.className = ""
    } else if (el.className == "") {
        el.className = "clicked"
    }
});

document.querySelector("#grid").appendChild(grid);

function clickableGrid( rows, cols, callback ){
    var i=0;
    var grid = document.createElement('table');
    grid.className = 'grid';
    for (var r=0;r<rows;++r){
        var tr = grid.appendChild(document.createElement('tr'));
        for (var c=0;c<cols;++c){
            var cell = tr.appendChild(document.createElement('td'));
            cell.addEventListener('click',(function(el,r,c,i){
                return function(){ callback(el,r,c,i); }
            })(cell,r,c,i),false);
        }
    }
    return grid;
}

function validMove(array) {
    var count = 0;
    for (var k = 0; k < 16; k++) {
        if (array[k%4][Math.floor(k/4)] == 1) {
            count++;
        }
    }
    if (count > 6) {
        console.log("Too many cells filled");
        return false;
    }
    for (var i = 0; i < 16; i++) {
        var curr = [i%4, Math.floor(i/4)];
        if (array[curr[0]][curr[1]] == 1) {
            for (var j = 0; j < 16; j++) {
                var dest = [j%4, Math.floor(j/4)];
                if (array[dest[0]][dest[1]] == 1) {
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

function submit() {
    var array = [];
    var message = document.querySelector(".msg").value;
    var room = document.querySelector(".rm").value;
    var name = document.querySelector(".name").value;
    document.querySelector(".msg").value = "";

    var string = "Array: ";

    document.getElementById("message").innerHTML = message;
    document.getElementById("room").innerHTML = room;

    var matrix = document.querySelector(".grid");
    var twoDA = [];

    for (var i = 0; i < 4; i++) {
        var row = matrix.rows[i];
        var inner = [];
        for (var j = 0; j < 4; j++) {
            var data = row.cells[j];
            var value = 0;
            if (data.className == "clicked") {
                value = 1;
                //data.className = "";
            }
            string = string.concat(value);
            string= string.concat(", ");
            array.push(value == 1);
            inner.push(value);
        }
        twoDA.push(inner);

    }

    document.getElementById("array").innerHTML = string;

    if (validMove(twoDA)) {
        var json = {room_id: room,
                    submitted_by: name,
                    quote: message,
                    piece_array: array};


        axios.post('/api/pieces', json)
        .then(function (response) {
            console.log(response);
        })
        .catch(function (error) {
            console.log(error);
        });
        document.getElementById("move").innerHTML = "Nice move"
    } else {
        document.getElementById("move").innerHTML = "Not a valid move"
    }
}

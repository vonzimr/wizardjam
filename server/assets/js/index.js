

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

    for (var i = 0; i < 4; i++) {
        var row = matrix.rows[i];
        for (var j = 0; j < 4; j++) {
            var data = row.cells[j];
            var value = 0;
            if (data.className == "clicked") {
                value = 1;
                data.className = "";
            }
            string = string.concat(value);
            string= string.concat(", ");
            array.push(value == 1);

        }

    }
    console.log(array);
    console.log(name);
    console.log(message);
    console.log(array);
    document.getElementById("array").innerHTML = string;

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
}

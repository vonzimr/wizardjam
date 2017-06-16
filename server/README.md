# Setup

- Install [mongo](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-linux/)
- Run mongod
- Install dependencies (npm install)
- type ''node server.js'' to start the node server
- You should now be able to connect to the server from either Godot or the web interface

#API
  - Creating a Room: Send a POST request to `/room/create`. The room location
    is returned in the response Header:
    ```
    POST http://<SERVER>/api/room/create
    Content-Type: application/json

    -- response --
    201 Created
    X-Powered-By:  Express
    Location:  /api/room/id/<ROOM_ID>
    Date:  Fri, 16 Jun 2017 23:37:36 GMT
    Connection:  keep-alive
    Content-Length:  0
    ```

    - Sending block submission to room: Send a POST request to `/room/id/<ROOM_ID>` In the following JSON format:
    ```JSON
    {
        submitted_by: String,
        quote: String,
        shape: Boolean Array[16]
    }
    ```

    - Deleting most recent `n` submissions from Database: send a DELETE request to 
      `/room/id/<ROOM_ID>/submissions/<COUNT>`. Needs some sort of
      authentication mechanism client-side.






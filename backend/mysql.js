import mysql from "mysql";

function initializeConnection(config) {
    function addDisconnectHandler(connection) {
        connection.on("error", function (error) {
            if (error instanceof Error) {
                if (error.code === "PROTOCOL_CONNECTION_LOST") {
                    console.error(error.stack);
                    console.log("Lost connection. Reconnecting...");

                    initializeConnection(connection.config);
                } else if (error.fatal) {
                    throw error;
                }
            }
        });
    }

    var connection = mysql.createConnection(config);

    // Add handlers.
    addDisconnectHandler(connection);

    connection.connect();
    return connection;
}

export default initializeConnection({
    host: '172.16.220.29',
    user: 'conex',
    password: 'Ad123456',
    database: 'otrsbancas'
});

// export default initializeConnection({
//     host: 'localhost',
//     user: 'root',
//     password: '123456',
//     database: 'otrs'
// });

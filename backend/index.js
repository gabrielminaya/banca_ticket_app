'use strict';

import express from "express";
import cors from "cors";
import connection from "./mysql.js";

const app = express();
app.use(cors());
app.use(express.json());

// Constants
const PORT = 3001;
const HOST = '0.0.0.0';

app.post("/user", (req, res) => {

    try {
        const { username, password } = req.body;
        const query = `
            SELECT users.*, (
                SELECT roles.name FROM role_user
                inner join roles on roles.id = role_id
                where user_id = users.id limit 1
            ) as role_id FROM users
            where valid_id = 1 and login= '${username}' and pw='${password}';
        `;

        console.log(query);

        connection.query(query, function (error, results, fields) {
            if (error) throw error;

            return res.json({
                "ok": true,
                "error": null,
                "result": results,
            });
        });


    } catch (error) {
        return res.json({
            "ok": false,
            "error": error,
        });
    }
});

app.get("/users", (_, res) => {

    try {
        connection.query(`SELECT * FROM customer_user;`, function (error, results, fields) {
            if (error) throw error;

            return res.json({
                "ok": true,
                "error": null,
                "result": results,
            });
        });


    } catch (error) {
        return res.json({
            "ok": false,
            "error": error,
        });
    }
});

app.post("/updateMails", (req, res) => {

    const { oldEmail, newEmail } = req.body;

    try {
        const query = `UPDATE customer_user SET email = '${newEmail}' WHERE email = '${oldEmail}';`;
        console.log(query);

        connection.query(query, function (error, results, fields) {
            if (error) throw error;
        });

        return res.json({
            "ok": true,
            "error": null,
        });
    } catch (error) {
        return res.json({
            "ok": false,
            "error": error,
        });
    }
});

app.post("/updateCommentary", (req, res) => {

    const { id, name, contactOne, contactTwo } = req.body;

    try {
        let newComments = `${contactOne}/${contactTwo}/${name}`;
        let query = `UPDATE customer_user SET comments = '${newComments}' WHERE login = '${id}';`;
        console.log(query);

        connection.query(query, function (error, results, fields) {
            if (error) throw error;

            return res.json({
                "ok": true,
                "error": null,
                "result": results
            });
        });

    } catch (error) {
        return res.json({
            "ok": false,
            "error": error,
        });
    }
});

app.post("/updateLastname", (req, res) => {

    const { id, newLastname } = req.body;

    try {
        const query = `UPDATE customer_user SET last_name = '${newLastname}' WHERE login = '${id}';`;
        console.log(query)
        connection.query(query, function (error, results, fields) {
            if (error) throw error;
        });

        return res.json({
            "ok": true,
            "error": null,
        });
    } catch (error) {
        return res.json({
            "ok": false,
            "error": error,
        });
    }
});

app.listen(PORT, HOST, () => {
    console.log(`Running on http://${HOST}:${PORT}`);
});

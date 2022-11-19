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


app.post("/ticket", async (req, res) => {

    const {
        title,
        subject,
        note,
        queueId,
        customerId,
        customerUserId,
        userCreatedById,
        userResponsibleById,
        emailName,
        email
    } = req.body;

    connection.query('SET TRANSACTION ISOLATION LEVEL READ COMMITTED');
    connection.beginTransaction();

    try {
        let d = new Date();

        let datestring = d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDay() + " " +
            d.getHours() + ":" + d.getMinutes();

        let ticketId = d.getFullYear().toString() + (d.getMonth() + 1) + d.getDay() +
            d.getHours() + d.getMinutes() + d.getSeconds() + 'BOT';

        const query01 = `
            INSERT INTO otrsbancas.ticket(
                id,
                tn,
                title,
                queue_id,
                ticket_lock_id,
                ticket_answered,
                type_id,
                user_id,
                responsible_user_id,
                group_id,
                ticket_priority_id,
                ticket_state_id,
                customer_id,
                customer_user_id,
                timeout,
                until_time,
                escalation_time,
                escalation_update_time,
                escalation_response_time,
                escalation_solution_time,
                valid_id,
                archive_flag,
                create_time_unix,
                create_time,
                create_by,
                change_time,
                change_by
                ) VALUES (
                null,
                '${ticketId}',
                '${title}',
                ${queueId}, -- ID TIPO
                1,
                0,
                1,
                ${userCreatedById}, -- USER_ID
                ${userResponsibleById}, -- REPONSABLE
                1, -- GROUP_ID
                3, -- ticket_priority_id,
                4, -- ticket_state_id,
                '${customerId}', -- customer_id,
                '${customerUserId}',-- customer_user_id,
                ${Date.now() / 1000}, -- timeout,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
                ${Date.now() / 1000}, -- create_time_unix,
                '${datestring}', -- create_time,
                2, -- create_by,
                '${datestring}', -- change_time
                2 -- change_by
            );
        `;

        const query02 = `
            INSERT INTO otrsbancas.article (
                id,
                ticket_id,
                article_type_id,
                article_sender_type_id,
                a_from,
                a_reply_to,
                a_to,
                a_cc,
                a_subject,
                a_message_id,
                a_in_reply_to,
                a_references,
                a_content_type,
                a_body,
                incoming_time,
                content_path,
                valid_id,
                create_time,
                create_by,
                change_time,
                change_by
            ) VALUES (
                null,
                ?, -- ticket_id
                1,
                1,
                'HELP DESK <helpdesk@bancaskingsport.com>',
                '',
                '"${emailName}" <${email}>',
                '',
                '[Ticket#${ticketId}] ${subject}',
                '<${Date.now() / 1000}.788026.158893151.182101.2@otrs.bancaskingsport.com>',
                '',
                '',
                'text/plain; charset=utf-8',
                '${note} \n\n\nCall Service\nTel:829-581-5464/809-226-0797/Ext:223\nCell:829-451-1089\nEmail:techsupport@bancaskingsport.com',
                ${Date.now() / 1000},
                '${datestring}',
                1,
                '${datestring}',
                2,
                '${datestring}',
                2
            );
        `;


        connection.beginTransaction(function (err) {
            if (err) { throw err; }

            connection.query(query01, title, function (error, results, fields) {
                if (error) {
                    return connection.rollback(function () {
                        throw error;
                    });
                }

                connection.query(query02, results.insertId, function (error, results, fields) {
                    if (error) {
                        return connection.rollback(function () {
                            throw error;
                        });
                    }

                    connection.commit(function (err) {
                        if (err) {
                            return connection.rollback(function () {
                                throw err;
                            });
                        }

                        console.log('success!');

                        return res.json({
                            "ok": true,
                            "error": null,
                        });
                    });

                });
            });
        });

    } catch (error) {
        connection.rollback();

        return res.json({
            "ok": false,
            "error": error,
        });
    }
});

app.listen(PORT, HOST, () => {
    console.log(`Running on http://${HOST}:${PORT}`);
});

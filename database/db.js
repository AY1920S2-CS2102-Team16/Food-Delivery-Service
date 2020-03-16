const promise = require("bluebird");
const initOptions = {
    // promiseLib: promise // overriding the default (ES6 Promise);
    query(e) {
        console.log("SQL: [" + e.query + "]");
    }
};
const pgp = require("pg-promise")(initOptions);
const monitor = require("pg-monitor");
//monitor.attach(initOptions);

const cn = {
    host: "localhost",
    port: 5432,
    database: "fds",
    user: "postgres",
    password: "postgres"
};
const db = pgp(cn);

module.exports = db;

const pgp = require("pg-promise")();

const db = pgp({
    host: "localhost",
    port: 5432,
    database: "fds",
    user: "postgres",
    password: "postgres"
});

module.exports = db;

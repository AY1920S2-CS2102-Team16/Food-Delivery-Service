# Food Delivery Service
## Setup
- Set up database.

In pg terminal, execute
 ```sql
CREATE DATABASE fds
\c fds
\i database/initdb.sql
```

- Set up node.js
```
yarn install
node server.js
```
Server will start on http://localhost:8080.

## Troubleshooting
- Cannot connect to database

   * Check database connection settings in `database/db.js`
   * Check postgresSQL server status with "pg_ctl status"
     * start server with "pg_ctl start"

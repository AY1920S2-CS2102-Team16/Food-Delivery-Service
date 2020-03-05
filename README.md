# Food Delivery Service
## Setup
- Set up database. In pg terminal, execute
 ```sql
CREATE DATABASE fds
\i database/schema.sql
```

- Set up node.js
```
yarn install
node server.js
```
Server will start on http://localhost:8080.

## Troubleshooting
- Cannot connect to database

    Check database connection settings in `database/db.js`

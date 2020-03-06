const express = require("express");
const app = express();
const path = require("path");
const bodyParser = require("body-parser");
const session = require("express-session");
const passport = require("passport");

const indexRouter = require("./routes/index");

app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

app.use(express.static(__dirname + "/public"));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));
app.use(session({secret: "cats"}));
app.use(passport.initialize());
app.use(passport.session());

app.use("/", indexRouter);


app.listen(8080, () => {
    console.log("Start listening on http://localhost:8080");
});

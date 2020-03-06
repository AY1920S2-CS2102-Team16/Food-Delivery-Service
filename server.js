const express = require("express");
const app = express();
const path = require("path");
const bodyParser = require("body-parser");
const session = require("express-session");
const passport = require("passport");

const indexRouter = require("./routes/index");
const customerRouter = require("./routes/customer/customer-index");
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

app.use(express.static(__dirname + "/public"));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));
app.use(session({secret: "cats"}));
app.use(passport.initialize());
app.use(passport.session());

function ensureAuthenticated(req, res, next) {
    if (req.isAuthenticated()) {
        return next();
    }
    res.redirect("/");
}

app.all("*", function (req, res, next) {
    if (req.path === "/")
        next();
    else
        ensureAuthenticated(req, res, next);
});

app.use("/", indexRouter);
app.use("/customer", customerRouter);

app.listen(8080, () => {
    console.log("Start listening on http://localhost:8080");
});

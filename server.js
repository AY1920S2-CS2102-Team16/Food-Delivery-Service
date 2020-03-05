const express = require("express");
const app = express();
const path = require("path");
const bodyParser = require("body-parser");

const indexRouter = require("./routes/index");

app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

app.use(express.static(__dirname + "/public"));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

app.use("/", indexRouter);


app.listen(8080);
console.log("Start on 8080");

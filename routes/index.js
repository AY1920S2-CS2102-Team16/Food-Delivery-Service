var express = require("express");
var router = express.Router();

app.get("/", function (req, res) {
    res.render("pages/index");
});

module.exports = router;

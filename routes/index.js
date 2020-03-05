var express = require("express");
var router = express.Router();
var db = require("../database/db");
router.get("/", function (req, res) {
    res.render("pages/index");
});

router.post("/", async function (req, res) {
    const role = req.body.role + "s";
    const id = req.body.userId;
    const pwd = req.body.password;

    let user;
    try {
        user = await db.one("select 1 from users u join " + role + " v on u.uid = v.id where u.uid = $1 and password = $2", [id, pwd]);
        console.log(user);
        res.send("Success");
    } catch (e) {
        res.send("Wrong user id/password");
    }

});

module.exports = router;

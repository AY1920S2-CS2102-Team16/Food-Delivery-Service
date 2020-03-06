const express = require("express");
const router = express.Router();
const passport = require("../database/passport");

router.get("/", function (req, res) {
    res.render("pages/index", {isError: false});
});

router.post("/",
    function (req, res, next) {
        passport.authenticate("local", function (err, user, info) {
            if (err) {
                console.log(err);
                return res.render("pages/index", {isError: true});
            }
            if (!user) {
                return res.render("pages/index", {isError: true});
            }
            req.logIn(user, function (err) {
                if (err) {
                    return res.render("pages/index", {isError: true});
                }
                return res.send(user);
            });
        })(req, res, next);
    });

module.exports = router;

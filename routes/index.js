const express = require("express");
const router = express.Router();
const passport = require("../database/passport");

router.get("/", function (req, res) {
    if (req.user) {
        return res.redirect("/" + req.user.role);
    }
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
                return res.redirect("/customer");
            });
        })(req, res, next);
    });

module.exports = router;

const express = require("express");
const router = express.Router();
const db = require("../../database/db");

router.get("/customer", function (req, res) {
    if (req.user) {
        return res.redirect("/login");
    }
    res.render("pages/signup/customer-signup",
        {
            successFlash: req.flash("success"),
            errorFlash: req.flash("error")
        }
    );
});

router.post("/customer", function (req, res) {
    db.tx(t => {
        const q1 = db.none("INSERT INTO Users (uid, password, username) VALUES ($1, $2, $3)", [req.body.userId, req.body.password, req.body.userName]);
        const q2 = db.none("INSERT INTO Customers (id) VALUES ($1)", [req.body.userId]);
        return t.batch([q1, q2]);
    })
        .then(data => {
            req.flash("success", "Sign up success.");
        })
        .catch(e => {
            req.flash("error", "Sign up failed.");
        }).finally(() => {
            res.redirect("/signup/customer");
        }
    );
});

module.exports = router;

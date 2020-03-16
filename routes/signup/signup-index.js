const express = require("express");
const router = express.Router();
const db = require("../../database/db");
const pgp = require("pg-promise")();

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

router.post("/customer", async function (req, res) {
    try {
        await db.any("begin; INSERT INTO Users (id, password, username) VALUES ($1, $2, $3); INSERT INTO Customers (id) VALUES ($1); commit;",
            [req.body.userId, req.body.password, req.body.userName, req.body.userId]);
        req.flash("success", "Sign up success.");
    } catch (e) {
        console.log(e);
        req.flash("error", "Sign up failed.");
    } finally {
        res.redirect("/signup/customer");
    }
});

module.exports = router;

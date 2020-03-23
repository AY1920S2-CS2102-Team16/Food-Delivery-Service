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

router.get("/restaurant", function (req, res) {
    if (req.user) {
        return res.redirect("/login");
    }
    res.render("pages/signup/restaurant-signup",
        {
            successFlash: req.flash("success"),
            errorFlash: req.flash("error")
        }
    );
});

router.get("/rider", function (req, res) {
    if (req.user) {
        return res.redirect("/login");
    }
    res.render("pages/signup/rider-signup",
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

router.post("/restaurant", async function (req, res) {
    try {
        await db.any("begin; " +
            "INSERT INTO Users (id, password, username) VALUES ($1, $2, $3); " +
            "INSERT INTO Restaurants (id, rname, description, address, lon, lat) VALUES ($1, $3, $5, $6, $7, $8);" +
            "commit;",
            [req.body.userId, req.body.password, req.body.userName, req.body.userId, req.body.description,
                req.body.address, req.body.lon, req.body.lat,]);
        req.flash("success", "Sign up success.");
    } catch (e) {
        console.log(e);
        req.flash("error", "Sign up failed.");
    } finally {
        res.redirect("/signup/restaurant");
    }
});

router.post("/rider", async function (req, res) {
    try {
        await db.any("begin; " +
            "INSERT INTO Users (id, password, username) VALUES ($1, $2, $3); " +
            "INSERT INTO Riders (id, type) VALUES ($1, $4); " +
            "commit;",
            [req.body.userId, req.body.password, req.body.userName, req.body.riderType]);
        req.flash("success", "Sign up success.");
    } catch (e) {
        console.log(e);
        req.flash("error", "Sign up failed.");
    } finally {
        res.redirect("/signup/rider");
    }
});

module.exports = router;

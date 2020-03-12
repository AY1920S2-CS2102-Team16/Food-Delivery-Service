const express = require("express");
const router = express.Router();
const passport = require("../../database/passport");
const db = require("../../database/db");

const sidebarItems = [
    {name: "Restaurants", link: "/customer/restaurants"},
    {name: "Cart", link: "#"},
];

router.all("*", function (req, res, next) {
    if (!req.user || req.user.role !== "customer") {
        return res.redirect("/");
    } else {
        next();
    }
});

router.get("/", function (req, res) {
    res.render("pages/customer/customer-index", {sidebarItems: sidebarItems, user: req.user, navbarTitle: "Welcome"});
});

router.get("/restaurants", async function (req, res) {
    let restaurants = await db.any("select * from Restaurants");
    console.log(restaurants);
    res.render("pages/customer/customer-restaurant-list", {
        sidebarItems: sidebarItems,
        navbarTitle: "Restaurants",
        user: req.user,
        restaurants: restaurants,
        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

module.exports = router;

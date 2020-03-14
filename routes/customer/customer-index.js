const express = require("express");
const router = express.Router();
const passport = require("../../database/passport");
const db = require("../../database/db");

const sidebarItems = [
    {name: "Restaurants", link: "/customer/restaurants", icon: "utensils"},
    {name: "Cart", link: "#", icon: "utensils"},
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

/*
 * Restaurant list page.
 */
router.get("/restaurants", async function (req, res) {
    let restaurants = await db.any("select * from Restaurants");
    res.render("pages/customer/customer-restaurant-list", {
        sidebarItems: sidebarItems,
        navbarTitle: "Restaurants",
        user: req.user,
        restaurants: restaurants,
    });
});

/*
 * Individual restaurant display page.
 */
router.get("/restaurants/:rid", async function (req, res) {
    let foods, restaurant;
    try {
        const getFoods = db.any("select * from Sells where rid = $1", [req.params.rid]);
        const getRestaurant = db.one("select * from Restaurants join Users on Restaurants.id = Users.uid where Users.uid = $1", [req.params.rid]);
        [foods, restaurant] = await Promise.all([getFoods, getRestaurant]);
    } catch (e) {
        //TODO: Add error notification bar on restaurant list page.
        req.flash("error", "An error has occurred.");
        res.redirect("/customer/restaurants/");
    }

    res.render("pages/customer/customer-restaurant-page", {
        sidebarItems: sidebarItems,
        navbarTitle: "Restaurants",
        user: req.user,
        foods: foods,
        restaurant: restaurant,
        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

router.get("/settings", function (req, res) {
    res.render("pages/customer/customer-settings", {
        sidebarItems: sidebarItems,
        user: req.user,
        navbarTitle: "Welcome"
    });
});

module.exports = router;

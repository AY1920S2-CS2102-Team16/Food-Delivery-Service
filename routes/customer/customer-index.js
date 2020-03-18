const express = require("express");
const router = express.Router();
const passport = require("../../database/passport");
const db = require("../../database/db");

const sidebarItems = [
    {name: "Restaurants", link: "/customer/restaurants", icon: "utensils"},
    {name: "Orders", link: "/customer/orders", icon: "shopping-cart"},
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
    let foods, restaurant, locations, card;
    try {
        const getFoods = db.any("select * from Sells where rid = $1", [req.params.rid]);
        const getRestaurant = db.one("select * from Restaurants join Users on Restaurants.id = Users.id where Users.id = $1", [req.params.rid]);
        const getCustomerLocations = db.any("select * from CustomerLocations where cid = $1 order by last_used_time desc", [req.user.id]);
        const getCard = db.any("select * from CustomerCards where cid = $1", [req.user.id]);
        [foods, restaurant, locations, card] = await Promise.all([getFoods, getRestaurant, getCustomerLocations, getCard]);
    } catch (e) {
        console.log(e);
        //TODO: Add error notification bar on restaurant list page.
        req.flash("error", "An error has occurred.");
        return res.redirect("/customer/restaurants/");
    }

    //Card is registered
    let cardLastFourDigits = "";
    if (card.length === 1) {
        cardLastFourDigits = card[0].number.slice(-4);
    }
    res.render("pages/customer/customer-restaurant-page", {
        sidebarItems: sidebarItems,
        navbarTitle: "Restaurants",
        user: req.user,
        foods: foods,
        restaurant: restaurant,
        locations: locations,
        cardLastFourDigits: cardLastFourDigits,

        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

router.get("/settings", async function (req, res) {
    let customerLocations;
    try {
        customerLocations = await db.any("select * from CustomerLocations where cid = $1 order by last_used_time desc", [req.user.id]);
    } catch (e) {
        req.flash("error", "An error has occurred.");
        return res.redirect("/customer/settings");
    }
    res.render("pages/customer/customer-settings", {
        sidebarItems: sidebarItems,
        user: req.user,
        navbarTitle: "Settings",
        locations: customerLocations,

        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

router.post("/settings/add-location", async function (req, res) {
    try {
        await db.none("insert into CustomerLocations (cid, lat, lon, address) values ($1, $2, $3, $4)",
            [req.user.id, req.body.lat, req.body.lon, req.body.address]);
    } catch (e) {
        console.log(e);
        req.flash("error", "An error has occurred.");
        return res.redirect("/customer/settings");
    }
    req.flash("success", "Location is added.");
    return res.redirect("/customer/settings");
});

router.post("/settings/add-card", async function (req, res) {
    try {
        await db.none("insert into CustomerCards (cid, number, expiry, name, cvv) values ($1, $2, $3, $4, $5) " +
            "on conflict (cid) do update set number = $2, expiry = $3, name = $4, cvv = $5",
            [req.user.id, req.body.number, req.body.expiry, req.body.name, req.body.cvv]);
    } catch (e) {
        console.log(e);
        req.flash("error", "An error has occurred.");
        return res.redirect("/customer/settings");
    }
    req.flash("success", "Card is added/Updated");
    return res.redirect("/customer/settings");
});

router.post("/checkout", async function (req, res) {
    const addOrderFood = function (name, quantity) {
        db.none;
    };
    let order = {
        location: {
            lat: null, lon: null
        },
        foods: []
    };
    order.location.lat = req.body.location.split(" ")[0];
    order.location.lon = req.body.location.split(" ")[1];
    for (let [key, value] of Object.entries(req.body)) {
        if (key !== "location" && value > 0) {
            order.foods.push({
                name: key,
                quantity: parseInt(value, 10),
                // price:
                // total:
            });
        }
    }
    //Food name,

    return res.render("pages/customer/customer-checkout", {
        sidebarItems: sidebarItems,
        user: req.user,
        navbarTitle: "Checkout",
        order: order,

        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

router.get("/orders", function (req, res) {
    res.render("pages/customer/customer-orders", {sidebarItems: sidebarItems, user: req.user, navbarTitle: "Orders"});
});

module.exports = router;

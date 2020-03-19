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

        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
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
    //First, convert post order request into order object.
    let order = {
        rid: req.body.rid,
        location: {
            lat: req.body.location.split(" ")[0],
            lon: req.body.location.split(" ")[1]
        },
        foods: [],
        payment: req.body.payment
    };

    for (let [key, value] of Object.entries(req.body)) {
        if (key !== "location" && value > 0) {
            order.foods.push({
                name: key,
                quantity: parseInt(value, 10),
            });
        }
    }

    if (order.foods.length === 0) {
        req.flash("error", "Please select some products.");
        return res.redirect("/customer/restaurants/" + order.rid);
    }

    //Then, execute SQL transaction.
    db.tx(function (t) {
        let operations = [];
        operations.push(t.none("insert into Orders(cid, lon, lat, payment_mode) values ($1, $2, $3, $4)",
            [req.user.id,
                req.body.location.split(" ")[0],
                req.body.location.split(" ")[1],
                req.body.payment]));
        order.foods.forEach(food => {
            operations.push(t.none("insert into OrderFoods(rid, oid, food_name, quantity) values ($1, currval('orders_id_seq'), $2, $3)",
                [order.rid, food.name, food.quantity]));
        });
        t.batch(operations);
    }).then(data => {
        req.flash("success", "Order placed successfully");
        return res.redirect("/customer/orders");
    }).catch(e => {
        req.flash("error", "Failed to place order.");
        return res.redirect("/customer/restaurants/" + order.rid);
    })
});

router.get("/orders", async function (req, res) {
    let orders = [];
    orders = await db.any("select *, (delivery_cost + food_cost) as total from Orders where cid = $1", req.user.id);
    console.log(orders.length);
    for (let i = 0; i < orders.length; i++) {
        const data = await db.any("select * from OrderFoods where oid = $1", orders[i].id);
        orders[i]["allFoods"] = data;
        orders[i]["rname"] = await db.one("select rname from Restaurants where id = $1", data[0].rid);
        orders[i]["rname"] = orders[i]["rname"].rname;
    }

    res.render("pages/customer/customer-orders", {
        sidebarItems: sidebarItems,
        user: req.user,
        navbarTitle: "Orders",
        orders: orders,

        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

module.exports = router;

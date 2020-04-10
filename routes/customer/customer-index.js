const express = require("express");
const router = express.Router();
const passport = require("../../database/passport");
const db = require("../../database/db");
const getOrderStatus = require("../../utils/getOrderStatus");

const sidebarItems = [
    {name: "Home", link: "/", icon: "home"},
    {name: "Restaurants", link: "/customer/restaurants", icon: "utensils"},
    {name: "Orders", link: "/customer/orders", icon: "shopping-cart"},
    {name: "Search", link: "/customer/search", icon: "search"},
];

router.all("*", function (req, res, next) {
    if (!req.user || req.user.role !== "customer") {
        return res.redirect("/");
    } else {
        next();
    }
});

router.get("/", async function (req, res) {
    let favorite_rest, random_rest, points;
    try {
        favorite_rest = await db.any(
            "select r.id, rname, description, count(*) as num " +
            "from orders join restaurants r on orders.rid = r.id " +
            "where cid = $1 " +
            "group by r.id, rname, description " +
            "order by num desc " +
            "limit 5 ", [req.user.id]);

        random_rest = await db.any(
            "select * from restaurants order by random() limit 5");

    } catch (e) {
        console.log(e);
    }

    console.log(favorite_rest);

    res.render("pages/customer/customer-index", {
        sidebarItems: sidebarItems,
        user: req.user,
        navbarTitle: "Welcome",
        favorite_rest: favorite_rest,
        random_rest: random_rest
    });
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
    let foods, restaurant, locations, card, reviews;
    try {
        const getFoods = db.any("select * from Sells where rid = $1", [req.params.rid]);
        const getRestaurant = db.one("select * from Restaurants join Users on Restaurants.id = Users.id where Users.id = $1", [req.params.rid]);
        const getCustomerLocations = db.any("select * from CustomerLocations where cid = $1 order by last_used_time desc", [req.user.id]);
        const getCard = db.any("select * from CustomerCards where cid = $1", [req.user.id]);
        const getReviews = db.any("select * from Reviews join Orders on Reviews.oid = Orders.id where Reviews.oid in (select id from Orders where rid = $1)", req.params.rid);

        [foods, restaurant, locations, card, reviews] = await Promise.all([getFoods, getRestaurant, getCustomerLocations, getCard, getReviews]);
    } catch (e) {
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
        reviews: reviews,
        cardLastFourDigits: cardLastFourDigits,

        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

router.get("/settings", async function (req, res) {
    let customerLocations, points;
    try {
        points = await db.any("select reward_points from Customers where id = $1", [req.user.id]);
        customerLocations = await db.any("select * from CustomerLocations where cid = $1 order by last_used_time desc", [req.user.id]);
    } catch (e) {
        console.log(e);
        req.flash("error", "An error has occurred.");
        return res.redirect("/customer/settings");
    }
    res.render("pages/customer/customer-settings", {
        sidebarItems: sidebarItems,
        user: req.user,
        navbarTitle: "Settings",

        locations: customerLocations,
        points: points,

        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

router.post("/settings/update-password", async function (req, res) {
    let role = req.user.role + "s";
    let user;
    try {
        user = await db.one("select * from users u join " + role + " v on u.id = v.id where u.id = $1 and password = crypt($2, $3)",
            [req.user.id, req.body.oldpassword, "$2a$04$1wxM7b.ub1nIISNmhDU97e"]);
        if (user)
        {
            await db.none("Update users set password = $1 where users.id = $2; commit;",
            [req.body.newpassword, req.user.id]);
        }
    } catch (e) {
        console.log(e);
        req.flash("error", "Wrong password, Please try again");
        return res.redirect("/customer/settings");
    }
    req.flash("success", "Password updated.");
    return res.redirect("/customer/settings");
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
    db.tx(t => {
        let operations = [];
        operations.push(t.none("insert into Orders(cid, lon, lat, payment_mode, rid, time_paid) values ($1, $2, $3, $4, $5, $6)",
            [
                req.user.id,
                req.body.location.split(" ")[0],
                req.body.location.split(" ")[1],
                req.body.payment,
                order.rid,
                req.body.payment === "Card" ? new Date() : null
            ]));
        order.foods.forEach(food => {
            operations.push(t.none("insert into OrderFoods(rid, oid, food_name, quantity) values ($1, currval('orders_id_seq'), $2, $3)",
                [order.rid, food.name, food.quantity]));
        });
        return t.batch(operations);
    }).then(data => {
        req.flash("success", "Order placed successfully");
        return res.redirect("/customer/orders");
    }).catch(e => {
        console.log(e);
        req.flash("error", "Failed to place order. Either minimum spending is not reached or daily limit is reached.");
        return res.redirect("/customer/restaurants/" + order.rid);
    })
});

router.get("/orders", async function (req, res) {
    let orders = [];
    orders = await db.any("select *, (delivery_cost + food_cost) as total, (select address from CustomerLocations where cid = Orders.cid and lon = Orders.lon and lat = Orders.lat) as address from Orders where cid = $1 order by Orders.time_placed desc", req.user.id);
    for (let i = 0; i < orders.length; i++) {
        const data = await db.any("select * from OrderFoods where oid = $1", orders[i].id);
        orders[i]["allFoods"] = data;
        orders[i]["rname"] = await db.one("select rname from Restaurants where id = $1", data[0].rid);
        orders[i]["rname"] = orders[i]["rname"].rname;

        [orders[i].status, orders[i].isPaid] = getOrderStatus(orders[i]);

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

router.post("/orders/addreview", async function (req, res) {
    const content = req.body.review;
    const oid = req.body.oid;
    const rating = req.body.rating;
    const cid = req.user.id;
    try {

        await db.any("insert into Reviews (content, rating, oid) values ($1, $2, $3) on conflict(oid) do update set content = $1, rating = $2 where Reviews.oid = $3",
            [content, rating, oid]);
        req.flash("success", "Create/update review success");
    } catch (e) {
        console.log(e);
        req.flash("error", "Failed to create/update review");
    } finally {
        res.redirect("/customer/orders");
    }
});

router.get("/search", async function (req, res) {
    res.render("pages/customer/customer-search", {
        sidebarItems: sidebarItems,
        user: req.user,
        navbarTitle: "Search",

        searchRes: [],
        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

router.post("/search", async function (req, res) {
    console.log(req.body);
    let searchRes;
    let min_price;
    let max_price;
    if (req.body.food_price === "0") {
        min_price = 0;
        max_price = 99999;
    } else if (req.body.food_price === "1") {
        min_price = 0;
        max_price = 20;
    } else if (req.body.food_price === "2") {
        min_price = 20;
        max_price = 40;
    } else if (req.body.food_price === "3") {
        min_price = 40;
        max_price = 60;
    } else if (req.body.food_price === "4") {
        min_price = 60;
        max_price = 80;
    }
    try {
        searchRes = await db.any(
            "select food_name, food_category, rname, S.rid\n" +
            "from Sells S join Restaurants R on S.rid = R.id\n" +
            "where food_category in ($1:csv)\n" +
            "and (select avg(S2.price::numeric) from Sells S2 where S2.rid = R.id) between $3 and $4\n" +
            "and SIMILARITY(food_name, $2) > 0.02\n" +
            "order by SIMILARITY(food_name, $2) desc;",
            [req.body.food_category, req.body.keyword, min_price, max_price]
        );
    } catch (e) {
        console.log(e);
    }
    console.log(searchRes);
    res.render("pages/customer/customer-search", {
        sidebarItems: sidebarItems,
        user: req.user,
        navbarTitle: "Search",

        searchRes: searchRes,
        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

module.exports = router;

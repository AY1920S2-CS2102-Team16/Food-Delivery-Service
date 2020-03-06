const express = require("express");
const router = express.Router();
const db = require("../../database/db");

const sidebarItems = [
    {name: "Food", link: "/restaurant/food"},
    {name: "Orders", link: "#"},
];

router.all("*", function (req, res, next) {
    if (req.user.role !== "restaurant") {
        return res.redirect("/");
    } else {
        next();
    }
});

router.get("/", function (req, res) {
    res.render("pages/restaurant/restaurant-index", {sidebarItems: sidebarItems, user: req.user});
});

router.get("/food", async function (req, res) {
    let foods = await db.any("select * from Sells where rid = $1", [req.user.uid]);
    console.log(foods);
    res.render("pages/restaurant/restaurant-food", {sidebarItems: sidebarItems, user: req.user});
});

module.exports = router;

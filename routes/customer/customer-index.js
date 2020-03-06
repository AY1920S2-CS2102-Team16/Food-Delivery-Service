const express = require("express");
const router = express.Router();
const passport = require("../../database/passport");

const sidebarItems = [
    {name: "Food", link: "#"},
    {name: "Cart", link: "#"},
];

router.all("*", function (req, res, next) {
    if (req.user.role !== "customer") {
        return res.redirect("/");
    } else {
        next();
    }
});

router.get("/", function (req, res) {
    console.log(req.user);
    res.render("pages/customer/customer-index", {sidebarItems: sidebarItems, user: req.user});
});

module.exports = router;

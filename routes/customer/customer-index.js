const express = require("express");
const router = express.Router();
const passport = require("../../database/passport");

router.get("/", function (req, res) {
    if (req.user.role !== "customer") {
        return res.redirect("/");
    }

    res.render("pages/customer/customer-index");
});

module.exports = router;

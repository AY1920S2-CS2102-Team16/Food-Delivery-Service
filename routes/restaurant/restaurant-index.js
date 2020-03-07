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
    res.render("pages/restaurant/restaurant-food", {
        sidebarItems: sidebarItems,
        navbarTitle: "Food",
        user: req.user,
        foods: foods,
        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

router.post("/food/edit", async function (req, res) {
    console.log("-----");
    console.log(req.body);
    console.log("-----");

    //new food
    if (req.body.old_food_name === "") {
        db.none("INSERT INTO Sells (rid, food_name, food_description, food_category, daily_limit, price) values ($1, $2, $3, $4, $5, $6)",
            [req.user.id, req.body.food_name, req.body.food_description, req.body.food_category, req.body.daily_limit, req.body.price])
            .then(() => {
                req.flash("success", "Creation successful.");
            })
            .catch(error => {
                req.flash("error", "Creation failed.");
                console.log("ERROR:", error);
            })
            .finally(() => {
                return res.redirect("/restaurant/food");
            });
    }

    db.none("UPDATE Sells SET food_name=$1, food_category=$2, daily_limit=$3, price=$4, food_description=$5 WHERE rid=$6 AND food_name=$7",
        [req.body.food_name, req.body.food_category, req.body.daily_limit, req.body.price, req.body.food_description,
            req.user.id, req.body.old_food_name])
        .then(() => {
            req.flash("success", "Modification successful.");
        })
        .catch(error => {
            req.flash("error", "Modification failed.");
            console.log("ERROR:", error);
        })
        .finally(() => {
            res.redirect("/restaurant/food");
        });
});

module.exports = router;

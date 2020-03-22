const express = require("express");
const router = express.Router();
const db = require("../../database/db");

const sidebarItems = [
    {name: "Food", link: "/restaurant/food", icon: "utensils"},
    {name: "Orders", link: "/restaurant/orders", icon: "shopping-cart"},
    {name: "Promotions", link: "/restaurant/promotions", icon: "shopping-cart"},
];

router.all("*", function (req, res, next) {
    if (!req.user || req.user.role !== "restaurant") {
        return res.redirect("/");
    } else {
        next();
    }
});

router.get("/", function (req, res) {
    res.render("pages/restaurant/restaurant-index", {sidebarItems: sidebarItems, user: req.user});
});

router.get("/food", async function (req, res) {
    let foods = await db.any("select * from Sells where rid = $1", [req.user.id]);
    res.render("pages/restaurant/restaurant-food", {
        sidebarItems: sidebarItems,
        navbarTitle: "Food",
        user: req.user,
        foods: foods,
        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

router.get("/food/remove/:food_name", async function (req, res) {
    try {
        db.none("DELETE FROM Sells WHERE rid = $1 AND food_name = $2", [req.user.id, req.params.food_name]);
    } catch (e) {
        req.flash("error", "Deletion failed.");
    } finally {
        res.redirect("/restaurant/food");
    }
});

router.post("/food/edit", async function (req, res) {
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


router.get("/settings", async function (req, res) {
    res.render("pages/restaurant/restaurant-settings", {
        sidebarItems: sidebarItems,
        user: req.user,
        navbarTitle: "Settings",
        //locations: customerLocations,

        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

router.post("/settings", async function (req, res) {
    try {
        if (req.body.password === "") {
            await db.any("begin; " +
                "update Users set username = $/userName/ where id = $/userId/; " +
                "update Restaurants set rname = $/userName/, description = $/description/, address = $/address/, lon = $/lon/, lat = $/lat/ where id = $/userId/;" +
                "commit;",
                {...req.body, userId: req.user.id});
        } else {
            await db.any("begin; " +
                "update Users set username = $/userName/, password = $/password/ where id = $/userId/; " +
                "update Restaurants set rname = $/userName/, description = $/description/, address = $/address/, lon = $/lon/, lat = $/lat/ where id = $/userId/;" +
                "commit;",
                {...req.body, userId: req.user.id});
        }
        req.flash("success", "Update success.");
        res.redirect("/logout");
    } catch (e) {
        console.log(e);
        req.flash("error", "Update failed.");
        res.redirect("/restaurant/settings");
    }
});

router.get("/orders", async function (req, res) {
    let orderIds = await db.any("select distinct Orders.id from Orders join OrderFoods on Orders.id = OrderFoods.oid where OrderFoods.rid = $1", req.user.id);

    let orders = [];
    for (let i = 0; i < orderIds.length; i++) {
        const orderedItems = await db.any("select * from OrderFoods where oid = $1", orderIds[i].id);
        let order = await db.any("select *, (delivery_cost + food_cost) as total from Orders where id = $1", orderIds[i].id);
        console.log(order);
        order = order[0];
        order.allFoods = orderedItems;
        orders.push(order);
    }

    res.render("pages/restaurant/restaurant-orders", {
        sidebarItems: sidebarItems,
        user: req.user,
        navbarTitle: "Orders",
        orders: orders,

        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });

});

router.get("/promotions", async function (req, res) {
    let actions, rules, promotions;
    try {
        rules = await db.any("select *, case when exists(select 1 from Managers where Managers.id = PromotionRules.giver_id) then true else false end as is_admin from PromotionRules where giver_id = $1 or exists(select 1 from Managers where Managers.id = giver_id)", req.user.id);
        actions = await db.any("select *, case when exists(select 1 from Managers where Managers.id = PromotionActions.giver_id) then true else false end as is_admin from PromotionActions where giver_id = $1 or exists(select 1 from Managers where Managers.id = giver_id)", req.user.id);
        promotions = await db.any("select *, case when exists(select 1 from Managers where Managers.id = Promotions.giver_id) then true else false end as is_admin from Promotions where giver_id = $1 or exists(select 1 from Managers where Managers.id = giver_id)", req.user.id);
    } catch (e) {
        console.log(e);
    }
    console.log(rules);
    res.render("pages/restaurant/restaurant-promotions", {
        sidebarItems: sidebarItems,
        user: req.user,
        navbarTitle: "Promotions",

        rules: rules,
        actions: actions,
        promotions: promotions,
        rtypes: ["ORDER_TOTAL", "NTH_ORDER"],
        atypes: ["FOOD_DISCOUNT", "DELIVERY_DISCOUNT"], //TODO: Avoid hardcode values

        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

router.post("/promotions/addrule", async function (req, res) {
    try {
        console.log(req.body);
        await db.none("insert into PromotionRules (giver_id, rtype, config) values ($1, $2, $3)",
            [req.user.id, req.body.rtype, req.body.config]);
        req.flash("success", "Rule added.");
    } catch (e) {
        console.log(e);
        req.flash("error", "Error when adding rule.");
    } finally {
        res.redirect("/restaurant/promotions");
    }
});

router.post("/promotions/addaction", async function (req, res) {
    try {
        await db.none("insert into PromotionActions (giver_id, atype, config) values ($1, $2, $3)",
            [req.user.id, req.body.rtype, req.body.config]);
        req.flash("success", "Action added.");
    } catch (e) {
        console.log(e);
        req.flash("error", "Error when adding action.");
    } finally {
        res.redirect("/restaurant/promotions");
    }
});

router.post("/promotions/addpromo", async function (req, res) {
    try {
        console.log(req.body);
        await db.none("insert into Promotions (promo_name, rule_id, action_id, start_time, end_time, giver_id) " +
            "values ($1, $2, $3, $4, $5, $6)",
            [req.body.desc, req.body.rule, req.body.action, req.body.start, req.body.end, req.user.id]);
        req.flash("success", "Promotion added.");
    } catch (e) {
        console.log(e);
        req.flash("error", "Error when adding promotion.");
    } finally {
        res.redirect("/restaurant/promotions");
    }
});

router.get("/promotions/remove", async function (req, res) {
    try {
        if (req.query.actionid) {
            await db.none("delete from PromotionActions where id = $1", req.query.actionid);
        } else if (req.query.ruleid) {
            await db.none("delete from PromotionRules where id = $1", req.query.ruleid);
        } else if (req.query.promoid) {
            await db.none("delete from Promotions where id = $1", req.query.promoid);
        }
    } catch (e) {
        console.log(e);
        req.flash("error", "Error when removing.");
    } finally {
        res.redirect("/restaurant/promotions");
    }
});
module.exports = router;

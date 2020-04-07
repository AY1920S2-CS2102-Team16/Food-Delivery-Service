const express = require("express");
const router = express.Router();
const db = require("../../database/db");

const sidebarItems = [
    {name: "Dashboard", link: "/", icon: "tachometer-alt"},
    {name: "Users", link: "/manager/users", icon: "users"},
    {name: "Promotions", link: "/manager/promotions", icon: "percentage"},
];

router.all("*", function (req, res, next) {
    if (!req.user || req.user.role !== "manager") {
        return res.redirect("/");
    } else {
        next();
    }
});

router.get("/", async function (req, res) {
    let stats, cus_stats;
    try {
        stats = await db.any(
            "with recursive MonthlyCalendar as (\n" +
            "    select CURRENT_TIMESTAMP as date\n" +
            "    union all\n" +
            "    select date - interval '1 month'\n" +
            "    from MonthlyCalendar\n" +
            "    where date > CURRENT_TIMESTAMP - interval '11 month'\n" +
            ")\n" +
            "select to_char(mc.date, 'YYYY-MM') as yearmonth,\n" +
            "       count(distinct c.id) as total_new_users,\n" +
            "       coalesce(sum(o.food_cost::numeric + o.delivery_cost::numeric), 0::numeric) as total_order_revenue,\n" +
            "       count(distinct o.id) as total_order_num\n" +
            "from MonthlyCalendar mc\n" +
            "    left join (Customers natural join Users) c\n" +
            "    on to_char(c.join_date, 'YYYY-MM') = to_char(mc.date, 'YYYY-MM')\n" +
            "    left join Orders o\n" +
            "    on to_char(o.time_placed, 'YYYY-MM') = to_char(mc.date, 'YYYY-MM')\n" +
            "group by to_char(mc.date, 'YYYY-MM')\n" +
            "order by yearmonth desc;\n"
        );
        cus_stats = await db.any(
            "select c.id, count(distinct o.id) as total_order_num, sum(o.food_cost + o.delivery_cost) as total_spending\n" +
            "from Customers c join Orders o on c.id = o.cid  and to_char(o.time_placed, 'YYYY-MM') = to_char(CURRENT_TIMESTAMP, 'YYYY-MM')\n" +
            "group by c.id\n"
        );
    } catch (e) {
        console.log(e);
    }
    console.log(stats);
    res.render("pages/manager/manager-index", {
        sidebarItems: sidebarItems,
        user: req.user, navbarTitle: "Welcome",
        stats: stats,
        cus_stats: cus_stats
    });
});

router.get("/users", async function (req, res) {
    let users;
    try {
        users = await db.any("select * from UserInfo");

    } catch (e) {
        console.log(e);
    }
    res.render("pages/manager/manager-users", {
        sidebarItems: sidebarItems,
        user: req.user, navbarTitle: "Users",
        users: users
    });
});

router.get("/users/remove/:id", async function (req, res) {
    let users;
    try {
        await db.none("DELETE FROM Users WHERE id = $1", [req.params.id]);
    } catch (e) {
        req.flash("error", "Deletion failed.");
    } finally {
        res.redirect("/manager/users");
    }
});

router.post("/users/add", async function (req, res) {
    let users;
    try {
        await db.any("begin; INSERT INTO Users (id, password, username) VALUES ($1, $2, $3); INSERT INTO Managers (id) VALUES ($1); commit;",
            [req.body.id, req.body.password, req.body.name, req.body.id]);
    } catch (e) {
        req.flash("error", "Deletion failed.");
    } finally {
        res.redirect("/manager/users");
    }
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
    res.render("pages/manager/manager-promotions", {
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
        await db.none("insert into PromotionRules (giver_id, rtype, config) values ($1, $2, $3)",
            [req.user.id, req.body.rtype, req.body.config]);
        req.flash("success", "Rule added.");
    } catch (e) {
        console.log(e);
        req.flash("error", "Error when adding rule.");
    } finally {
        res.redirect("/manager/promotions");
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
        res.redirect("/manager/promotions");
    }
});

router.post("/promotions/addpromo", async function (req, res) {
    try {
        await db.none("insert into Promotions (promo_name, rule_id, action_id, start_time, end_time, giver_id) " +
            "values ($1, $2, $3, $4, $5, $6)",
            [req.body.desc, req.body.rule, req.body.action, req.body.start, req.body.end, req.user.id]);
        req.flash("success", "Promotion added.");
    } catch (e) {
        console.log(e);
        req.flash("error", "Error when adding promotion.");
    } finally {
        res.redirect("/manager/promotions");
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
        res.redirect("/manager/promotions");
    }
});

router.get("/settings", async function (req, res) {
    res.render("pages/manager/manager-settings", {
        sidebarItems: sidebarItems,
        user: req.user,
        navbarTitle: "Settings",
        //locations: customerLocations,

        successFlash: req.flash("success"),
        errorFlash: req.flash("error")
    });
});

module.exports = router;

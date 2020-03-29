const express = require("express");
const router = express.Router();
const db = require("../../database/db");
const dateToUrl = require("../../utils/dateToUrl");

const sidebarItems = [
    {name: "Delivery", link: "/rider/delivery", icon: "truck"},
    {name: "Schedule", link: "/rider/schedule", icon: "calendar-alt"},
    {name: "Salary", link: "/rider/salary", icon: "money-check-alt"},
];

router.all("*", function (req, res, next) {
    if (!req.user || req.user.role !== "rider") {
        return res.redirect("/");
    } else {
        next();
    }
});

router.get("/", async function (req, res) {
    res.render("pages/rider/rider-index", {sidebarItems: sidebarItems, user: req.user, navbarTitle: ""});
});

router.get("/schedule", async function (req, res) {
    let now = new Date();
    now = dateToUrl(now);

    return res.redirect("/rider/schedule/" + now);
});

router.get("/schedule/:date_req", async function (req, res) {
    let join_date = await db.one("select join_date from Users where id = $1", req.user.id);
    console.log(join_date);
    join_date = new Date(join_date.join_date.getFullYear(), join_date.join_date.getMonth(), join_date.join_date.getDate() + 1);
    let date_req = new Date(req.params.date_req);
    console.log(date_req);

    let rider_type = await db.one("select type from Riders where id = $1", req.user.id);
    if (rider_type.type === "full_time") {
        console.log("Sorry, full_time page not developed");
        let schedules = await db.any("select * from FWS where rid = $1", req.user.id);
        res.render("pages/rider/riderFT-schedule",{
            sidebarItems: sidebarItems,
            user: req.user,
            navbarTitle: "",
            schedules: schedules,
            reference: reference,

            successFlash: req.flash("success"),
            errorFlash: req.flash("error")
        });
    } else { // part_time rider
        let day_in_week = (date_req - join_date) / (1000 * 60 * 60 * 24) % 7;
        console.log(day_in_week);
        date_req.setDate(date_req.getDate() - day_in_week);
        console.log(date_req);
        let date_req_str = dateToUrl(date_req);
        let intervals = await db.any(
            "select * from PWS where rid = $1 " +
            "and start_of_week = to_date($2, 'YYYY-MM-DD')" +
            "order by (day_of_week, start_hour)", [req.user.id, date_req_str]);

        // console.log(intervals);
        let schedules = [];
        for (var i = 0; i < 7; i++) {
            schedules.push([]);
        }

        intervals.forEach(function (interval) {
            schedules[interval.day_of_week].push([interval.start_hour, interval.end_hour - interval.start_hour]);
        });

        res.render("pages/rider/riderPT-schedule",{
            sidebarItems: sidebarItems,
            user: req.user,
            navbarTitle: "Weekly Schedule",
            start_of_week: date_req,
            schedules: schedules,

            successFlash: req.flash("success"),
            errorFlash: req.flash("error")
        });
    }
});

router.post("/schedule/changeSchedule", async function(req, res) {
    let start_of_week = new Date(req.body.start_of_week);;
    let start_of_week_str = dateToUrl(start_of_week);
    let start_hour, end_hour;
    let query = "begin;\n";
    query += "DELETE FROM PWS WHERE start_of_week = to_date('" + start_of_week_str + "', 'YYYY-MM-DD');\n";
    for (let day = 0; day < 7; day++) {
        start_hour = 10; end_hour = 10;
        for (let hour = 10; hour < 22; hour++) {
            if (req.body["d" + day + "_" + hour] === "on") {
                if (start_hour === end_hour) {
                    start_hour = hour;
                    end_hour = hour + 1;
                } else {
                    end_hour = hour + 1;
                }
            } else {
                if (start_hour === end_hour) {
                    start_hour = hour;
                    end_hour = hour;
                } else {
                    query += "INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour) " +
                        "VALUES ('" + req.user.id + "', to_date('" + start_of_week_str + "', 'YYYY-MM-DD'), " + day + ", " + start_hour + ", " + end_hour + ");\n";

                    start_hour = end_hour;
                }
            }
        }
        if (start_hour !== end_hour) {
            query += "INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour) " +
                "VALUES ('" + req.user.id + "', to_date('" + start_of_week_str + "', 'YYYY-MM-DD'), " + day + ", " + start_hour + ", " + end_hour + ");\n";
        }
    }
    query += "commit;";

    try {
        await db.any(query);
        req.flash("success", "Schedules updated success.");
    } catch (e) {
        console.log(e);
        req.flash("error", "Schedules updated failed.");
    } finally {
        res.redirect("/rider/schedule/" + start_of_week_str);
    }
});

// todo: handlers for sub pages.

module.exports = router;
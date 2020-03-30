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
    join_date = new Date(dateToUrl(join_date.join_date));
    console.log(join_date);
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

        let schedules = [];
        for (var i = 0; i < 7; i++) {
            schedules.push([]);
        }

        await db.each("select * from PWS where rid = $1 and start_of_week = date $2 order by (day_of_week, start_hour)",
            [req.user.id, date_req_str],
            row => {
            schedules[row.day_of_week].push([row.start_hour, row.end_hour - row.start_hour]);
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
    let start_of_week = new Date(req.body.start_of_week);
    let start_of_week_str = dateToUrl(start_of_week);
    let start_hour, end_hour;

    let query = "DELETE FROM PWS WHERE start_of_week = date '" + start_of_week_str + "';\n";
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
                        "VALUES ('" + req.user.id + "', date '" + start_of_week_str + "', " + day + ", " + start_hour + ", " + end_hour + ");\n";

                    start_hour = end_hour;
                }
            }
        }
        if (start_hour !== end_hour) {
            query += "INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour) " +
                "VALUES ('" + req.user.id + "', date '" + start_of_week_str + "', " + day + ", " + start_hour + ", " + end_hour + ");\n";
        }
    }

    db.tx(async t => {
        await db.none(query);
        req.flash("success", "Schedules updated success.");
    }).then(data => {
        return res.redirect("/rider/schedule/" + start_of_week_str);
    }).catch(error => {
        console.log(error);
        req.flash("error", "Schedules updated failed.");
        return res.redirect("/rider/schedule/" + start_of_week_str);
    });

});

// todo: handlers for sub pages.

module.exports = router;
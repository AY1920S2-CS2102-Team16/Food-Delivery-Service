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
    let date_req = new Date(req.params.date_req);

    let rider_type = await db.one("select type from Riders where id = $1", req.user.id);
    if (rider_type.type === "full_time") {
        let day_in_month = (date_req - join_date) / (1000 * 60 * 60 * 24) % 28;
        if (day_in_month < 0) {
            day_in_month = day_in_month + 28;
        }
        console.log(day_in_month);
        let day_in_week =day_in_month % 7;
        date_req.setDate(date_req.getDate() - day_in_month);
        let start_of_month_str = dateToUrl(date_req);
        let start_of_month = new Date(start_of_month_str);
        date_req.setDate(date_req.getDate() + day_in_month);
        date_req.setDate(date_req.getDate() - day_in_week); // date_req converted to start_of_week

        let schedules = [];
        for (let i = 0; i < 7; i ++) {
            schedules.push([]);
        }

        let prototype_week = await db.oneOrNone("select * from FWS where rid = $1 and start_date = date $2",
            [req.user.id, start_of_month_str]);
        if (prototype_week !== null) {
            let shifts = [prototype_week.day_one, prototype_week.day_two, prototype_week.day_three, prototype_week.day_four,
                prototype_week.day_five, prototype_week.day_six, prototype_week.day_seven];
            for (let i = 0; i < 7; i++) {
                await db.each("select * from Shifts where shift_num = $1", shifts[i], row => {
                    schedules[i].push([row.first_start_hour, row.first_end_hour - row.first_start_hour]);
                    schedules[i].push([row.second_start_hour, row.second_end_hour - row.second_start_hour]);
                });
            }
        }

        // let schedules = await db.any("select * from FWS where rid = $1", req.user.id);
        res.render("pages/rider/riderFT-schedule",{
            sidebarItems: sidebarItems,
            user: req.user,
            navbarTitle: "One week in Monthly Schedule",
            start_of_week: date_req,
            start_of_month: start_of_month,
            schedules: schedules,

            successFlash: req.flash("success"),
            errorFlash: req.flash("error")
        });
    } else { // part_time rider
        let day_in_week = (date_req - join_date) / (1000 * 60 * 60 * 24) % 7;
        console.log(day_in_week);
        date_req.setDate(date_req.getDate() - day_in_week); // date_req converted to start_of_week
        console.log(date_req);
        let date_req_str = dateToUrl(date_req);

        let schedules = [];
        for (let i = 0; i < 7; i++) {
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

router.post("/schedule/changePTSchedule", async function(req, res) {
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

router.post("/schedule/changeFTSchedule", async function(req, res) {
    let start_of_week = new Date(req.body.start_of_week);
    let start_of_week_str = dateToUrl(start_of_week);
    let start_of_month = new Date(req.body.start_of_month);
    let start_of_month_str = dateToUrl(start_of_month);
    // let start_hour, end_hour;

    // let query = "DELETE FROM PWS WHERE start_of_week = date '" + start_of_week_str + "';\n";

    let query_values = [req.user.id, start_of_month_str];
    for (let day = 0; day < 7; day++) {
        query_values.push(req.body["day" + day + "_shift"]);

        /*
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

         */
    }

    let prototype_week = await db.oneOrNone("select * from FWS where FWS.rid = $1 and FWS.start_date = date $2",
        [req.user.id, start_of_month_str]);

    db.task(async t => {
        if (prototype_week === null) {
            await db.none("insert into FWS\n" +
                "values ($1, date $2, $3, $4, $5, $6, $7, $8, $9)", query_values);
        } else {
            await db.none("update FWS " +
                "set day_one = $3, set day_two = $4, set day_three = $5, set day_four = $6, " +
                "set day_five = $7, set day_six = $8, set day_seven = $9 " +
                "where rid = $1 and start_date = date $2", query_values);
        }
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
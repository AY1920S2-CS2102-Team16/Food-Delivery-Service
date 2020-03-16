const passport = require("passport"),
    LocalStrategy = require("passport-local").Strategy,
    db = require("../database/db");

passport.serializeUser(function (user, done) {
    done(null, user);
});

passport.deserializeUser(function (user, done) {
    done(null, user);
});

passport.use(new LocalStrategy({
        usernameField: "userId",
        passwordField: "password",
        passReqToCallback: true
    },
    async function (req, username, password, done) {
        let role = req.body.role + "s";
        let user;
        try {
            user = await db.one("select * from users u join " + role + " v on u.id = v.id where u.id = $1 and password = $2", [username, password]);
            user = {...user, role: req.body.role};
            return done(null, user);
        } catch (e) {
            return done(e);
        }
    }
));

module.exports = passport;




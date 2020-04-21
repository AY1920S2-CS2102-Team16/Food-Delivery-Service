create extension if not exists cube;
create extension if not exists earthdistance;
create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

drop table if exists Users, Managers, Customers, Restaurants, Riders, Sells, CustomerLocations, Orders, OrderFoods,
    Constants, Reviews, PromotionActions, PromotionRules, Promotions, CustomerCards, FWS, Shifts, PWS, Salaries cascade;

drop view if exists UserInfo;
drop view if exists RiderSummary;
drop view if exists LimitedRiderSummary;
drop view if exists AvailableRiders;

drop type if exists food_category_t, delivery_rating_t, payment_mode_t, promo_rule_t, promo_action_t,
    shift_t, rider_type_t cascade;

/*
  Checks if longitude is valid.
*/
create or replace function fn_check_lon(lon float) returns boolean as
$$
begin
    return (lon >= -180 and lon <= 180);
end;
$$ language plpgsql;

/*
  Checks if latitude is valid
*/
create or replace function fn_check_lat(lat float) returns boolean as
$$
begin
    return (lat >= -90 and lat <= 90);
end;
$$ language plpgsql;

create or replace function fn_check_promotion_giver_domain(id_to_check varchar(20)) returns boolean as
$$
begin
    if (exists(select 1
               from (select id from Restaurants union select id from Managers) as RM
               where RM.id = id_to_check)) then
        return true;
    end if;
    return false;
end;
$$ language plpgsql;

create type food_category_t as enum ('Chinese', 'Western', 'Malay', 'Indian', 'Fast food');
create type payment_mode_t as enum ('Cash', 'Card');
create type shift_t AS ENUM ('1', '2', '3', '4', '0'); -- '0' means rest day.
create type rider_type_t AS ENUM ('full_time', 'part_time');

create type promo_rule_t as enum ('ORDER_TOTAL', 'NTH_ORDER', 'INACTIVITY');
create type promo_action_t as enum ('FOOD_DISCOUNT', 'DELIVERY_DISCOUNT');

/*
 General user information.
 User password are hashed before saving into database (see: tr_hash_password).
 */
create table Users
(
    id        varchar(20) primary key check (id similar to '[a-zA-Z0-9\-_]*'),
    password  text        not null,
    username  varchar(50) not null,
    join_date DATE        not null default CURRENT_TIMESTAMP
);

/*
  FDS manager accounts.
*/
create table Managers
(
    id varchar(20) primary key references Users (id) on delete cascade
);

/*
  Restaurant staff accounts.
*/
create table Restaurants
(
    id            varchar(20) primary key references Users (id) on delete cascade,
    rname         varchar(50),
    description   varchar(1000), -- brief information of the restaurant,
    minimum_spend money        not null default 0 check (minimum_spend > 0::money),
    address       varchar(100) not null,
    lon           float        not null check (fn_check_lon(lon)),
    lat           float        not null check (fn_check_lat(lat))
);

/*
  FDS customer accounts.
*/
create table Customers
(
    id     varchar(20) primary key references Users (id) on delete cascade,
    reward_points float not null default 0 check (reward_points >= 0)
);

/*
  FDS rider accounts
*/
create table Riders
(
    id   varchar(20) primary key references Users (id) on delete cascade,
    type rider_type_t not null,
    lon  float check (fn_check_lon(lon)),
    lat  float check (fn_check_lat(lat))
);

/*
  Food items each restaurant is selling.
*/
create table Sells
(
    rid              varchar(20) references Restaurants (id) on delete cascade,
    food_name        varchar(50) check (not food_name = ''),
    food_description text,
    food_category    food_category_t not null,
    daily_limit      integer         not null,
    daily_sold       integer         not null default 0,
    price            money           not null check (price >= 0::money),

    constraint daily_limit check (daily_limit >= 0 and daily_limit >= daily_sold),
    constraint daily_sold check (daily_sold >= 0),
    primary key (rid, food_name)
);

/*
 Customers' delivery addresses.
 Guarantees: Each customer can have at most 5 locations (by tr_ensure_maximum_recent_location).
             Least recent used locations will be removed if the locations for a customer are full and new locations are added.
 */
create table CustomerLocations
(
    cid            varchar(20),
    lon            float check (fn_check_lon(lon)),
    lat            float check (fn_check_lat(lat)),
    address        varchar(100) not null,
    last_used_time timestamp    not null default CURRENT_TIMESTAMP,

    foreign key (cid) references Customers (id) on delete cascade,
    primary key (cid, lon, lat)
);

create table Orders
(
    id             serial,
    rid            varchar(20)    references Restaurants (id) on delete set null,
    delivery_cost  money          not null default 0::money check (delivery_cost >= 0::money),
    food_cost      money          not null default 0::money check (food_cost >= 0::money),

    -- delivery information
    rider_id       varchar(20)             default null references Riders (id) on delete set null,
    cid            varchar(20),
    lon            float check (fn_check_lon(lon)),
    lat            float check (fn_check_lat(lat)),

    -- timing information
    time_placed    timestamp      not null default CURRENT_TIMESTAMP,
    time_depart    timestamp               default null,
    time_collect   timestamp               default null,
    time_leave     timestamp               default null,
    time_delivered timestamp               default null,
    time_paid      timestamp               default null,

    payment_mode   payment_mode_t not null,

    remarks        varchar(500)            default '',

    foreign key (cid, lon, lat) references CustomerLocations (cid, lon, lat) on delete set null,
    primary key (id)
);

create table Reviews
(
    oid         integer primary key not null references Orders (id) on delete cascade,
    rating      integer check (rating >= 1 and rating <= 5),
    content     varchar(1000)       not null,
    create_time timestamp           not null default CURRENT_TIMESTAMP
);

/*
 Food items of orders.
 Guarantees: All food items for a single order is from the same restaurant (by tr_order_food_from_same_restaurant).
 */
create table OrderFoods
(
    id        serial,
    oid       integer not null references Orders (id) on delete cascade,
    rid       varchar(20),
    food_name varchar(50),
    quantity  integer not null check (quantity > 0),

    foreign key (rid, food_name) references Sells (rid, food_name) on delete set null,
    unique (oid, rid, food_name),
    primary key (id) -- cannot use aggregate key (oid, rid, food_name) because rid should be set to null when an item is deleted by restaurant

);


/*
  Customers' credit card information.
  - Guarantees: Each customer has at most one credit card.
  - Reason for not putting card information as attribute of Customer:
    Extensibility - it will be easier when e we later want to support multiple cards for a customer.
 */
create table CustomerCards
(
    cid    varchar(20) primary key references Customers (id) on delete cascade,
    number varchar(19) not null check (number ~ $$\d{4}-?\d{4}-?\d{4}-?\d{4}$$),             -- 16 digits (optionally separated by hyphens)
    expiry varchar(7)  not null check (expiry ~ $$^(0[1-9]|1[0-2])\/?([0-9]{4}|[0-9]{2})$$), -- valid formats: MM/YY, MMYY, MM/YYYY, MM/YY
    name   varchar(20) not null,
    cvv    varchar(4)  not null check (cvv ~ $$^[0-9]{3,4}$$)                                -- 3 or 4 digits
);

/**
  General FDS configurations.
 */
create table Constants
(
    salt          text  not null, -- salt used to hash password
    reward_cutoff float not null,
    primary key (salt, reward_cutoff)
);

create table PromotionRules
(
    id       serial primary key,

    giver_id varchar(20) not null references Users (id) on delete cascade check (fn_check_promotion_giver_domain(giver_id)),

    rtype    promo_rule_t,
    config   jsonb
);

create table PromotionActions
(
    id       serial primary key,

    giver_id varchar(20) not null references Users (id) on delete cascade check (fn_check_promotion_giver_domain(giver_id)),

    atype    promo_action_t,
    config   jsonb
);

create table Promotions
(
    id         serial primary key,

    promo_name varchar(50)       not null,
    rule_id    integer           not null references PromotionRules (id) on delete cascade,
    action_id  integer           not null references PromotionActions (id) on delete cascade,

    num_orders integer default 0 not null,

    start_time timestamp         not null,
    end_time   timestamp         not null check (start_time <= end_time),

    giver_id   varchar(20)       not null references Users (id) on delete cascade check (fn_check_promotion_giver_domain(giver_id))
);

/*
  Returns absolute day difference between two dates.
 */
create or replace function day_diff(start_date date, end_date date) returns integer as
$$
begin
    return abs(end_date - start_date);
end;
$$ language plpgsql;

/*
  Ensures months in each FWS tuples do not overlap.
 */
create or replace function fn_check_start_date(rid varchar(20), start_date date) returns boolean as
$$
declare join_date date;
begin
    select Users.join_date::date into join_date
    from Users where id = rid;

    if ((start_date - join_date) % 28 <> 0 or start_date < join_date)
    then return false;
    else return true;
    end if;

end;
$$ language plpgsql;

create or replace function fn_get_rider_type(this_rid varchar(20)) returns rider_type_t as
$$
begin
    return (select type
            from Riders
            where id = this_rid);
end;
$$ language plpgsql;

/*
  Full time riders work schedule
  - Guarantees: Differences among each start_date are at least 1 month.
 */
create table FWS
(
    rid        varchar(20) references Riders (id) on delete cascade,
    start_date date,
    day_one          shift_t not null default '0',
    day_two          shift_t not null default '0',
    day_three        shift_t not null default '0',
    day_four         shift_t not null default '0',
    day_five         shift_t not null default '0',
    day_six          shift_t not null default '0',
    day_seven        shift_t not null default '0',

    check (fn_get_rider_type(rid) = 'full_time'),
    check (fn_check_start_date(rid, start_date)),

    primary key (rid, start_date)
);

create table Shifts
(
    shift_num shift_t primary key,
    first_start_hour integer check(first_start_hour >= 10 and first_start_hour < 22),
    first_end_hour integer check(first_end_hour > 10 and first_end_hour <= 22),
    second_start_hour integer check(second_start_hour >= 10 and second_start_hour < 22),
    second_end_hour integer check(second_end_hour > 10 and second_end_hour <= 22)
);

begin;
INSERT INTO Shifts (shift_num, first_start_hour, first_end_hour, second_start_hour, second_end_hour)
VALUES ('1', 10, 14, 15, 19);
INSERT INTO Shifts (shift_num, first_start_hour, first_end_hour, second_start_hour, second_end_hour)
VALUES ('2', 11, 15, 16, 20);
INSERT INTO Shifts (shift_num, first_start_hour, first_end_hour, second_start_hour, second_end_hour)
VALUES ('3', 12, 16, 17, 21);
INSERT INTO Shifts (shift_num, first_start_hour, first_end_hour, second_start_hour, second_end_hour)
VALUES ('4', 13, 17, 18, 22);
end;

/*
  Ensures time intervals of each day in PWS do not overlap.
 */
create or replace function fn_check_time_overlap(rid varchar(20), start_of_week date, day_of_week integer, start_hour integer, end_hour integer) returns boolean as
$$
begin

    return not exists(select 1
                          from PWS P
                          where P.rid = fn_check_time_overlap.rid
                          and P.start_of_week = fn_check_time_overlap.start_of_week
                          and P.day_of_week = fn_check_time_overlap.day_of_week
                          and ((P.start_hour >= fn_check_time_overlap.start_hour and P.start_hour <= fn_check_time_overlap.end_hour)
                              or
                              (fn_check_time_overlap.start_hour >= P.start_hour and fn_check_time_overlap.start_hour <= P.end_hour))
                     );

end;
$$ language plpgsql;

/*
  Ensures weeks in each PWS tuples do not overlap.
 */
create or replace function fn_check_start_of_week(rid varchar(20), start_of_week date) returns boolean as
$$
declare
join_date date;
begin
    select Users.join_date::date into join_date
    from Users where Users.id = rid;

    if ((start_of_week - join_date) % 7 <> 0 or start_of_week < join_date)
    then return false;
    else return true;
    end if;

end;
$$ language plpgsql;

/*
  Part time workers work schedule
 */
create table PWS
(
    rid           varchar(20) references Riders (id) on delete cascade,
    start_of_week date not null,
    day_of_week   integer check (day_of_week in (0, 1, 2, 3, 4, 5, 6)),
    start_hour    integer not null check (start_hour >= 10 and start_hour <= 21),
    end_hour      integer not null check (end_hour >= 11 and end_hour <= 22),

    check (fn_get_rider_type(rid) = 'part_time'),
    check (end_hour - start_hour <= 4 and end_hour > start_hour),
    check (fn_check_time_overlap(rid, start_of_week, day_of_week, start_hour, end_hour)),
    check (fn_check_start_of_week(rid, start_of_week)),
    primary key (rid, start_of_week, day_of_week, start_hour)
);

/*
  Ensures dates in each Salary tuples can be found in PWS or FWS.
 */
create or replace function fn_check_salary_date(this_rid varchar(20), salary_date date) returns boolean as
$$
begin
    if (fn_get_rider_type(this_rid) = 'full_time')
    then
        return exists(select 1
                      from FWS
                      where rid = this_rid
                      and start_date = salary_date);
    else
        return exists(select 1
                      from PWS
                      where rid = this_rid
                      and start_of_week = salary_date);
    end if;
end;
$$ language plpgsql;

/*
  Each tuples represent salaries that week/month.
 */
create table Salaries
(
    rid        varchar(20) references Riders (id) on delete cascade,
    start_date date,
    base       money not null,
    bonus      money not null default 0,

    check (fn_check_salary_date(rid, start_date)),
    -- update bonus once an order is completed. trigger

    primary key (rid, start_date)
);

create view UserInfo
as
select id,
       username,
       join_date,
       case
           when exists(select 1 from Customers c where c.id = u.id) then 'Customer'
           when exists(select 1 from Restaurants c where c.id = u.id) then 'Restaurant'
           when exists(select 1 from Riders c where c.id = u.id) then 'Rider'
           when exists(select 1 from Managers c where c.id = u.id) then 'Manager'
           end as role
from Users u;

create view RiderSummary(rid, start_date, num_order, total_hour, base_salary, bonus_salary, total_salary, avg_delivery_time, num_rating, avg_rating)
as
select S.rid,
       S.start_date,
       count(O.id),
       case R.type
           when 'part_time' then (select sum(end_hour - start_hour)
                                  from PWS P
                                  where P.rid = S.rid and P.start_of_week = S.start_date)
           when 'full_time' then 4 * 5 * 8 -- 4 weeks, 5 days per week, 8 hours per day
           end,
       S.base,
       S.bonus,
       S.base + S.bonus,
       to_char(avg(date_trunc('second', time_delivered - time_placed)), 'HH24:MI:SS'),
       count(RV.rating),
       round(avg(RV.rating), 2)
from Riders R join Salaries S on (R.id = S.rid) left join Orders O
     on (S.rid = O.rider_id and O.time_delivered::date >= S.start_date
        and O.time_delivered::date - S.start_date < case R.type
                                                        when 'part_time' then 7
                                                        when 'full_time' then 28 end)
              left join Reviews RV on (O.id is not distinct from RV.oid)
group by (R.id, S.rid, S.start_date);

create view LimitedRiderSummary (rid, start_date, num_order, total_hour, base_salary, bonus_salary, total_salary)
as
select R.rid, R.start_date, R.num_order, R.total_hour, R.base_salary, R.bonus_salary, R.total_salary
from RiderSummary R;

drop index if exists trgm_idx;
create index trgm_idx on Sells using gist (food_name gist_trgm_ops);

create view AvailableRiders(rid)
as
select rid
from PWS
where start_of_week + day_of_week + (start_hour || ' hour')::interval <= CURRENT_TIMESTAMP
  and start_of_week + day_of_week + (end_hour || ' hour')::interval > CURRENT_TIMESTAMP
union
-- union both available part time and full time riders.
select rid
from FWS F,
     Shifts S
where CURRENT_DATE - F.start_date < 28
  and CURRENT_DATE >= F.start_date
  and S.shift_num = case (CURRENT_DATE - F.start_date) % 7
                        when 0 then F.day_one
                        when 1 then F.day_two
                        when 2 then F.day_three
                        when 3 then F.day_four
                        when 4 then F.day_five
                        when 5 then F.day_six
                        when 6 then F.day_seven
    end
  and ((CURRENT_DATE + (S.first_start_hour || ' hour')::interval <= CURRENT_TIMESTAMP
    and CURRENT_DATE + (S.first_end_hour || ' hour')::interval > CURRENT_TIMESTAMP)
    or
       (CURRENT_DATE + (S.second_start_hour || ' hour')::interval <= CURRENT_TIMESTAMP
           and CURRENT_DATE + (S.second_end_hour || ' hour')::interval > CURRENT_TIMESTAMP));

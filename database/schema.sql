create extension if not exists cube;
create extension if not exists earthdistance;
create extension if not exists pgcrypto;

drop table if exists Users, Managers, Customers, Restaurants, Riders, Sells, CustomerLocations, Orders, OrderFoods,
    Constants, Reviews, PromotionActions, PromotionRules, Promotions, CustomerCards cascade;
drop type if exists food_category_t, delivery_rating_t, payment_mode_t, promo_rule_t, promo_action_t cascade;

create or replace function fn_check_lon(lon float) returns boolean as
$$
begin
    return (lon >= -180 and lon <= 180);
end;
$$ language plpgsql;

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
create type delivery_rating_t as enum ('Excellent', 'Good', 'Average', 'Bad', 'Disappointing');
create type payment_mode_t as enum ('Cash', 'Card');

create type promo_rule_t as enum ('ORDER_TOTAL', 'NTH_ORDER', 'INACTIVITY');
create type promo_action_t as enum ('FOOD_DISCOUNT', 'DELIVERY_DISCOUNT');

/*
 General user information.
 User password are hashed before saving into database (see: tr_hash_password).
 */
create table Users
(
    id        varchar(20) primary key,
    password  text        not null,
    username  varchar(50) not null,
    join_date DATE        not null default CURRENT_TIMESTAMP

    --credit_card_number_encrypted
);

create table Managers
(
    id varchar(20) primary key references Users (id) on delete cascade
);

create table Restaurants
(
    id          varchar(20) primary key references Users (id) on delete cascade,
    rname       varchar(50),
    description varchar(1000), -- brief information of the restaurant
    address     varchar(100) not null,
    lon         float        not null check (fn_check_lon(lon)),
    lat         float        not null check (fn_check_lat(lat))
);

create table Customers
(
    id     varchar(20) primary key references Users (id) on delete cascade,
    points integer
);

create table Riders
(
    id   varchar(20) primary key references Users (id) on delete cascade,
    name varchar(50)
);

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

create table Reviews
(
    id      serial primary key,
    content varchar(1000) not null,
    rid     varchar(20)   not null references Restaurants (id) on delete cascade
);

create table Orders
(
    id             serial,
    rid            varchar(20)    not null references Restaurants (id) on delete set null,
    delivery_cost  money          not null default 0::money check (delivery_cost >= 0::money),
    food_cost      money          not null default 0::money check (food_cost >= 0::money),

    -- delivery information
    rider_id       varchar(20)             default null references Riders (id), /* TODO: Assign rider to order based on rider schedule */
    cid            varchar(20)    not null,
    lon            float          not null check (fn_check_lon(lon)),
    lat            float          not null check (fn_check_lat(lat)),

    -- timing information
    time_placed    timestamp      not null default CURRENT_TIMESTAMP,
    time_depart    timestamp,
    time_collect   timestamp,
    time_leave     timestamp,
    time_delivered timestamp,

    rating         delivery_rating_t,
    review_id      integer unique,
    payment_mode   payment_mode_t not null,

    foreign key (review_id) references Reviews (id) on delete set null,
    foreign key (cid, lon, lat) references CustomerLocations (cid, lon, lat) on delete set null,
    primary key (id)
);

/*
 Food items of orders.
 Guarantees: All food items for a single order is from the same restaurant (by tr_order_food_from_same_restaurant).
 */
create table OrderFoods
(
    id        serial, -- cannot use aggregate key (oid, rid, food_name) because rid should be set to null when an item is deleted by restaurant
    oid       integer not null references Orders (id) on delete cascade,
    rid       varchar(20),
    food_name varchar(50),
    quantity  integer not null check (quantity > 0),

    foreign key (rid, food_name) references Sells (rid, food_name) on delete set null,
    unique (oid, rid, food_name),
    primary key (id)
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

create table Constants
(
    salt text,
    primary key (salt)
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

    promo_name varchar(50) not null,
    rule_id    integer     not null references PromotionRules (id) on delete cascade,
    action_id  integer     not null references PromotionActions (id) on delete cascade,

    start_time timestamp   not null,
    end_time   timestamp   not null,

    giver_id varchar(20) not null references Users (id) on delete cascade check (fn_check_promotion_giver_domain(giver_id))
);

-- Promotion types: 满减，满百分比，满免运费，首单减5刀 etc.

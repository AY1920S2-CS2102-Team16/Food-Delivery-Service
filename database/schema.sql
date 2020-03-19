create extension if not exists cube;
create extension if not exists earthdistance;
create extension if not exists pgcrypto;

drop table if exists Users, Managers, Customers, Restaurants, Riders, Sells, CustomerLocations, Orders, OrderFoods, 
    Constants, Review, PromotionActions, PromotionRules, Promotions cascade;
drop type if exists food_category_t, delivery_rating_t, payment_mode_t;

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

create type food_category_t AS ENUM ('Chinese', 'Western', 'Malay', 'Indian', 'Fast food');
create type delivery_rating_t AS ENUM ('Excellent', 'Good', 'Average', 'Bad', 'Disappointing');
create type payment_mode_t AS ENUM ('Cash', 'Card');

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
    id varchar(20) primary key references Users (id) on delete cascade,
    points integer,
    c_card varchar(19) --max num of digits for credit card number seems to be 19
);

create table Riders
(
    id varchar(20) primary key references Users (id) on delete cascade,
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

create table Review 
(
    id     serial primary key,
    review text not null, 
    rid    varchar(20) not null references Restaurants (id) on delete cascade
);

create table Orders
(
    id             serial,
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
    review_id    integer unique,
    payment_mode   payment_mode_t not null,

    foreign key (review_id) references Review (id) on delete set null,
    foreign key (cid, lon, lat) references CustomerLocations (cid, lon, lat) on delete set null,
    primary key (id)
);

/*
 Food items of orders.
 Guarantees: All food items for a single order is from the same restaurant (by tr_order_food_from_same_restaurant).
 */
create table OrderFoods
(
    rid       varchar(20),
    oid       integer references Orders (id) on delete cascade,
    food_name varchar(50),
    quantity  integer not null check (quantity > 0),

    foreign key (rid, food_name) references Sells (rid, food_name) on delete set null,
    primary key (oid, rid, food_name)
);

create table Constants
(
    salt text,
    primary key (salt)
);

create table PromotionRules
(
    id serial primary key,
    rtype varchar(30),
    config varchar(100)
);

create table PromotionActions
(
    id serial primary key,
    atype varchar(30),
    config varchar(100)
);

create table Promotions
(
    promo_name varchar(50) unique not null,
    promo_id serial primary key,

    rule_id integer not null references PromotionRules (id),
    action_id integer not null references PromotionActions (id),

    start_time timestamp,
    end_time timestamp,
    num_of_orders integer,

    giver_id varchar(20) not null
);


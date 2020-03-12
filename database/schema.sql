drop table if exists Users, Managers, Customers, Restaurants, Riders, Sells, CustomerLocations, Orders, OrderFoods, Delivers;
drop type if exists food_category_t, delivery_rating_t;

create type food_category_t AS ENUM ('Chinese', 'Western', 'Malay', 'Indian', 'Fast food');
create type delivery_rating_t AS ENUM ('Excellent', 'Good', 'Average', 'Bad', 'Disappointing');

create table Users
(
    uid       varchar(20) primary key,
    password  text        not null,
    username  varchar(50) not null,
    join_date DATE        not null default CURRENT_TIMESTAMP
);

create table Managers
(
    id varchar(20) primary key references Users (uid)
        on delete cascade,
    check (is_overlapping_role(id) = 'False')
);

create table Restaurants
(
    id          varchar(20) primary key references Users (uid) on delete cascade,
    rname       varchar(50),
    description varchar(1000), -- brief information of the restaurant
    address     text  not null,
    lon         float not null,
    lat         float not null,
    check (is_overlapping_role(id) = 'False')
);

create table Customers
(
    id varchar(20) primary key references Users (uid)
        on delete cascade,
    check (is_overlapping_role(id) = 'False')

);

create table Riders
(
    id varchar(20) primary key references Users (uid)
        on delete cascade,
    check (is_overlapping_role(id) = 'False')
);

create table Sells
(
    rid              varchar(20) references Restaurants (id) on delete cascade,
    food_name        varchar(50) check (not food_name = ''),
    food_description text,
    food_category    food_category_t NOT NULL,
    daily_limit      integer         NOT NULL check (daily_limit >= 0),
    -- todo: count daily sold
    price            integer         NOT NULL check (price >= 0), -- price in cents
    primary key (rid, food_name)
);

create table CustomerLocations
(
    cid            varchar(20),
    lon            float,
    lat            float,
    address        varchar(100) not null,
    last_used_time timestamp    not null default CURRENT_TIMESTAMP,
    primary key (cid, lon, lat)
);

create table Orders
(
    id            serial,
    delivery_cost integer not null,
    food_cost     integer not null,

    primary key (id)
);

create table OrderFoods
(
    rid       varchar(20),
    food_name varchar(50),
    oid       integer references Orders (id),
    quantity  integer not null,

    foreign key (rid, food_name) references Sells (rid, food_name),
    primary key (oid, rid, food_name)
);

create table Delivers
(
    oid            integer references Orders (id),
    rid            varchar(20) not null references Riders (id),
    cid            varchar(20) not null,
    lon            float8      not null,
    lat            float8      not null,

    time_depart    timestamp,
    time_collect   timestamp,
    time_leave     timestamp,
    time_delivered timestamp,
    rating         delivery_rating_t,

    primary key (oid),
    foreign key (cid, lon, lat) references CustomerLocations (cid, lon, lat)
);

create or replace function is_overlapping_role(uid varchar(20)) returns varchar(5) as
$$
begin
    if exists(select id
              from (select id
                    from Customers
                    union
                    select id
                    from Restaurants
                    union
                    select id
                    from Riders
                    union
                    select id
                    from Managers) as IDS
              where IDS.id = uid
        ) then
        return 'True';
    end if;
    return 'False';
end;
$$ language plpgsql;

insert into Users
values ('alice', '123456', 'Alice');
insert into Customers
values ('alice');
insert into Users
values ('kfc', '123456', 'KFC');
insert into Restaurants
values ('kfc', 'KFC', 'kfc fast food restaurant', 'Avenue 1', 1.112300, 1.11231);

insert into Sells
values ('kfc', 'Fries', 'French fries', 'Fast food', 50, 600);
insert into Sells
values ('kfc', 'Cheese burger', 'Cheese burger', 'Fast food', 50, 1000);

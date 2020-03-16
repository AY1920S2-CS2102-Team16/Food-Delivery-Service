create extension if not exists cube;
create extension if not exists earthdistance;

drop table if exists Users, Managers, Customers, Restaurants, Riders, Sells, CustomerLocations, Orders, OrderFoods, Delivers cascade;
drop type if exists food_category_t, delivery_rating_t;

create type food_category_t AS ENUM ('Chinese', 'Western', 'Malay', 'Indian', 'Fast food');
create type delivery_rating_t AS ENUM ('Excellent', 'Good', 'Average', 'Bad', 'Disappointing');

create table Users
(
    id        varchar(20) primary key,
    password  text        not null,
    username  varchar(50) not null,
    join_date DATE        not null default CURRENT_TIMESTAMP
);

create table Managers
(
    id varchar(20) primary key references Users (id)
        on delete cascade
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
    id varchar(20) primary key references Users (id)
        on delete cascade
);

create table Riders
(
    id varchar(20) primary key references Users (id)
        on delete cascade
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

    constraint constraint_daily_limit check (daily_limit >= 0 and daily_limit >= daily_sold),
    constraint constraint_daily_sold check (daily_sold >= 0 and daily_sold <= daily_limit),
    primary key (rid, food_name)
);

create table CustomerLocations
(
    cid            varchar(20),
    lon            float check (fn_check_lon(lon)),
    lat            float check (fn_check_lat(lat)),
    address        varchar(100) not null,
    last_used_time timestamp    not null default CURRENT_TIMESTAMP,
    primary key (cid, lon, lat)
);

create table Orders
(
    id            serial,
    delivery_cost money not null check (delivery_cost >= 0::money),
    food_cost     money not null check (food_cost >= 0::money),

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
    lon            float       not null check (fn_check_lon(lon)),
    lat            float       not null check (fn_check_lat(lat)),

    time_depart    timestamp,
    time_collect   timestamp,
    time_leave     timestamp,
    time_delivered timestamp,
    rating         delivery_rating_t,

    primary key (oid),
    foreign key (cid, lon, lat) references CustomerLocations (cid, lon, lat)
);


/*
 Updates daily sold food items whenever an order is placed or updated.
 */
drop trigger if exists tr_update_daily_sold on OrderFoods cascade;
create trigger tr_update_daily_sold
    before insert or update
    on OrderFoods
    for each row
execute function increase_daily_sold();

create or replace function increase_daily_sold() returns trigger as
$$
begin
    update Sells
    set daily_sold = daily_sold + new.quantity - (case when old.quantity is null then 0 else old.quantity end)
    where rid = new.rid
      and food_name = new.food_name;
    return new;
end;
$$ language plpgsql;

/*
  Ensures only the number of location for each customer dose not exceed maximum number. If attempting to insert
  after reaching the maximum, the least recently used location will be removed.
 */
drop trigger if exists tr_ensure_maximum_recent_location on CustomerLocations cascade;
create trigger tr_ensure_maximum_recent_location
    after insert
    on CustomerLocations
    for each row
execute function ensure_maximum_recent_location();

create or replace function ensure_maximum_recent_location() returns trigger as
$$
begin
    delete
    from CustomerLocations
    where (cid, lat, lon) in (
        select cid, lat, lon
        from CustomerLocations
        where cid = new.cid
        order by last_used_time desc
            offset 5
        limit 1);
    return null;
end ;
$$ language plpgsql;

/**
  Ensures that non-overlapping and covering ISA relationship between Users and different user roles.
 */
create or replace function fn_ensure_covering_and_non_overlapping_roles() returns trigger as
$$
begin
    if (select count(*)
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
        where IDS.id = new.id
       ) = 1 then
        return null;
    end if;
    raise exception 'User id % already has an other role or is not given a role.', new.id;
end;
$$ language plpgsql;

drop trigger if exists tr_users_covering_role on Users cascade;
create constraint trigger tr_users_covering_role
    after insert or update
    on Users
    deferrable initially deferred
    for each row
execute function fn_ensure_covering_and_non_overlapping_roles();

drop trigger if exists tr_restaurants_covering_role on Restaurants cascade;
create trigger tr_restaurants_covering_role
    after insert or update
    on Restaurants
    for each row
execute function fn_ensure_covering_and_non_overlapping_roles();

drop trigger if exists tr_customers_covering_role on Customers cascade;
create trigger tr_customers_covering_role
    after insert or update
    on Customers
    for each row
execute function fn_ensure_covering_and_non_overlapping_roles();

drop trigger if exists tr_riders_covering_role on Riders cascade;
create trigger tr_riders_covering_role
    after insert or update
    on Riders
    for each row
execute function fn_ensure_covering_and_non_overlapping_roles();

drop trigger if exists tr_managers_covering_role on Managers cascade;
create trigger tr_managers_covering_role
    after insert or update
    on Managers
    for each row
execute function fn_ensure_covering_and_non_overlapping_roles();

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

begin;
insert into Users
values ('alice', '123456', 'Alice');
insert into Customers
values ('alice');
insert into Users
values ('kfc', '123456', 'KFC');
insert into Restaurants
values ('kfc', 'KFC', 'kfc fast food restaurant', 'Avenue 1', 1.112300, 1.11231);
commit;

insert into Sells
values ('kfc', 'Fries', 'French fries', 'Fast food', 50, 0, 6);
insert into Sells
values ('kfc', 'Cheese burger', 'Cheese burger', 'Fast food', 50, 0, 10);

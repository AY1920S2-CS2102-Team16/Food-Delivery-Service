drop table if exists Users, Managers, Customers, Restaurants, Riders, Sells;
drop type if exists food_category_t;

create type food_category_t AS ENUM ('Chinese', 'Western', 'Malay', 'Indian', 'Fast food');

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
    check (is_id_exist(id) = 'False')
);

create table Restaurants
(
    id varchar(20) primary key references Users (uid)
        on delete cascade,
    check (is_id_exist(id) = 'False')
);

create table Customers
(
    id varchar(20) primary key references Users (uid)
        on delete cascade,
    check (is_id_exist(id) = 'False')

);

create table Riders
(
    id varchar(20) primary key references Users (uid)
        on delete cascade,
    check (is_id_exist(id) = 'False')
);

create table Sells
(
    rid              varchar(20) references Restaurants (id) on delete cascade,
    food_name        varchar(50) check (not food_name = ''),
    food_description text,
    food_category    food_category_t NOT NULL,
    daily_limit      integer         NOT NULL check (daily_limit >= 0),
    price            integer         NOT NULL check (price >= 0), -- price in cents
    primary key (rid, food_name)
);

create or replace function is_id_exist(uid varchar(20))
    returns varchar(5) AS
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
values ('kfc');

insert into Sells
values ('kfc', 'Fries', 'French fries', 'Fast food', 50, 600);
insert into Sells
values ('kfc', 'Cheese burger', 'Cheese burger', 'Fast food', 50, 1000);

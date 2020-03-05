drop table if exists Users, Managers, Customers, Restaurants, Riders;

create table Users
(
    uid       varchar(20) primary key,
    password  text        not null,
    username  varchar(50) not null,
    join_date DATE        not null default CURRENT_TIMESTAMP
);

create table Managers
(
    id varchar(20) primary key references Users (uid) on delete cascade,
    check (is_id_exist(id) = 'False')
);

create table Restaurants
(
    id varchar(20) primary key references Users (uid) on delete cascade
        check (is_id_exist(id) = 'False')
);

create table Customers
(
    id varchar(20) primary key references Users (uid) on delete cascade
        check (is_id_exist(id) = 'False')

);

create table Riders
(
    id varchar(20) primary key references Users (uid) on delete cascade
        check (is_id_exist(id) = 'False')
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
values ('abc', '123', 'david');
insert into Customers
values ('abc');

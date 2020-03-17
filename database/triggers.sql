create or replace function fn_hash_password() returns trigger as
$$
declare
    my_salt text;
begin
    select salt from Constants into my_salt;
    new.password = crypt(new.password, my_salt);
    return new;
end;
$$ language plpgsql;

drop trigger if exists tr_hash_password on Users cascade;
create trigger tr_hash_password
    before insert or update
    on Users
    for each row
execute function fn_hash_password();


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

/*
 Ensures that all ordered foods for an order are from a single restaurant.
 */
create or replace function fn_order_food_from_same_restaurant() returns trigger as
$$
begin
    if ((select count(distinct rid) from OrderFoods where oid = new.oid) <= 1) then
        return null;
    end if;
    raise exception '% is from a different restaurant compared with other foods in this order.', new.food_name;
end;
$$ language plpgsql;

drop trigger if exists tr_order_food_from_same_restaurant on OrderFoods cascade;
create trigger tr_order_food_from_same_restaurant
    after insert or update
    on OrderFoods
    for each row
execute function fn_order_food_from_same_restaurant();

/*
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

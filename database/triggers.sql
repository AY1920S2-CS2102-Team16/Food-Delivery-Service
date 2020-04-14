/*
 Hashes the password
 */
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
    before insert or update of password
    on Users
    for each row
execute function fn_hash_password();


/*
 Updates daily sold food items whenever an order is placed or updated.
 */
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

drop trigger if exists tr_update_daily_sold on OrderFoods cascade;
create trigger tr_update_daily_sold
    before insert or update
    on OrderFoods
    for each row
execute function increase_daily_sold();

/*
  Ensures only the number of location for each customer dose not exceed maximum number. If attempting to insert
  after reaching the maximum, the least recently used location will be removed.
 */
-- create or replace function ensure_maximum_recent_location() returns trigger as
-- $$
-- begin
--     delete
--     from CustomerLocations
--     where (cid, lat, lon) in (
--         select cid, lat, lon
--         from CustomerLocations
--         where cid = new.cid
--         order by last_used_time desc
--             offset 5
--         limit 1);
--     return null;
-- end ;
-- $$ language plpgsql;

-- drop trigger if exists tr_ensure_maximum_recent_location on CustomerLocations cascade;
-- create trigger tr_ensure_maximum_recent_location
--     after insert
--     on CustomerLocations
--     for each row
-- execute function ensure_maximum_recent_location();

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

/*
  Updates orders' total price based on food items ordered.
 */
create or replace function fn_update_order_total_price() returns trigger as
$$
begin
    update Orders
    set food_cost = food_cost + (select price
                                 from Sells
                                 where food_name = new.food_name
                                   and rid = new.rid) * new.quantity
    where id = new.oid;
    return null;
end;
$$ language plpgsql;

drop trigger if exists tr_order_total_price on OrderFoods cascade;
create trigger tr_order_total_price
    after insert
    on OrderFoods
    for each row
execute function fn_update_order_total_price();

/*
  Assign riders after order is placed.
 */
create or replace function fn_assign_rider() returns trigger as
$$
declare
    selected_rid varchar(20);
    restaurant_lon float;
    restaurant_lat float;
begin
    select lon into restaurant_lon from Restaurants where id = new.rid;
    select lat into restaurant_lat from Restaurants where id = new.rid;

    with AvailableRiders as
    (select rid as rider_id from PWS
    where start_of_week + day_of_week + (start_hour || ' hour')::interval <= CURRENT_TIMESTAMP
    and start_of_week + day_of_week + (end_hour || ' hour')::interval > CURRENT_TIMESTAMP
    union -- union both available part time and full time riders.
    select rid as rider_id
    from FWS F, Shifts S
    where CURRENT_DATE - F.start_date < 28 and CURRENT_DATE >= F.start_date
    and S.shift_num = case (CURRENT_DATE - F.start_date) % 7
         when 0 then F.day_one when 1 then F.day_two when 2 then F.day_three when 3 then F.day_four
         when 4 then F.day_five when 5 then F.day_six when 6 then F.day_seven
         end
    and ((CURRENT_DATE + (S.first_start_hour || ' hour')::interval <= CURRENT_TIMESTAMP
         and CURRENT_DATE + (S.first_end_hour || ' hour')::interval > CURRENT_TIMESTAMP)
         or
         (CURRENT_DATE + (S.second_start_hour || ' hour')::interval <= CURRENT_TIMESTAMP
         and CURRENT_DATE + (S.second_end_hour || ' hour')::interval > CURRENT_TIMESTAMP)))
    select A.rider_id into selected_rid
    from AvailableRiders A join Riders R on A.rider_id = R.id
         left join Orders O on A.rider_id = O.rider_id -- left join to preserve riders without any deliveries
         and O.time_delivered is null -- remove finished orders
    group by A.rider_id, R.id
    order by count(O.id), -- riders with less deliveries
             point(R.lon, R.lat) <@> point(restaurant_lon, restaurant_lat) -- riders closer to the restaurant
    limit 1; -- choose the most suitable rider.

    if (selected_rid is null) then raise exception 'No rider available!';
    end if;


    update Orders -- write the rider id to the new order
    set    rider_id = selected_rid
    where  id = new.id;

    return null;
end;
$$ language plpgsql;

drop trigger if exists tr_place_order on Orders cascade;
create trigger tr_place_order
    after insert on Orders
    for each row
execute function fn_assign_rider();

create or replace function fn_add_salary_bonus() returns trigger as
$$
declare
    rider_type        varchar(10);
    restaurant_lon    float;
    restaurant_lat    float;
    delivery_distance float;
    delivery_bonus    money;
begin
    select type into rider_type from Riders where id = new.rider_id;
    select lon into restaurant_lon from Restaurants where id = new.rid;
    select lat into restaurant_lat from Restaurants where id = new.rid;

    delivery_distance = (point(new.lon, new.lat) <@> point(restaurant_lon, restaurant_lat)) * 1609.344;
    if (delivery_distance <= 1000) then
        delivery_bonus = 2::money;
    elsif (delivery_distance > 1000 and delivery_distance <= 3000) then
        delivery_bonus = 3::money;
    elsif (delivery_distance > 3000 and delivery_distance <= 5000) then
        delivery_bonus = 4::money;
    else
        delivery_bonus = 5::money;
    end if;

    update Salaries
    set bonus = bonus + delivery_bonus
        -- $2 per miles
    where rid = new.rider_id
      and new.time_delivered::date >= start_date
      and new.time_delivered::date - start_date < case rider_type
                                                      when 'part_time' then 7
                                                      when 'full_time' then 28 end;
    return null;
end;
$$ language plpgsql;

drop trigger if exists tr_finish_delivery on Orders cascade;
create trigger tr_finish_delivery
    after update of time_delivered
    on Orders
    for each row
execute function fn_add_salary_bonus();

drop trigger if exists tr_restrict_promotion_giver_domain on Promotions cascade;
create trigger tr_restrict_promotion_giver_domain
    after update of giver_id or insert
    on Promotions
    for each row
execute function fn_restrict_promotion_giver_domain();

/**
  Promotion system TODO: this is work-in-progress
 */
create or replace function check_rule(rid integer, rtype promo_rule_t, rconfig jsonb, oid integer) returns boolean as
$$
declare
    order_record Orders % rowtype;
begin
    select * from Orders where id = oid into order_record;
    case rtype
        when 'ORDER_TOTAL'::promo_rule_t
            then return (select (rconfig ->> 'cutoff')::money from PromotionRules where PromotionRules.id = rid) <=
                        order_record.food_cost;
        when 'NTH_ORDER'::promo_rule_t then if (select (rconfig ->> 'domain') = 'restaurant') then
            return (select count(*) from Orders where Orders.rid = order_record.rid and Orders.cid = order_record.cid)
                =
                   (select (rconfig ->> 'n')::integer);
        elsif (select (rconfig ->> 'domain') = 'all') then
            return (select count(*) from Orders where Orders.cid = order_record.cid)
                =
                   (select (rconfig ->> 'n')::integer);
        end if;
        when 'INACTIVITY'::promo_rule_t then if (current_timestamp
                                                     - (select time_placed
                                                        from Orders
                                                        where Orders.cid = order_record.cid
                                                        order by time_placed desc offset 1
                                                        limit 1)
            > (select (rconfig ->> 'interval'))::interval) then
            return true;
                                             end if;
                                             return false;
        end case;
    return true;
end;
$$ language plpgsql;


create or replace function get_food_discount(aid integer, atype promo_action_t, aconfig jsonb, oid integer) returns money as
$$
declare
    order_record Orders % rowtype;
begin
    select * from Orders where id = oid into order_record;
    if (select (aconfig ->> 'type')) = 'fixed' then
        return (select (aconfig ->> 'amount')::money);
    elsif (select (aconfig ->> 'type')) = 'percent' then
        raise notice 'Action id: %, Amount: %', aid, (select (aconfig ->> 'amount')::float) * order_record.food_cost;
        return (select (aconfig ->> 'amount')::float) * order_record.food_cost;
    else
        return 0::money;
    end if;
end;
$$ language plpgsql;

create or replace function get_delivery_discount(aid integer, atype promo_action_t, aconfig jsonb, oid integer) returns money as
$$
declare
    order_record Orders % rowtype;
begin
    select * from Orders where id = oid into order_record;
    if (select (aconfig ->> 'type')) = 'fixed' then
        return (select (aconfig ->> 'amount')::money);
    elsif (select (aconfig ->> 'type')) = 'percent' then
        return (select (aconfig ->> 'amount')::float) * order_record.delivery_cost;
    else
        return 0::money;
    end if;
end;
$$ language plpgsql;

create or replace function fn_apply_promo() returns trigger as
$$
declare
    eligible_promo_record record;
    new_food_cost         money; -- food cost after discount
    new_delivery_cost     money; -- delivery cost after discount
begin
    select food_cost from Orders where id = new.id into new_food_cost;
    select delivery_cost from Orders where id = new.id into new_delivery_cost;

    if (select reward_points from Customers where id = new.cid) >= (select reward_cutoff from Constants) then
        new_delivery_cost = 0;
        update Customers set reward_points = reward_points - (select reward_cutoff from Constants) where id = new.cid;
        update Orders set remarks = concat(remarks, '[Reward points used] ') where id = new.id;

    end if;

    if new_food_cost < (select minimum_spend from Restaurants where id = new.rid) then
        raise exception 'Food cost is smaller than minimum spend.';
    end if;

    for eligible_promo_record in
        -- this CTE gets eligible promotions and calculates their discount amounts
        with PromotionDiscounts as (
            select (
                       case PromotionActions.atype
                           when 'FOOD_DISCOUNT' then
                               get_food_discount(PromotionActions.id, PromotionActions.atype, PromotionActions.config,
                                                 new.id)
                           when 'DELIVERY_DISCOUNT' then
                               get_delivery_discount(PromotionActions.id, PromotionActions.atype,
                                                     PromotionActions.config, new.id)
                           end)           as amount, -- the discount amount for of a promotion for a given order
                   PromotionActions.atype as atype,  -- the promotion action associated with the promotion
                   Promotions.id          as pid,
                   Promotions.promo_name  as pname
            from Promotions
                     join PromotionRules on Promotions.rule_id = PromotionRules.id
                     join PromotionActions on Promotions.action_id = PromotionActions.id
            where (select now()) between Promotions.start_time and Promotions.end_time     -- eligible time period
              and (Promotions.giver_id = new.rid or
                   exists(select 1 from Managers where Managers.id = Promotions.giver_id)) -- promotion domain eligibility check
              and check_rule(PromotionRules.id, PromotionRules.rtype, PromotionRules.config,
                             new.id) -- promotion rule eligibility check
        )
        select distinct on (atype) amount,
                                   atype,
                                   pid,
                                   pname
        from PromotionDiscounts
        order by atype, amount desc --gets maximum discount amount for each action type
        loop
            case eligible_promo_record.atype
                when 'FOOD_DISCOUNT' then if (new_food_cost <= 0::money) then continue; end if;
                                          new_food_cost = new_food_cost - eligible_promo_record.amount;
                when 'DELIVERY_DISCOUNT' then if (new_delivery_cost <= 0::money) then continue; end if;
                                              new_delivery_cost = new_delivery_cost - eligible_promo_record.amount;
                end case;
            update Promotions set num_orders = num_orders + 1 where id = eligible_promo_record.pid;
            update Orders set remarks = concat(remarks, '[', eligible_promo_record.pname, '] ') where id = new.id;
            raise notice 'Promotion [%] is applied to order [%]', eligible_promo_record.pid, new.id;
        end loop;

    update Orders set food_cost = new_food_cost, delivery_cost = new_delivery_cost where id = new.id;
    raise notice 'New food cost: %. New delivery cost: %', new_food_cost, new_delivery_cost;

    update Customers
    set reward_points = reward_points + new_food_cost::numeric
    where id = new.cid;
    return null;
end
$$ language plpgsql;

drop trigger if exists tr_apply_promo on Orders cascade;
create constraint trigger tr_apply_promo
    after insert
    on Orders
    deferrable initially deferred
    for each row
execute function fn_apply_promo();

create or replace function fn_calculate_delivery_fee() returns trigger as
$$
declare
    distance float;
    fee      float := 5;
begin
    select (point(new.lon, new.lat) <@> point(
                (select lon from Restaurants where id = new.rid),
                (select lon from Restaurants where id = new.rid)
        )) * 1609.344
    into distance;
    raise notice '%', distance;
    if (distance > 1000 and distance < 3000) then
        fee = fee + 2;
    else
        if (distance >= 3000 and distance < 5000) then
            fee = fee + 4;
        else
            if (distance >= 5000) then
                fee = fee + 7;
            end if;
        end if;
    end if;
    new.delivery_cost = fee;
    return new;
end;
$$ language plpgsql;

drop trigger if exists tr_calculate_delivery_fee on Orders cascade;
create trigger tr_calculate_delivery_fee
    before insert
    on Orders
    for each row
execute function fn_calculate_delivery_fee();

create or replace function fn_set_PWS() returns trigger as
$$
declare
    work_hours integer;
begin
    if (not exists (select 1 from Users where id = coalesce(new.rid, old.rid))) then return null;
    end if;

    select sum(end_hour - start_hour)
    into work_hours
    from PWS
    where PWS.rid = coalesce(new.rid, old.rid)
      and PWS.start_of_week = coalesce(new.start_of_week, old.start_of_week);

    if (work_hours > 48)
    then
        raise exception 'Work hours for the week exceed 48 hours';
    elsif (work_hours < 10 or work_hours is null)
    then
        raise exception 'Work hours for the week are less than 10 hours';
    end if;

    if (exists(select 1
               from Salaries
               where Salaries.rid = coalesce(new.rid, old.rid)
                 and Salaries.start_date = coalesce(new.start_of_week, old.start_of_week)))
    then
        update Salaries
        set base  = work_hours * 6,
            bonus = 0 -- base salary should be changed.
        where Salaries.rid = coalesce(new.rid, old.rid)
          and Salaries.start_date = coalesce(new.start_of_week, old.start_of_week);
        return null;
    end if;

    insert into Salaries
    values (new.rid, new.start_of_week, work_hours * 6, 0); -- $6 per hour

    return null;
end;
$$ language plpgsql;

/*
  Updates or inserts Salaries after a transaction on a PWS.
  Ensures sum of durations >= 10 and <= 48.
  Ensures single work time not exceed four hours.
 */
drop trigger if exists tr_set_PWS on PWS cascade;
create constraint trigger tr_set_PWS
    after update or insert or delete
    on PWS
    deferrable initially deferred
    for each row
execute function fn_set_PWS();

create or replace function fn_set_FWS() returns trigger as
$$
begin
    if (exists(select 1
               from Salaries
               where Salaries.rid = new.rid
                 and Salaries.start_date = new.start_date))
    then
        update Salaries
        set base  = 4 * 5 * 8,
            bonus = 0 -- base salary should be changed.
        where Salaries.rid = new.rid
          and Salaries.start_date = new.start_date;
        return null;
    end if;

    insert into Salaries
    values (new.rid, new.start_date, 160 * 8, 0); -- 160 work hours and $8 per hour.
    return null;
end;
$$ language plpgsql;

/*
  Updates or inserts Salaries when update or insert a FWS.
 */
drop trigger if exists tr_set_FWS on FWS cascade;
create trigger tr_set_FWS
    after update or insert
    on FWS
    for each row
execute function fn_set_FWS();

create or replace function fn_check_shifts() returns trigger as
$$
declare
    first_rest  integer := -1;
    second_rest integer := -1;
    third_rest  integer := -1; -- create a window sized 3.
    week_schedule integer[7];
begin
    week_schedule := array [new.day_one, new.day_two, new.day_three, new.day_four, new.day_five, new.day_six, new.day_seven];
    for counter in 1..7
        loop
            if (week_schedule[counter] = '0')
            then
                third_rest := second_rest;
                second_rest := first_rest;
                first_rest := counter;
                -- slide the rest day into the window.
            end if;
        end loop;

    if (third_rest <> -1 or second_rest = -1) then -- guarantees exact 5 working days
        raise exception 'Exact 5 working days are required in a week.';
    end if;
    if (first_rest - second_rest = 1 or first_rest - second_rest = 6) then -- guarantees consecutive working days
        return null;
    else
        raise exception '5 working days must be consecutive in a week.';
    end if;
end;
$$ language plpgsql;

drop trigger if exists tr_FWS_check_shifts on FWS cascade;
create trigger tr_FWS_check_shifts
    after update or insert
    on FWS
    for each row
execute function fn_check_shifts();
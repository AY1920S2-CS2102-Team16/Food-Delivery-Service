-- Get order total for the last 12 months for some restaurant, including months that do not have an order for that restaurant
with recursive MonthlyCalendar as (
    select CURRENT_TIMESTAMP as date
    union all
    select date - interval '1 month'
    from MonthlyCalendar
    where date > CURRENT_TIMESTAMP - interval '11 month'
)
select to_char(mc.date, 'YYYY-MM') as yearmonth, coalesce(sum(o.food_cost::numeric), 0::numeric) as total
from MonthlyCalendar mc
         left join Orders o
                   on to_char(o.time_placed, 'YYYY-MM') = to_char(mc.date, 'YYYY-MM') and o.rid = 'kfc'
group by to_char(mc.date, 'YYYY-MM')
order by yearmonth desc;

-- Fuzzy food search with filters
select food_name, food_category, rname
from Sells S
         join Restaurants R on S.rid = R.id
where food_category in ($catogory)
  and (select avg(S2.price::numeric) from Sells S2 where S2.rid = R.id) between $lower_price
  and $upper_price
  and SIMILARITY(food_name
    , $food_name)
    > 0.4
order by SIMILARITY(food_name, '') desc
    limit 20;

--
with recursive MonthlyCalendar as (
    select CURRENT_TIMESTAMP as date
    union all
    select date - interval '1 month'
    from MonthlyCalendar
    where date > CURRENT_TIMESTAMP - interval '11 month'
)
select to_char(mc.date, 'YYYY-MM')                                                as yearmonth,
       count(distinct c.id)                                                       as total_new_users,
       coalesce(sum(o.food_cost::numeric + o.delivery_cost::numeric), 0::numeric) as total_order_revenue,
       count(distinct o.id)                                                       as total_order_num
from MonthlyCalendar mc
         left join (Customers natural join Users) c
                   on to_char(c.join_date, 'YYYY-MM') = to_char(mc.date, 'YYYY-MM')
         left join Orders o
                   on to_char(o.time_placed, 'YYYY-MM') = to_char(mc.date, 'YYYY-MM')
group by to_char(mc.date, 'YYYY-MM')
order by yearmonth desc;

--
select c.id, count(distinct o.id) as total_order_num, sum(o.food_cost + o.delivery_cost) as total_spending
from Customers c
         join Orders o on c.id = o.cid and to_char(o.time_placed, 'YYYY-MM') = to_char(CURRENT_TIMESTAMP, 'YYYY-MM')
group by c.id
order by total_spending;


create or replace function fn_check_shifts() returns boolean as
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
                -- slide the day of rest into the window.
            end if;
        end loop;

    if (third_rest <> -1 or second_rest = -1) then -- guarantees exactly 5 working days
        return false;
    end if;
    if (first_rest - second_rest = 1 or first_rest - second_rest = 6) then -- guarantees consecutive working days
        return true;
    else
        return false;
    end if;
end;
$$ language plpgsql;

drop trigger if exists tr_FWS_check_shifts on FWS cascade;
create trigger tr_FWS_check_shifts
    after update or insert
    on FWS
    for each row
execute function fn_check_shifts();

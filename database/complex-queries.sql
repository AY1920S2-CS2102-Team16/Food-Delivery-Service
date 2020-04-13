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

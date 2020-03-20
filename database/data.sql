insert into Constants
values (
           '$2a$04$1wxM7b.ub1nIISNmhDU97e' -- salt
       );

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

insert into CustomerLocations (cid, lat, lon, address)
values ('alice', '1.11', '1.11', 'CAPT');
insert into CustomerCards (cid, number, expiry, name, cvv)
values ('alice', '1234-1234-1234-1234', '07/24', 'Alice Tan', '123');

insert into PromotionRules
values (1, 'ORDER_TOTAL', '{"cutoff": 10}');
insert into PromotionActions
values (1, 'FOOD_DISCOUNT', '{"discount": 10}');
insert into Promotions
values (1, '$5 off for orders above $20', 1, 1, '2000-1-1'::timestamp, '2029-1-1'::timestamp, 'kfc');

begin;
insert into Orders(cid, lon, lat, payment_mode, rid)
values ('alice', '1.11', '1.11', 'Cash', 'kfc');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Fries', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 1);
commit;

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
insert into Users
values ('mcdonalds', '123456', 'MCDONALDS');
insert into Restaurants
values ('mcdonalds', 'MCDONALDS', 'mcdonalds fast food restaurant', 'Avenue 2', 1.212300, 1.11231);
commit;

insert into Sells
values ('kfc', 'Fries', 'French fries', 'Fast food', 50, 0, 6);
insert into Sells
values ('mcdonalds', 'Fries', 'French fries', 'Fast food', 50, 0, 6);
insert into Sells
values ('mcdonalds', 'Big Mac', 'Signature Big Mac burger', 'Fast food', 50, 0, 6);
insert into Sells
values ('kfc', 'Cheese burger', 'Cheese burger', 'Fast food', 50, 0, 10);

insert into CustomerLocations (cid, lat, lon, address)
values ('alice', '1.11', '1.11', 'CAPT');
insert into CustomerCards (cid, number, expiry, name, cvv)
values ('alice', '1234-1234-1234-1234', '07/24', 'Alice Tan', '123');

insert into PromotionRules(giver_id, rtype, config) -- rule 1
values ('kfc', 'ORDER_TOTAL', '{"cutoff": 5}');
insert into PromotionRules(giver_id, rtype, config) -- rule 2
values ('kfc', 'ORDER_TOTAL', '{"cutoff": 10}');

insert into PromotionActions(giver_id, atype, config) -- action 1
values ('kfc', 'FOOD_DISCOUNT', '{"type": "fixed", "amount": "3"}');
insert into PromotionActions(giver_id, atype, config) -- action 2
values ('kfc', 'FOOD_DISCOUNT', '{"type": "fixed", "amount": "6"}');
insert into PromotionActions(giver_id, atype, config) -- action 3
values ('kfc', 'FOOD_DISCOUNT', '{"type": "percent", "amount": "0.4"}');
insert into PromotionActions(giver_id, atype, config) -- action 3
values ('kfc', 'DELIVERY_DISCOUNT', '{"type": "percent", "amount": "0.6"}');

insert into Promotions (promo_name, rule_id, action_id, start_time, end_time, giver_id)
values ('$6 off for orders above $10', 2, 2, '2000-1-1'::timestamp, '2029-1-1'::timestamp, 'kfc');

insert into Promotions (promo_name, rule_id, action_id, start_time, end_time, giver_id)
values ('40% off for orders above 10', 2, 3, '2000-1-1'::timestamp, '2029-1-1'::timestamp, 'kfc');

insert into Promotions (promo_name, rule_id, action_id, start_time, end_time, giver_id)
values ('$3 off for orders above $5', 1, 1, '2000-1-1'::timestamp, '2029-1-1'::timestamp, 'kfc');

begin;
insert into Orders(cid, lon, lat, payment_mode, rid)
values ('alice', '1.11', '1.11', 'Cash', 'kfc');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Fries', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 1);
commit;

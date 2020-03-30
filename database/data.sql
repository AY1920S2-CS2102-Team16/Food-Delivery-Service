insert into Constants
values ('$2a$04$1wxM7b.ub1nIISNmhDU97e', -- salt
        10);

begin;
insert into Users
values ('alice', '123456', 'Alice');
insert into Customers
values ('alice');
insert into Users
values ('kfc', '123456', 'KFC');
insert into Restaurants
values ('kfc', 'KFC', 'kfc fast food restaurant', 20, 'Avenue 1', 1.112300, 1.11231);
insert into Users
values ('mcdonalds', '123456', 'MCDONALDS');
insert into Restaurants
values ('mcdonalds', 'MCDONALDS', 'mcdonalds fast food restaurant', 20, 'Avenue 2', 1.212300, 1.11231);
insert into Users
values ('grabber', '123456', 'grabber', to_date('2020-03-29','YYYY-MM-DD'));
insert into Riders
values ('grabber', 'part_time');
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
values ('kfc', currval('orders_id_seq'), 'Fries', 10);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 10);
commit;

begin;
insert into PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
values ('grabber', to_date('2020-03-29', 'YYYY-MM-DD'), 0, 10, 12);
insert into PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
values ('grabber', to_date('2020-03-29', 'YYYY-MM-DD'), 1, 14, 15);
insert into PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
values ('grabber', to_date('2020-03-29', 'YYYY-MM-DD'), 2, 20, 22);
insert into PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
values ('grabber', to_date('2020-03-29', 'YYYY-MM-DD'), 3, 13, 15);
insert into PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
values ('grabber', to_date('2020-03-29', 'YYYY-MM-DD'), 3, 18, 22);
insert into PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
values ('grabber', to_date('2020-03-29', 'YYYY-MM-DD'), 4, 19, 21);
insert into PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
values ('grabber', to_date('2020-03-29', 'YYYY-MM-DD'), 5, 11, 15);
insert into PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
values ('grabber', to_date('2020-03-29', 'YYYY-MM-DD'), 5, 17, 20);
insert into PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
values ('grabber', to_date('2020-03-29', 'YYYY-MM-DD'), 6, 12, 16);
end;
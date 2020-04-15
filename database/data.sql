insert into Constants
values ('$2a$04$1wxM7b.ub1nIISNmhDU97e', -- salt
        30.0);

/*
 Users
 */
begin;
insert into Users
values ('alice', '123456', 'Alice');
insert into Customers
values ('alice');
insert into Users
values ('bob', '123456', 'Bob');
insert into Customers
values ('bob');

insert into Users
values ('kfc', '123456', 'KFC');
insert into Restaurants
values ('kfc', 'KFC', 'kfc fast food restaurant', 20, 'Avenue 1', 1.112300, 1.11231);

insert into Users
values ('mcdonalds', '123456', 'MCDONALDS');
insert into Restaurants
values ('mcdonalds', 'MCDONALDS', 'mcdonalds fast food restaurant', 20, 'Avenue 2', 1.212300, 1.11231);

insert into Users
values ('pizza-hut', '654321', 'PIZZA HUT');
insert into Restaurants
values ('pizza-hut', 'PIZZA HUT', 'a fast food restaurant that sells pizza', 27, '802 Bukit Batok West Ave 5', 1.3521,
        87.8198);

insert into Users
values ('grabber', '123456', 'grabber', to_date('2020-03-29', 'YYYY-MM-DD'));
insert into Riders
values ('grabber', 'part_time', 1, 1);
insert into Users
values ('rider', '123456', 'rider', to_date('2019-12-29', 'YYYY-MM-DD'));
insert into Riders
values ('rider', 'full_time', 1, 1);
insert into Users
values ('lightning', '123456', 'lightning', to_date('2019-03-29', 'YYYY-MM-DD'));
insert into Riders
values ('lightning', 'full_time', 1, 1);
insert into Users
values ('flash', '123456', 'flash', to_date('2020-03-29', 'YYYY-MM-DD'));
insert into Riders
values ('flash', 'full_time', 1, 1);
insert into Users
values ('manager1', '123456', 'manager1');
insert into Managers
values ('manager1');
commit;

insert into CustomerLocations (cid, lat, lon, address)
values ('alice', '1.11', '1.11', 'CAPT');
insert into CustomerLocations (cid, lat, lon, address)
values ('alice', '2.637', '20.373', '2 Linden Drive Singapore 288683');
insert into CustomerLocations (cid, lat, lon, address)
values ('alice', '38.374', '11.2736', '50 Jurong Gateway Rd Singapore 608549');
insert into CustomerLocations (cid, lat, lon, address)
values ('alice', '80.567', '37.28', '21 Lower Kent Ridge Rd Singapore 119077');
insert into CustomerCards (cid, number, expiry, name, cvv)
values ('alice', '1234-1234-1234-1234', '07/24', 'Alice Tan', '123');

insert into CustomerLocations (cid, lat, lon, address)
values ('bob', '1.35', '2.48', 'Zhong Nan Hai');

/*
 Sells
 */
insert into Sells
values ('kfc', 'Fries', 'French fries', 'Fast food', 50, 0, 6);
insert into Sells
values ('mcdonalds', 'Fries', 'French fries', 'Fast food', 50, 0, 6);
insert into Sells
values ('mcdonalds', 'Big Mac', 'Signature Big Mac burger', 'Fast food', 50, 0, 6);
insert into Sells
values ('kfc', 'Cheese burger', 'Cheese burger', 'Fast food', 50, 0, 10);

insert into Sells
values ('kfc', 'Curry Rice Bowl', 'Spicy food', 'Fast food', 40, 0, 5.35);
insert into Sells
values ('kfc', 'Original Recipe Rice Bowl', 'Customer favourite', 'Fast food', 35, 0, 5.40);

insert into Sells
values ('mcdonalds', 'Buttermilk crispy chicken', 'Creamy burger', 'Fast food', 200, 0, 6.55);
insert into Sells
values ('mcdonalds', 'Angus BLT', 'Beef burger', 'Fast food', 200, 0, 6.55);
insert into Sells
values ('mcdonalds', 'Orignal angus cheese burger', 'Beef burger', 'Fast food', 200, 0, 7.55);
insert into Sells
values ('mcdonalds', 'BBQ beef burger with egg', 'Beef burger', 'Fast food', 200, 0, 4.55);
insert into Sells
values ('mcdonalds', 'Cheeseburger', 'Beef burger', 'Fast food', 200, 0, 3.55);
insert into Sells
values ('mcdonalds', 'Double cheeseburger', 'Beef burger', 'Fast food', 200, 0, 4.55);

insert into Sells
values ('pizza-hut', 'Hawaiian', 'Classic Pizza', 'Fast food', 100, 0, 12.30);
insert into Sells
values ('pizza-hut', 'Meat Galore', 'Classic Pizza', 'Fast food', 100, 0, 12.30);
insert into Sells
values ('pizza-hut', 'Super Supreme', 'Classic Pizza', 'Fast food', 100, 0, 12.30);
insert into Sells
values ('pizza-hut', 'Pepperoni', 'Classic Pizza', 'Fast food', 100, 0, 12.30);
insert into Sells
values ('pizza-hut', 'Curry Chicken', 'Classic Pizza', 'Fast food', 100, 0, 12.30);
insert into Sells
values ('pizza-hut', 'Chicken Supreme', 'Classic Pizza', 'Fast food', 100, 0, 12.30);

/*
  Promotions
 */
insert into PromotionRules(giver_id, rtype, config)
values ('kfc', 'ORDER_TOTAL', '{"cutoff": 20}'),     -- rule 1
       ('kfc', 'ORDER_TOTAL', '{"cutoff": 30}'),     -- rule 2
       ('manager1', 'ORDER_TOTAL', '{"cutoff": 2}'), -- rule 3
       ('manager1', 'NTH_ORDER', '{"domain": "all", "n": 1}'); -- rule 4

insert into PromotionActions(giver_id, atype, config)
values ('kfc', 'FOOD_DISCOUNT', '{"type": "fixed", "amount": "3"}'),         -- action 1
       ('kfc', 'FOOD_DISCOUNT', '{"type": "fixed", "amount": "5"}'),         -- action 2
       ('kfc', 'DELIVERY_DISCOUNT', '{"type": "percent", "amount": "0.6"}'), -- action 3
       ('manager1', 'FOOD_DISCOUNT', '{"type": "percent", "amount": "0.5"}'); -- action 4


insert into Promotions (promo_name, rule_id, action_id, start_time, end_time, giver_id)
values ('$3 off for orders above $20', 1, 1, '2000-1-1'::timestamp, '2029-1-1'::timestamp, 'kfc'),
       ('$5 off for orders above $30', 2, 2, '2000-1-1'::timestamp, '2029-1-1'::timestamp, 'kfc'),
       ('60% off delivery fee for orders above $30', 2, 3, '2000-1-1'::timestamp, '2029-1-1'::timestamp, 'kfc'),
       ('50% off for new user', 4, 4, '2000-1-1'::timestamp, '2029-1-1'::timestamp, 'manager1');

/*
 Schedule
 */
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

begin;
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
VALUES ('grabber', date '2020-04-05', 2, 10, 14);
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
VALUES ('grabber', date '2020-04-05', 2, 15, 19);
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
VALUES ('grabber', date '2020-04-05', 2, 20, 22);
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
VALUES ('grabber', date '2020-04-05', 3, 14, 18);
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
VALUES ('grabber', date '2020-04-05', 3, 19, 22);
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
VALUES ('grabber', date '2020-04-05', 4, 12, 16);
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour)
VALUES ('grabber', date '2020-04-05', 5, 10, 14);
end;

begin;
insert into FWS
values ('rider', date '2019-12-29', '0', '0', '4', '4', '4', '3', '4');
insert into FWS
values ('rider', date '2020-01-26', '4', '4', '4', '3', '4', '0', '0');
insert into FWS
values ('rider', date '2020-02-23', '4', '4', '4', '3', '4', '0', '0');
insert into FWS
values ('rider', date '2020-03-22', '4', '4', '4', '3', '4', '0', '0');

insert into FWS
values ('lightning', date '2020-03-22', '0', '0', '3', '4', '3', '4', '2');
insert into FWS
values ('flash', date '2020-03-22', '3', '1', '0', '0', '2', '3', '4');
end;

/*
 Orders
 */
begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid)
values ('alice',
        '1.11',
        '1.11',
        'Cash',
        'kfc',
        date '2020-12-30',
        date '2020-12-30',
        date '2020-12-30',
        date '2020-12-30',
        date '2020-12-30');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Fries', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 2);
commit;



begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid)
values ('alice',
        '11.2736',
        '38.374',
        'Cash',
        'pizza-hut',
        '2020-01-24T16:55:50.459+08:00',
        '2020-01-24T16:55:50.459+08:00',
        '2020-01-24T16:55:50.459+08:00',
        '2020-01-24T16:55:50.459+08:00',
        '2020-01-24T16:55:50.459+08:00');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Hawaiian', 2);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Super Supreme', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Pepperoni', 1);
commit;
begin;
update Orders
set time_delivered = '2020-01-24T17:03:50.459+08:00'
where id = 2;
commit;

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid)
values ('alice',
        '11.2736',
        '38.374',
        'Card',
        'kfc',
        '2020-01-24T18:55:50.459+08:00',
        '2020-01-24T18:55:50.459+08:00',
        '2020-01-24T18:55:50.459+08:00',
        '2020-01-24T18:55:50.459+08:00',
        '2020-01-24T18:55:50.459+08:00');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 3);
commit;
begin;
update Orders
set time_delivered = '2019-01-24T19:59:50.459+08:00'
where id = 3;
commit;

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid)
values ('alice',
        '11.2736',
        '38.374',
        'Card',
        'kfc',
        '2020-04-17T18:55:50.459+08:00',
        '2020-04-17T18:55:50.459+08:00',
        '2020-04-17T18:55:50.459+08:00',
        '2020-04-17T18:55:50.459+08:00',
        '2020-04-17T18:55:50.459+08:00');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 6);
commit;
begin;
update Orders
set time_delivered = '2019-04-17T19:55:50.459+08:00'
where id = 4;
commit;

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid)
values ('alice',
        '11.2736',
        '38.374',
        'Card',
        'kfc',
        '2020-01-03T18:55:50.459+08:00',
        '2020-01-03T18:55:50.459+08:00',
        '2020-01-03T18:55:50.459+08:00',
        '2020-01-03T18:55:50.459+08:00',
        '2020-01-03T18:55:50.459+08:00');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 4);
commit;
begin;
update Orders
set time_delivered = '2020-01-03T19:58:50.459+08:00'
where id = 5;
commit;

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid)
values ('alice', '11.2736', '38.374', 'Card', 'kfc', '2020-01-03T18:55:50.459+08:00', '2020-03-03T18:55:50.459+08:00',
        '2020-03-03T18:55:50.459+08:00', '2020-03-03T18:55:50.459+08:00', '2020-03-03T18:55:50.459+08:00');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 6);
commit;
begin;
update Orders
set time_delivered = '2020-03-03T20:15:30.459+08:00'
where id = 6;
commit;

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid)
values ('alice', '11.2736', '38.374', 'Card', 'kfc', '2020-01-27T18:55:50.459+08:00', '2020-01-27T18:55:50.459+08:00',
        '2020-01-27T18:55:50.459+08:00', '2020-01-27T18:55:50.459+08:00', '2020-01-27T18:55:50.459+08:00');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 5);
commit;
begin;
update Orders
set time_delivered = '2020-01-27T19:55:50.459+08:00'
where id = 7;
commit;

begin; --8
insert into Orders(cid, lon, lat, payment_mode, rid, time_paid)
values ('bob', '2.48', '1.35', 'Cash', 'mcdonalds', null);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Big Mac', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Buttermilk crispy chicken', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Angus BLT', 2);
commit;

begin; -- 9
insert into Orders(cid, lon, lat, payment_mode, rid, time_paid)
values ('bob', '2.48', '1.35', 'Cash', 'mcdonalds', null);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Fries', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Big Mac', 2);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Angus BLT', 1);
commit;

begin; -- 10
insert into Orders(cid, lon, lat, payment_mode, rid, time_paid)
values ('bob', '2.48', '1.35', 'Cash', 'pizza-hut', null);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Meat Galore', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Super Supreme', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Chicken Supreme', 1);
commit;

/*
 Reviews
 */
begin;
insert into Reviews (content, rating, oid)
values ('Chicken is amazing', '5', '4'),
       ('Delivery is too slow. Food is quite good.', '3', '3'),
       ('McSpicy is absolutely amazing', '5', '8'),
       ('Fries are a bit cold', '1', '9'),
       ('Pepperroni pizza is amazing', '1', '10');
commit;


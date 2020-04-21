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
values ('mcdonalds', '123456', 'McDonalds');
insert into Restaurants
values ('mcdonalds', 'MCDONALDS', 'mcdonalds fast food restaurant', 20, 'Avenue 2', 1.212300, 1.11231);

insert into Users
values ('pizza-hut', '123456', 'Pizza Hut');
insert into Restaurants
values ('pizza-hut', 'Pizza Hut', 'We offer amazing pizzas.', 27, '802 Bukit Batok West Ave 5', 1.3521,
        87.8198);

insert into Users
values ('sichuan', '123456', 'Sichuan Restaurant');
insert into Restaurants
values ('sichuan', 'Sichuan Restaurant', 'Spicy Sichuan style food', 27, '802 Bukit Batok West Ave 5', 1.3521,
        87.80);

insert into Users
values ('grabber', '123456', 'grabber', to_date('2020-03-29', 'YYYY-MM-DD'));
insert into Riders
values ('grabber', 'part_time', 1, 1);
insert into Users
values ('rider', '123456', 'rider', to_date('2019-12-29', 'YYYY-MM-DD'));
insert into Riders
values ('rider', 'full_time', 1.1, 1.1);
insert into Users
values ('lightning', '123456', 'lightning', to_date('2019-03-29', 'YYYY-MM-DD'));
insert into Riders
values ('lightning', 'full_time', 1, 1);
insert into Users
values ('flash', '123456', 'flash', to_date('2020-03-29', 'YYYY-MM-DD'));
insert into Riders
values ('flash', 'full_time', 1, 1);
insert into Users
values ('wind', '123456', 'wind', to_date('2020-04-15', 'YYYY-MM-DD'));
insert into Riders
values ('wind', 'full_time', 1, 1);
insert into Users
values ('motor', '123456', 'motor', to_date('2020-04-15', 'YYYY-MM-DD'));
insert into Riders
values ('motor', 'full_time', 1, 1);
insert into Users
values ('driver', '123456', 'driver', to_date('2020-04-15', 'YYYY-MM-DD'));
insert into Riders
values ('driver', 'full_time', 1, 1);


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
values ('pizza-hut', 'Hawaiian', 'Classic Pizza', 'Western', 100, 0, 12.30);
insert into Sells
values ('pizza-hut', 'Meat Galore', 'Classic Pizza', 'Western', 100, 0, 12.30);
insert into Sells
values ('pizza-hut', 'Super Supreme', 'Classic Pizza', 'Western', 100, 0, 12.30);
insert into Sells
values ('pizza-hut', 'Pepperoni', 'Classic Pizza', 'Western', 100, 0, 12.30);
insert into Sells
values ('pizza-hut', 'Curry Chicken', 'Classic Pizza', 'Western', 100, 0, 12.30);
insert into Sells
values ('pizza-hut', 'Chicken Supreme', 'Classic Pizza', 'Western', 100, 0, 12.30);

insert into Sells
values ('sichuan', 'Mapo Tofu', 'Tofu served in a chili-and-bean-based sauce', 'Chinese', 100, 0, 12);
insert into Sells
values ('sichuan', 'Kung Pao Chicken', 'Fried diced chicken with dry red pepper and golden peanuts', 'Chinese', 100, 0,
        14);
insert into Sells
values ('sichuan', 'Sichuan Hot Pot', 'Spicy hotpot', 'Chinese', 100, 0, 50);
insert into Sells
values ('sichuan', 'Dandan Mian', 'Savoury, nutty, spicy, and smoky noodles', 'Chinese', 100, 0, 12.30);
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
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour) VALUES ('grabber', date '2020-04-19', 0, 20, 22);
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour) VALUES ('grabber', date '2020-04-19', 1, 21, 22);
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour) VALUES ('grabber', date '2020-04-19', 2, 19, 22);
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour) VALUES ('grabber', date '2020-04-19', 3, 10, 14);
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour) VALUES ('grabber', date '2020-04-19', 5, 10, 14);
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour) VALUES ('grabber', date '2020-04-19', 5, 18, 20);
INSERT INTO PWS(rid, start_of_week, day_of_week, start_hour, end_hour) VALUES ('grabber', date '2020-04-19', 6, 20, 22);
commit;
-- demo use


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
values ('rider', date '2020-04-19', '1', '2', '3', '1', '2', '0', '0'); -- demo use

insert into FWS
values ('lightning', date '2020-03-27', '2', '2', '2', '0', '0', '1', '1'); -- demo use

insert into FWS
values ('flash', date '2020-03-29', '3', '3', '4', '1', '0', '0', '1'); -- demo use

insert into FWS
values ('wind', date '2020-04-15', '1', '1', '1', '2', '2', '0', '0'); -- demo use

insert into FWS
values ('motor', date '2020-04-15', '1', '3', '4', '4', '0', '0', '1'); -- demo use

insert into FWS
values ('driver', date '2020-04-15', '1', '0', '0', '4', '2', '3', '4'); -- demo use
end;

/*
 Orders
 */

-- insert into
-- Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid, time_delivered)

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid, rider_id)
values ('alice',
        '1.11',
        '1.11',
        'Cash',
        'kfc',
        '2019-12-31T13:55:50.459+08:00',
        '2019-12-31T14:00:50.459+08:00',
        '2019-12-31T14:10:50.459+08:00',
        '2019-12-31T14:25:50.459+08:00',
        '2019-12-31T14:36:50.459+08:00',
        'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Fries', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 2);
commit;
begin;
update Orders
set time_delivered = '2019-12-31T14:37:50.459+08:00'
where id = 1;
commit;

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid, rider_id)
values ('bob',
        '2.48',
        '1.35',
        'Cash',
        'kfc',
        '2019-12-31T14:55:50.459+08:00',
        '2019-12-31T15:00:50.459+08:00',
        '2019-12-31T15:10:50.459+08:00',
        '2019-12-31T15:25:50.459+08:00',
        '2019-12-31T15:36:50.459+08:00',
        'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Fries', 2);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 3);
commit;
begin;
update Orders
set time_delivered = '2019-12-31T15:37:50.459+08:00'
where id = 2;
commit;


begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid, rider_id)
values ('alice',
        '11.2736',
        '38.374',
        'Cash',
        'pizza-hut',
        '2020-01-24T12:55:50.459+08:00',
        '2020-01-24T13:00:50.459+08:00',
        '2020-01-24T13:10:50.459+08:00',
        '2020-01-24T13:30:50.459+08:00',
        '2020-01-24T13:43:50.459+08:00',
        'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Hawaiian', 2);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Super Supreme', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Pepperoni', 1);
commit;
begin;
update Orders
set time_delivered = '2020-01-24T13:45:50.459+08:00'
where id = 3;
commit;

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid, rider_id)
values ('bob',
        '2.48',
        '1.35',
        'Cash',
        'pizza-hut',
        '2020-01-24T13:55:50.459+08:00',
        '2020-01-24T14:00:50.459+08:00',
        '2020-01-24T14:10:50.459+08:00',
        '2020-01-24T14:30:50.459+08:00',
        '2020-01-24T14:43:50.459+08:00',
        'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Hawaiian', 2);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Super Supreme', 2);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Pepperoni', 3);
commit;
begin;
update Orders
set time_delivered = '2020-01-24T14:45:50.459+08:00'
where id = 4;
commit;

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid, rider_id)
values ('alice',
        '11.2736',
        '38.374',
        'Card',
        'kfc',
        '2020-01-24T18:10:50.459+08:00',
        '2020-01-24T18:15:50.459+08:00',
        '2020-01-24T18:26:50.459+08:00',
        '2020-01-24T18:46:50.459+08:00',
        '2020-01-24T19:00:50.459+08:00',
        'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 3);
commit;
begin;
update Orders
set time_delivered = '2020-01-24T19:01:50.459+08:00'
where id = 5;
commit;

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid, rider_id)
values ('alice',
        '11.2736',
        '38.374',
        'Card',
        'kfc',
        '2020-04-16T18:12:50.459+08:00',
        '2020-04-16T18:20:50.459+08:00',
        '2020-04-16T18:30:50.459+08:00',
        '2020-04-16T18:46:50.459+08:00',
        '2020-04-16T18:59:50.459+08:00',
        'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 6);
commit;
begin;
update Orders
set time_delivered = '2020-04-16T19:00:50.459+08:00'
where id = 6;
commit;

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid, rider_id)
values ('alice',
        '11.2736',
        '38.374',
        'Card',
        'kfc',
        '2020-01-03T20:02:50.459+08:00',
        '2020-01-03T20:10:50.459+08:00',
        '2020-01-03T20:32:50.459+08:00',
        '2020-01-03T20:45:50.459+08:00',
        '2020-01-03T20:56:50.459+08:00',
        'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 4);
commit;
begin;
update Orders
set time_delivered = '2020-01-03T20:58:50.459+08:00'
where id = 7;
commit;

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid, rider_id)
values ('alice', '11.2736', '38.374', 'Card', 'kfc', '2020-03-03T18:00:50.459+08:00', '2020-03-03T18:05:50.459+08:00',
        '2020-03-03T18:20:50.459+08:00', '2020-03-03T18:40:50.459+08:00', '2020-03-03T18:54:50.459+08:00', 'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 7);
commit;
begin;
update Orders
set time_delivered = '2020-03-03T18:56:30.459+08:00'
where id = 8;
commit;

begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid, rider_id)
values ('alice', '11.2736', '38.374', 'Card', 'kfc', '2020-01-27T18:55:50.459+08:00', '2020-01-27T19:00:50.459+08:00',
        '2020-01-27T19:10:50.459+08:00', '2020-01-27T19:25:50.459+08:00', '2020-01-27T19:40:50.459+08:00', 'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 5);
commit;
begin;
update Orders
set time_delivered = '2020-01-27T19:42:50.459+08:00'
where id = 9;
commit;

begin; --10
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_paid, rider_id)
values ('bob', '2.48', '1.35', 'Cash', 'mcdonalds',
'2020-04-02T19:00:50.459+08:00', '2020-04-02T19:45:50.459+08:00', 'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Big Mac', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Buttermilk crispy chicken', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Angus BLT', 2);
commit;
begin;
update Orders
set time_delivered = '2020-04-02T19:46:50.459+08:00'
where id = 10;
commit;

begin; -- 11
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_paid, rider_id)
values ('bob', '2.48', '1.35', 'Cash', 'mcdonalds',
'2020-04-02T20:00:50.459+08:00', '2020-04-02T20:45:50.459+08:00', 'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Fries', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Big Mac', 2);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Angus BLT', 1);
commit;
begin;
update Orders
set time_delivered = '2020-04-02T20:46:50.459+08:00'
where id = 11;
commit;

begin; -- 12
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_paid, rider_id)
values ('bob', '2.48', '1.35', 'Cash', 'pizza-hut',
'2020-04-02T13:00:50.459+08:00', '2020-04-02T13:45:50.459+08:00', 'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Meat Galore', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Super Supreme', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Chicken Supreme', 1);
commit;
begin;
update Orders
set time_delivered = '2020-04-02T13:46:50.459+08:00'
where id = 12;
commit;

begin; -- 13
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_paid, rider_id)
values ('bob', '2.48', '1.35', 'Cash', 'pizza-hut',
'2020-04-19T12:00:50.459+08:00', '2020-04-19T12:45:50.459+08:00', 'rider');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Meat Galore', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Super Supreme', 2);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Chicken Supreme', 3);
commit;
begin;
update Orders
set time_delivered = '2020-04-19T12:46:50.459+08:00'
where id = 13;
commit;

begin; -- 14
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_paid, rider_id)
values ('bob', '2.48', '1.35', 'Cash', 'pizza-hut',
'2020-03-27T12:00:50.459+08:00', '2020-03-27T12:45:50.459+08:00', 'lightning');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Meat Galore', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Super Supreme', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('pizza-hut', currval('orders_id_seq'), 'Chicken Supreme', 1);
commit;
begin;
update Orders
set time_delivered = '2020-03-27T12:46:50.459+08:00'
where id = 14;
commit;

begin; -- 15
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid, rider_id)
values ('alice', '11.2736', '38.374', 'Card', 'kfc', '2020-03-29T18:00:50.459+08:00', '2020-03-29T18:05:50.459+08:00',
        '2020-03-29T18:20:50.459+08:00', '2020-03-29T18:40:50.459+08:00', '2020-03-29T18:54:50.459+08:00', 'flash');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('kfc', currval('orders_id_seq'), 'Cheese burger', 6);
commit;
begin;
update Orders
set time_delivered = '2020-03-29T18:56:30.459+08:00'
where id = 15;
commit;

begin; --16
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_paid, rider_id)
values ('bob', '2.48', '1.35', 'Cash', 'mcdonalds',
'2020-04-15T19:00:50.459+08:00', '2020-04-15T19:45:50.459+08:00', 'wind');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Big Mac', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Buttermilk crispy chicken', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Angus BLT', 2);
commit;
begin;
update Orders
set time_delivered = '2020-04-15T19:46:50.459+08:00'
where id = 16;
commit;

begin; --17
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_paid, rider_id)
values ('bob', '2.48', '1.35', 'Cash', 'mcdonalds',
'2020-04-16T19:00:50.459+08:00', '2020-04-16T19:45:50.459+08:00', 'motor');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Big Mac', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Buttermilk crispy chicken', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Angus BLT', 2);
commit;
begin;
update Orders
set time_delivered = '2020-04-16T19:46:50.459+08:00'
where id = 17;
commit;

begin; --18
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_paid, rider_id)
values ('bob', '2.48', '1.35', 'Cash', 'mcdonalds',
'2020-04-20T19:00:50.459+08:00', '2020-04-20T19:45:50.459+08:00', 'driver');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Big Mac', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Buttermilk crispy chicken', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Angus BLT', 2);
commit;
begin;
update Orders
set time_delivered = '2020-04-20T19:46:50.459+08:00'
where id = 18;
commit;

begin; --19
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_paid, rider_id)
values ('bob', '2.48', '1.35', 'Cash', 'mcdonalds',
'2020-04-21T19:00:50.459+08:00', '2020-04-21T19:45:50.459+08:00', 'grabber');
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Big Mac', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Buttermilk crispy chicken', 1);
insert into OrderFoods(rid, oid, food_name, quantity)
values ('mcdonalds', currval('orders_id_seq'), 'Angus BLT', 2);
commit;
begin;
update Orders
set time_delivered = '2020-04-21T19:46:50.459+08:00'
where id = 19;
commit;

/*
 Reviews
 */
begin;
insert into Reviews (content, rating, oid)
values ('Very impressing taste!', '5', '1'),
       ('The food is good but a bit cold', '4', '2'),
       ('Delivery is too slow. Food is quite good.', '3', '3'),
       ('Pepperroni pizza is amazing', '5', '4'),
       ('Cheese burger is classic and awesome', '4', '5'),
       ('Food tastes ok while the delivery took a bit long time', '3', '6'),
       ('I would like a Big Mac instead next time. Good food!', '4', '7'),
       ('McSpicy is absolutely amazing', '5', '8'),
       ('The burger is a bit cold', '3', '9'),
       ('Buttermilk crispy chicken is so delicious! Impressing!', '4', '10'),
       ('Angus BLT is not as good as those showed in ad', '3', '11'),
       ('The chicken is very juicy and fresh!', '4', '12'),
       ('Very Nice food!', '5', '13'),
       ('Meat Galore tastes really good. Recommend!', '5', '14'),
       ('Just a normal cheese burger..', '4', '15'),
       ('Big Mac is so value. Good meal!', '5', '16'),
       ('Buttermilk crispy chicken is not crispy', '4', '17'),
       ('Angus BLT has good flavour. Tomato is fresh.', '5', '18'),
       ('Burgers are impressing! Nice', '4', '19');
commit;


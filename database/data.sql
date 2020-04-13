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
-- insert into Sells
-- values ('kfc', 'Famous Potato Bowl', 'Very famous', 'Fast food', 20, 0, 6.20);
-- insert into Sells
-- values ('kfc', 'Egg Tarts', 'Creamy egg custard in flaky pastry', 'Fast food', 25, 0, 3.20);
-- insert into Sells
-- values ('kfc', 'Snack N Share Box', 'Has tenders and nuggets', 'Fast food', 20, 0, 12.95);
-- insert into Sells
-- values ('kfc', 'Popcorn Chicken', 'Golden bite-size chicken pieces', 'Fast food', 25, 0, 4.70);
-- insert into Sells
-- values ('kfc', 'Cheese fries', 'Creamy jalapeno cheese with thick cut fries topped with mayonnaise', 'Fast food', 20, 0, 4.80);
-- insert into Sells
-- values ('kfc', 'Whipped potato', 'A truly classic KFC side. It is soft and fluffy with rich gravy', 'Fast food', 40, 0, 3.50);
-- insert into Sells
-- values ('kfc', 'Coleslaw', 'A perfect compliment to your meal', 'Fast food', 10, 0, 4.70);
-- insert into Sells
-- values ('kfc', 'Cheese sauce', 'Best dipping sauce ever', 'Fast food', 50, 0, 1.50);
-- insert into Sells
-- values ('kfc', 'Curry sauce', 'Great with fries and chicken', 'Fast food', 50, 0, 1.00);
-- insert into Sells
-- values ('kfc', 'Sour cream and onion sauce', 'Pairs well with tenders and other sides', 'Fast food', 50, 0, 0.30);
-- insert into Sells
-- values ('kfc', 'Pepsi', 'A refreshing drink to wash down your food', 'Fast food', 100, 0, 2.85);
-- insert into Sells
-- values ('kfc', 'Sjora Mango Peach', 'A premium, refreshing drink made from a blend of milk, mango and peach', 'Fast food', 90, 0, 3.80);
-- insert into Sells
-- values ('kfc', 'Mineral Water', 'Hydrated with water boosted with various minerals', 'Fast food', 30, 0, 2.40);
-- insert into Sells
-- values ('kfc', 'Chipotle Melt', 'Original recipe with chicken pieces, BBQ nachos and sliced tomatoes', 'Fast food', 60, 0, 6.35);
-- insert into Sells
-- values ('kfc', 'Cheesy Zinger Stacker', 'A formidable stacker for Zinger fans', 'Fast food', 200, 0, 7.25);
-- insert into Sells
-- values ('kfc', 'Zinger', 'World famous spicy chicken sandwich', 'Fast food', 150, 0, 5.35);
-- insert into Sells
-- values ('kfc', 'BBQ pockett', 'Juicy chicken fillet marinated in signature hot and spicy sauce', 'Fast food', 200, 0, 5.35);
-- insert into Sells
-- values ('kfc', 'Original Recipe Chicken', 'The classic chicken. Original from KFC', 'Fast food', 500, 0, 3.55);
-- insert into Sells
-- values ('kfc', 'Hot and crispy chicken', 'Every spice lovers favourite', 'Fast food', 250, 0, 3.55);
-- insert into Sells
-- values ('kfc', 'Buddy meal', 'Great for sharing', 'Fast food', 310, 0, 22.45);

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
-- insert into Sells
-- values ('mcdonalds', 'Hamburger', 'Beef burger', 'Fast food', 200, 0, 2.55);
-- insert into Sells
-- values ('mcdonalds', 'McChicken', 'Chicken burger', 'Fast food', 200, 0, 3.55);
-- insert into Sells
-- values ('mcdonalds', 'McSpicy', 'Chicken burger', 'Fast food', 200, 0, 3.55);
-- insert into Sells
-- values ('mcdonalds', 'Double McSpicy', 'Chicken burger', 'Fast food', 200, 0, 6.55);
-- insert into Sells
-- values ('mcdonalds', 'Garden side salad', 'Salad', 'Fast food', 200, 0, 3.55);
-- insert into Sells
-- values ('mcdonalds', 'Grilled chicken salad', 'Salad', 'Fast food', 200, 0, 4.35);
-- insert into Sells
-- values ('mcdonalds', 'Grilled chicken McWrap', 'Wrap', 'Fast food', 300, 0, 2.90);
-- insert into Sells
-- values ('mcdonalds', 'Filet-O-Fish', 'Fish burger', 'Fast food', 200, 0, 4.65);
-- insert into Sells
-- values ('mcdonalds', 'Double Filet-O-Fish', 'Fish burger', 'Fast food', 200, 0, 7.65);
-- insert into Sells
-- values ('mcdonalds', 'Apple pie', 'Sides', 'Fast food', 200, 0, 3.65);
-- insert into Sells
-- values ('mcdonalds', 'Corn cup', 'Sides', 'Fast food', 200, 0, 1.65);
-- insert into Sells
-- values ('mcdonalds', 'Apple slices', 'Sides', 'Fast food', 200, 0, 1.45);
-- insert into Sells
-- values ('mcdonalds', 'Coca-Cola', 'Drinks', 'Fast food', 100, 0, 1.70);
-- insert into Sells
-- values ('mcdonalds', 'Hot milo', 'Drinks', 'Fast food', 100, 0, 1.70);
-- insert into Sells
-- values ('mcdonalds', 'Hot tea', 'Drinks', 'Fast food', 100, 0, 1.20);
-- insert into Sells
-- values ('mcdonalds', 'Iced lemon tea', 'Drinks', 'Fast food', 100, 0, 1.70);
-- insert into Sells
-- values ('mcdonalds', 'Ice Milo', 'Drinks', 'Fast food', 100, 0, 1.60);
-- insert into Sells
-- values ('mcdonalds', 'Jasmine Green Tea', 'Drinks', 'Fast food', 100, 0, 1.50);
-- insert into Sells
-- values ('mcdonalds', 'Ribena', 'Drinks', 'Fast food', 100, 0, 1.30);
-- insert into Sells
-- values ('mcdonalds', 'Sprite', 'Drinks', 'Fast food', 100, 0, 1.70);
-- insert into Sells
-- values ('mcdonalds', 'Chocolate Shake', 'Drinks', 'Fast food', 100, 0, 1.90);
-- insert into Sells
-- values ('mcdonalds', 'Strawberry Shake', 'Drinks', 'Fast food', 100, 0, 1.90);
-- insert into Sells
-- values ('mcdonalds', 'Vanilla Shake', 'Drinks', 'Fast food', 100, 0, 1.90);
-- insert into Sells
-- values ('mcdonalds', 'Banana Shake', 'Drinks', 'Fast food', 100, 0, 1.90);
-- insert into Sells
-- values ('mcdonalds', 'Oreo Shake', 'Drinks', 'Fast food', 100, 0, 1.90);
-- insert into Sells
-- values ('mcdonalds', 'Hot Fudge Sundae', 'Desert', 'Fast food', 100, 0, 1.00);
-- insert into Sells
-- values ('mcdonalds', 'Strawberry Sundae', 'Desert', 'Fast food', 100, 0, 1.00);
-- insert into Sells
-- values ('mcdonalds', 'Blueberry Sundae', 'Desert', 'Fast food', 100, 0, 1.00);
-- insert into Sells
-- values ('mcdonalds', 'Banana Sundae', 'Desert', 'Fast food', 100, 0, 1.00);
-- insert into Sells
-- values ('mcdonalds', 'Mango Sundae', 'Desert', 'Fast food', 100, 0, 1.00);
-- insert into Sells
-- values ('mcdonalds', 'Choco Cone', 'Desert', 'Fast food', 100, 0, 1.20);
-- insert into Sells
-- values ('mcdonalds', 'Mudpie McFlurry', 'Desert', 'Fast food', 100, 0, 2.50);
-- insert into Sells
-- values ('mcdonalds', 'Strawberry Shortcake McFlurry', 'Desert', 'Fast food', 100, 0, 2.50);
-- insert into Sells
-- values ('mcdonalds', 'Oero McFlurry', 'Desert', 'Fast food', 100, 0, 2.50);
-- insert into Sells
-- values ('mcdonalds', 'Chicken Muffin', 'Breakfast burger', 'Fast food', 100, 0, 5.60);
-- insert into Sells
-- values ('mcdonalds', 'Egg McMuffin', 'Breakfast burger', 'Fast food', 100, 0, 5.40);
-- insert into Sells
-- values ('mcdonalds', 'Sausage McMuffin', 'Breakfast burger', 'Fast food', 100, 0, 5.60);
-- insert into Sells
-- values ('mcdonalds', 'Sausage McMuffin with egg', 'Breakfast burger', 'Fast food', 100, 0, 6.60);
-- insert into Sells
-- values ('mcdonalds', 'Chicken Muffin with egg', 'Breakfast burger', 'Fast food', 100, 0, 6.60);
-- insert into Sells
-- values ('mcdonalds', 'Hotcakes', 'Pancakes', 'Fast food', 100, 0, 5.90);
-- insert into Sells
-- values ('mcdonalds', 'Hotcakes with Sausage', 'Pancakes', 'Fast food', 100, 0, 6.90);
-- insert into Sells
-- values ('mcdonalds', 'Breakfast Wrap Chicken Sausage', 'Breakfast wrap', 'Fast food', 100, 0, 5.60);
-- insert into Sells
-- values ('mcdonalds', 'Breakfast Wrap Chicken Ham', 'Breakfast wrap', 'Fast food', 100, 0, 5.60);
-- insert into Sells
-- values ('mcdonalds', 'Hashbrown', 'Sides', 'Fast food', 100, 0, 2.60);
-- insert into Sells
-- values ('mcdonalds', 'Chicken McNuggets Happy Meal', 'Happy meal', 'Fast food', 100, 0, 4.70);
-- insert into Sells
-- values ('mcdonalds', 'Hotcakes Happy Meal', 'Happy meal', 'Fast food', 100, 0, 4.80);

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
-- insert into Sells
-- values ('pizza-hut', 'Veggie Lovers', 'Classic Pizza', 'Fast food', 100, 0, 12.30);
-- insert into Sells
-- values ('pizza-hut', 'Margherita', 'Classic Pizza', 'Fast food', 100, 0, 12.30);
-- insert into Sells
-- values ('pizza-hut', 'Tropical Dream', 'Specialty Pizza', 'Fast food', 100, 0, 12.30);
-- insert into Sells
-- values ('pizza-hut', 'Wild About Mushroom', 'Specialty Pizza', 'Fast food', 100, 0, 12.30);
-- insert into Sells
-- values ('pizza-hut', 'The Four Cheese', 'Specialty Pizza', 'Fast food', 100, 0, 12.30);
-- insert into Sells
-- values ('pizza-hut', 'Seafood Deluxe', 'Specialty Pizza', 'Fast food', 100, 0, 12.30);
-- insert into Sells
-- values ('pizza-hut', 'BBQ Chicken', 'Specialty Pizza', 'Fast food', 100, 0, 12.30);
-- insert into Sells
-- values ('pizza-hut', 'Hawaiian Supreme', 'Specialty Pizza', 'Fast food', 100, 0, 12.30);

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
values ('lightning', date '2020-03-29', '0', '0', '3', '4', '3', '4', '2');
insert into FWS
values ('flash', date '2020-03-29', '3', '1', '0', '0', '2', '3', '4');
end;

/*
 Orders
 */
begin;
insert into Orders(cid, lon, lat, payment_mode, rid, time_placed, time_depart, time_collect, time_leave, time_paid)
values ('alice', '1.11', '1.11', 'Cash', 'kfc', date '2020-12-30', date '2020-12-30', date '2020-12-30',
        date '2020-12-30', date '2020-12-30');
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

begin;
insert into Reviews (content, rating, oid)
values ('Chicken is amazing', '5', '4')
on conflict(oid) do update set content = 'Chicken is amazing',
                               rating  = '5'
where Reviews.oid = '4';
insert into Reviews (content, rating, oid)
values ('Delivery is too slow. Food is quite good.', '3', '3')
on conflict(oid) do update set content = 'Delivery is too slow. Food is quite good.',
                               rating  = '3'
where Reviews.oid = '3';
insert into Reviews (content, rating, oid)
values ('McSpicy is absolutely amazing', '5', '8')
on conflict(oid) do update set content = 'Chicken is amazing',
                               rating  = '5'
where Reviews.oid = '8';
commit;


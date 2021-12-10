-- CS4400: Introduction to Database Systems (Fall 2021)
-- Phase III: Stored Procedures & Views [v0] Tuesday, November 9, 2021 @ 12:00am EDT
-- Team 32
-- Rebecca Tafete (rtafete3)
-- Serena Gao (sgao97)
-- Chelsea Yangnouvong (cyangnouvong3)
-- Keely Culbertson (kculbertson3)
-- Directions:
-- Please follow all instructions for Phase III as listed on Canvas.
-- Fill in the team number and names and GT usernames for all members above.
USE travel_reservation_service;
SET GLOBAL log_bin_trust_function_creators = 1;

-- ID: 1a
-- Name: register_customer
drop procedure if exists register_customer;
delimiter //
create procedure register_customer (
    in i_email varchar(50),
    in i_first_name varchar(100),
    in i_last_name varchar(100),
    in i_password varchar(50),
    in i_phone_number char(12),
    in i_cc_number varchar(19),
    in i_cvv char(3),
    in i_exp_date date,
    in i_location varchar(50)
) 
sp_main: begin
-- TODO: Implement your solution here
-- email and phone number must be unique
-- credit card number must be unique
-- phone number must be unique
-- if customer already exists as an account/client but not customer, add them as customer to indicate they are both an owner and a customer

-- HELP: do we need to check if their email matches their phone number in clients?
if (i_email in (select Email from Clients)) then
	if (i_email in (select Email from Customer)) then leave sp_main; end if;
    if (i_cc_number in (select CcNumber from Customer)) then leave sp_main; end if;
    insert into Customer values(i_email, i_cc_number, i_cvv, i_exp_date, i_location);
elseif (i_phone_number in (select Phone_Number from Clients)) then leave sp_main;
else 
	if (i_cc_number in (select CcNumber from Customer)) then leave sp_main; end if;
	insert into Accounts values(i_email, i_first_name, i_last_name, i_password);
    insert into Clients values(i_email, i_phone_number);
    insert into Customer values(i_email, i_cc_number, i_cvv, i_exp_date, i_location);
end if;

end //
delimiter ;

-- call register_customer('keelyculb@gmail.com', 'Chandler', 'Bing', 'pass', '555-456-7890', '1111-2222-3333-4444', '123', '2022-01-01', 'Atlanta');

-- ID: 1b
-- Name: register_owner
drop procedure if exists register_owner;
delimiter //
create procedure register_owner (
    in i_email varchar(50),
    in i_first_name varchar(100),
    in i_last_name varchar(100),
    in i_password varchar(50),
    in i_phone_number char(12)
) 
sp_main: begin
-- TODO: Implement your solution here

-- HELP: do we need to check if their email matches their phone number in clients?
if (i_email in (select Email from Clients)) then
	if (i_email in (select Email from Owners)) then leave sp_main; end if;
    insert into Owners values(i_email);
elseif (i_phone_number in (select Phone_Number from Clients)) then leave sp_main;
else 
	insert into Accounts values(i_email, i_first_name, i_last_name, i_password);
    insert into Clients values(i_email, i_phone_number);
    insert into Owners values(i_email);
end if;

end //
delimiter ;


-- ID: 1c
-- Name: remove_owner
drop procedure if exists remove_owner;
delimiter //
create procedure remove_owner ( 
    in i_owner_email varchar(50)
)
sp_main: begin
-- TODO: Implement your solution here

-- if owner has properties, leave
if (i_owner_email in (select Owner_Email from Property)) then leave sp_main; end if;

-- delete their reviews of customers
delete from Owners_Rate_Customers where Owner_Email = i_owner_email;
-- delete reviews of them by customers
delete from Customers_Rate_Owners where Owner_Email = i_owner_email;
-- if owner is customer, delete owner only
-- else delete client and account as well
if (i_owner_email not in (select Email from Customer)) then
	delete from Owners where Email = i_owner_email;
	delete from Clients where Email = i_owner_email;
    delete from Accounts where Email = i_owner_email;
    leave sp_main;
end if;
delete from Owners where Email = i_owner_email;

end //
delimiter ;


-- ID: 2a
-- Name: schedule_flight
drop procedure if exists schedule_flight;
delimiter //
create procedure schedule_flight (
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_from_airport char(3),
    in i_to_airport char(3),
    in i_departure_time time,
    in i_arrival_time time,
    in i_flight_date date,
    in i_cost decimal(6, 2),
    in i_capacity int,
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

-- if airline already has that flight num, leave
if (i_flight_num in (select Flight_Num from Flight where Airline_Name = i_airline_name)) then leave sp_main; end if;
-- if to airport is same as from airport, leave
if (i_to_airport = i_from_airport) then leave sp_main; end if;
-- if date is in future, add flight
if (i_flight_date > i_current_date) then 
	insert into Flight values (i_flight_num, i_airline_name, i_from_airport, i_to_airport, i_departure_time, i_arrival_time, i_flight_date, i_cost, i_capacity);
end if;

end //
delimiter ;


-- ID: 2b
-- Name: remove_flight
drop procedure if exists remove_flight;
delimiter //
create procedure remove_flight ( 
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_current_date date
) 
sp_main: begin
-- TODO: Implement your solution here

-- if date not in future, leave
if (i_current_date >= (select Flight_Date from Flight where Flight_Num = i_flight_num and Airline_Name = i_airline_name)) then leave sp_main; end if;
-- remove all bookings associated with flight
delete from Book where (Flight_Num = i_flight_num and Airline_Name = i_airline_name);
-- remove flight
delete from Flight where (Flight_Num = i_flight_num and Airline_Name = i_airline_name);

end //
delimiter ;


-- ID: 3a
-- Name: book_flight
drop procedure if exists book_flight;
delimiter //
create procedure book_flight (
    in i_customer_email varchar(50),
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_num_seats int,
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

-- HELP: will new i_num_seats always be greater? OR could it be smaller?
-- HELP: does date have to strictly be in future or could it be same day?

set @seats_remaining = calc_seats_remaining(i_flight_num, i_airline_name);

-- if num seats remaining is less than num seats booked, leave
if (@seats_remaining < i_num_seats) then leave sp_main; end if;
-- if date not in future, leave
if (i_current_date >= (select Flight_Date from Flight where Flight_Num = i_flight_num and Airline_Name = i_airline_name)) then leave sp_main; end if;
-- if count with email, flight num, and airline name > 0, update num seats if enough available and booking not cancelled
if ((select count(Flight_Num) from Book where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name) > 0) then
	if (select Was_Cancelled from Book where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name) then leave sp_main; end if;
    if (@seats_remaining >= (i_num_seats - (select count(Flight_Num) from Book where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name))) then
		update Book set Num_Seats = i_num_seats where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name;
	end if;
end if;
-- if count of non-cancelled flights on that day = 0, book flight
-- elseif ((select count(Flight_Num) from Book b, Flight f where b.Customer = i_customer_email and b.Flight_Num = i_flight_num and b.Airline_Name = i_airline_name and b.Was_Cancelled = 0) = 0) then
if ((select count(Flight_Num) from Book where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name and Was_Cancelled = 0) > 0) then leave sp_main; end if;

insert into Book values (i_customer_email, i_flight_num, i_airline_name, i_num_seats, 0);

end //
delimiter ;

drop function if exists calc_seats_remaining;
delimiter //
create function calc_seats_remaining(p_flight_num char(5), p_airline_name varchar(50))
	returns integer deterministic
begin
	return (select Capacity from Flight where Flight_Num = p_flight_num and Airline_Name = p_airline_name) - (select sum(Num_Seats) from Book where Flight_Num = p_flight_num and Airline_Name = p_airline_name and Was_Cancelled = 0);
end //
delimiter ;

-- ID: 3b
-- Name: cancel_flight_booking
drop procedure if exists cancel_flight_booking;
delimiter //
create procedure cancel_flight_booking ( 
    in i_customer_email varchar(50),
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

-- if customer not booked this flight, leave
-- if ((select count(Flight_Num) where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name) = 0) then leave sp_main; end if;
if ((select count(Flight_Num) from Book where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name) = 0) then leave sp_main; end if;
-- if date not in future, leave
if (i_current_date >= (select Flight_Date from Flight where Flight_Num = i_flight_num and Airline_Name = i_airline_name)) then leave sp_main; end if;
-- set cancelled flag to 1
update Book set Was_Cancelled = 1 where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name;

end //
delimiter ;

-- ID: 3c
-- Name: view_flight
create or replace view view_flight (
    flight_id,
    flight_date,
    airline,
    destination,
    seat_cost,
    num_empty_seats,
    total_spent
) as
select flight.Flight_Num, flight.Flight_Date, flight.Airline_Name, To_Airport, Cost, 
Capacity - ifnull(sum(Num_Seats), 0) + ifnull((select sum(Num_Seats) from book where Was_Cancelled is true and flight.Flight_Num = book.Flight_Num), 0), 
sum(ifnull(Num_Seats, 0) * Cost) - (ifnull((select sum(Num_Seats) from book where Was_Cancelled is true and flight.Flight_Num = book.Flight_Num), 0) * Cost * 0.8)
    from flight left join book on flight.Flight_Num = book.Flight_Num
    group by flight.Flight_Num
    order by flight.Flight_Num ASC;
    

-- ID: 4a
-- Name: add_property
drop procedure if exists add_property;
delimiter //
create procedure add_property (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_description varchar(500),
    in i_capacity int,
    in i_cost decimal(6, 2),
    in i_street varchar(50),
    in i_city varchar(50),
    in i_state char(2),
    in i_zip char(5),
    in i_nearest_airport_id char(3),
    in i_dist_to_airport int
) 
sp_main: begin
-- TODO: Implement your solution here

-- if address not unique, leave
if ((select count(Property_Name) from Property where Street = i_street and City = i_city and State = i_state and Zip = i_zip) > 0) then leave sp_main; end if;
-- if combo of property name and owner's email not unique, leave
if (i_property_name in (select Property_Name from Property where Owner_Email = i_owner_email)) then leave sp_main; end if;
-- insert into property
insert into Property values(i_property_name, i_owner_email, i_description, i_capacity, i_cost, i_street, i_city, i_state, i_zip);
-- if nearest airport given and valid (check if exists in airport?), add to is close to table
if (i_nearest_airport_id is not null and i_dist_to_airport is not null and i_nearest_airport_id in (select Airport_Id from Airport)) then
	insert into Is_Close_To values(i_property_name, i_owner_email, i_nearest_airport_id, i_dist_to_airport);
end if;
  
end //
delimiter ;


-- ID: 4b
-- Name: remove_property
drop procedure if exists remove_property;
delimiter //
create procedure remove_property (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

-- if booked for current day and not cancelled, leave
if ((select count(Customer) from Reserve where Property_Name = i_property_name and Owner_Email = i_owner_email and (Start_Date <= i_current_date and End_Date >= i_current_date) and Was_Cancelled = 0) > 0) then leave sp_main; end if;
-- remove all bookings (past and future) associated with this property
delete from Reserve where Property_Name = i_property_name and Owner_Email = i_owner_email;
-- remove all reviews associated with this property
delete from Review where Property_Name = i_property_name and Owner_Email = i_owner_email;
-- remove all amenities associated with this property
delete from Amenity where Property_Name = i_property_name and Property_Owner = i_owner_email;
-- remove all entries in is close to associated with this property
delete from Is_Close_To where Property_Name = i_property_name and Owner_Email = i_owner_email;
delete from Property where Property_Name = i_property_name and Owner_Email = i_owner_email;
    
end //
delimiter ;


-- ID: 5a
-- Name: reserve_property
drop procedure if exists reserve_property;
delimiter //
create procedure reserve_property (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_start_date date,
    in i_end_date date,
    in i_num_guests int,
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

-- if combo of property name, owner email, and customer not unique, leave
if ((select count(Start_Date) from Reserve where Property_Name = i_property_name and Owner_Email = i_owner_email and Customer = i_customer_email) > 0) then leave sp_main; end if;
-- if start date not in future, leave
if (i_start_date <= i_current_date) then leave sp_main; end if;
-- if guest has overlapping reservations, leave
if ((select count(Property_Name) from Reserve where ((Start_Date <= i_start_date and End_Date >= i_start_date) or (Start_Date <= i_end_date and End_Date >= i_end_date))) > 0) then leave sp_main; end if;
-- if property doesn't have enough capacity over the span of dates, leave
set @curr_date = i_start_date;
date_loop: loop
	if (i_num_guests > calc_beds_remaining(i_property_name, i_owner_email, @curr_date)) then leave sp_main; end if;
    set @curr_date = DATE_ADD(@curr_date, INTERVAL 1 DAY);
    if (@curr_date > i_end_date) then leave date_loop; end if;
end loop date_loop;
-- add reservation
insert into Reserve values(i_property_name, i_owner_email, i_customer_email, i_start_date, i_end_date, i_num_guests, 0);

end //
delimiter ;

drop function if exists calc_beds_remaining;
delimiter //
create function calc_beds_remaining(p_property_name varchar(50), p_owner_email varchar(50), p_date date)
	returns integer deterministic
begin
	return (select Capacity from Property where Property_Name = p_property_name and Owner_Email = p_owner_email) - COALESCE((select sum(Num_Guests) from Reserve where Property_Name = p_property_name and Owner_Email = p_owner_email and (Start_Date <= p_date and End_Date >= p_date)), 0);
    
end //
delimiter ;


-- ID: 5b
-- Name: cancel_property_reservation
drop procedure if exists cancel_property_reservation;
delimiter //
create procedure cancel_property_reservation (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

-- if customer hasn't booked property, leave
if (i_customer_email not in (select Customer from Reserve where Property_Name = i_property_name and Owner_Email = i_owner_email)) then leave sp_main; end if;
-- if reservation already cancelled, leave
if (select Was_Cancelled from Reserve where Property_Name = i_property_name and Owner_Email = i_owner_email and Customer = i_customer_email) then leave sp_main; end if;
-- if start date passed or today, leave
if (i_current_date >= (select Start_Date from Reserve where Property_Name = i_property_name and Owner_Email = i_owner_email and Customer = i_customer_email)) then leave sp_main; end if;
-- update cancelled
update Reserve set Was_Cancelled = 1 where Property_Name = i_property_name and Owner_Email = i_owner_email and Customer = i_customer_email;

end //
delimiter ;


-- ID: 5c
-- Name: customer_review_property
drop procedure if exists customer_review_property;
delimiter //
create procedure customer_review_property (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_content varchar(500),
    in i_score int,
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

-- if customer has reservation for property that started in past and wasn't cancelled
if (i_customer_email in (select Customer from Reserve where Property_Name = i_property_name and Owner_Email = i_owner_email and Was_Cancelled = 0 and Start_Date <= i_current_date)) then
-- if customer hasn't already reviewed property
	if (i_customer_email not in (select Customer from Review where Property_Name = i_property_name and Owner_Email = i_owner_email)) then
-- insert review
		insert into Review values(i_property_name, i_owner_email, i_customer_email, i_content, i_score);
	end if;
end if;
    
end //
delimiter ;


-- ID: 5d
-- Name: view_properties
create or replace view view_properties (
    property_name, 
    average_rating_score, 
    description, 
    address, 
    capacity, 
    cost_per_night
) as
select property.Property_Name, avg(review.Score), Descr, concat(Street, ", ", City, ", ", State, ", ", Zip), Capacity, Cost
    from property left outer join review on property.Property_Name = review.Property_Name group by property.Property_Name;

-- ID: 5e
-- Name: view_individual_property_reservations
drop procedure if exists view_individual_property_reservations;
delimiter //
create procedure view_individual_property_reservations (
    in i_property_name varchar(50),
    in i_owner_email varchar(50)
)
sp_main: begin
    drop table if exists view_individual_property_reservations;
    create table view_individual_property_reservations (
        property_name varchar(50),
        start_date date,
        end_date date,
        customer_email varchar(50),
        customer_phone_num char(12),
        total_booking_cost decimal(6,2),
        rating_score int,
        review varchar(500)
    );
    
    if (i_property_name in (select Property_Name from Property where Owner_Email = i_owner_email)) then
		insert into view_individual_property_reservations 
			select r.Property_Name, r.Start_Date, r.End_Date, r.Customer, c.Phone_Number, ((p.Cost * r.Num_guests) * (r.End_Date - r.Start_Date) * (1 - r.Was_Cancelled * 0.8)), v.Score, v.Content
            from Reserve r join Clients c on r.Customer = c.Email
            join Property p on p.Property_Name = r.Property_Name and p.Owner_Email = r.Owner_Email
            left join Review v on r.Property_Name = v.Property_Name and r.Owner_Email = v.Owner_Email and r.Customer = v.Customer
            where r.Property_Name = i_property_name and r.Owner_Email = i_owner_email;
	else drop table view_individual_property_reservations;
    end if;

end //
delimiter ;

drop function if exists calc_total_cost;
delimiter //
create function calc_total_cost(p_num_guests int(11), p_start_date date, p_end_date date, p_nightly_cost decimal(6,2), p_was_cancelled tinyint(1))
	returns decimal
begin
	set @total = (p_end_date - p_start_date + 1) * p_num_guests * p_nightly_cost;
    
    if (p_was_cancelled) then return (@total * 0.2); end if;
    return @total;
    
end //
delimiter ;


-- ID: 6a
-- Name: customer_rates_owner
drop procedure if exists customer_rates_owner;
delimiter //
create procedure customer_rates_owner (
    in i_customer_email varchar(50),
    in i_owner_email varchar(50),
    in i_score int,
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

-- if customer or owner don't exist, leave
if (i_owner_email not in (select Email from Owners)) then leave sp_main; end if;
if (i_customer_email not in (select Email from Customer)) then leave sp_main; end if;
-- if customer stayed at property owned by owner that was in the past and not cancelled
if (i_customer_email in (select Customer from Reserve where Owner_Email = i_owner_email and Start_Date <= i_current_date and Was_Cancelled = 0)) then
-- if customer hasn't already rated owner
	if (i_customer_email not in (select Customer from Customers_Rate_Owners where Owner_Email = i_owner_email)) then
		insert into Customers_Rate_Owners values(i_customer_email, i_owner_email, i_score);
	end if;
end if;

end //
delimiter ;


-- ID: 6b
-- Name: owner_rates_customer
drop procedure if exists owner_rates_customer;
delimiter //
create procedure owner_rates_customer (
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_score int,
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

-- if customer or owner don't exist, leave
if (i_owner_email not in (select Email from Owners)) then leave sp_main; end if;
if (i_customer_email not in (select Email from Customer)) then leave sp_main; end if;
-- if customer stayed at property owned by owner that was in the past and not cancelled
if (i_customer_email in (select Customer from Reserve where Owner_Email = i_owner_email and Start_Date <= i_current_date and Was_Cancelled = 0)) then
-- if customer hasn't already rated owner
	if (i_owner_email not in (select Owner_Email from Owners_Rate_Customers where Customer = i_customer_email)) then
		insert into Owners_Rate_Customers values(i_owner_email, i_customer_email, i_score);
	end if;
end if;

end //
delimiter ;


-- NOT AT ALL confident with this one lol
-- ID: 7a
-- Name: view_airports
create or replace view t1 as
    select Airport_Id, Airport_Name, time_zone, ifnull(count(To_Airport), 0) as tot_arr
    from airport left join flight on to_airport = airport_id group by airport_id;

create or replace view t2 as
    select Airport_Id, ifnull(count(From_Airport), 0) as tot_dep, avg(cost) as avg_dep
    from airport left join flight on Airport_Id = from_airport group by airport_id;

-- ID: 7a
-- Name: view_airports
create or replace view view_airports (
    airport_id, 
    airport_name, 
    time_zone, 
    total_arriving_flights, 
    total_departing_flights, 
    avg_departing_flight_cost
) as
select t1.Airport_Id, Airport_Name, time_zone, tot_arr, tot_dep, avg_dep from t1 natural join t2;

select * from view_airports;


-- ID: 7b
-- Name: view_airlines
create or replace view view_airlines (
    airline_name, 
    rating, 
    total_flights, 
    min_flight_cost
) as
select Airline_Name, Rating, count(*), min(Cost) from airline natural join flight group by Airline_Name;


create or replace view temp1 as
    select Customer.email as email, concat(First_Name, " ", Last_Name) as fullname, Location
    from accounts natural join customer; 

create or replace view temp2 as
    select customer.email as cust, ifnull(count(*), 0) as isOwner
    from owners join customer on owners.email = customer.email
    group by customer.email;

create or replace view temp3 as
    select email, fullname, location, ifnull(isOwner, 0) as isOwner
    from temp1 left join temp2 on email = cust;

create or replace view temp4 as
    select customer, sum(num_seats) as total from book group by customer;
    
create or replace view temp5 as
    select email, fullname, location, isOwner, ifnull(total, 0) as tot from temp3 left join temp4 on email = customer;


-- ID: 8a
-- Name: view_customers
create or replace view view_customers (
    customer_name, 
    avg_rating, 
    location, 
    is_owner, 
    total_seats_purchased
) as
-- TODO: replace this select query with your solution
-- view customers
    select fullname, avg(Score), location, isOwner, tot from temp5 
    left join owners_rate_customers
    on customer = temp5.email
    group by temp5.email;

-- TEMP VIEWS FOR VIEW_OWNERS

create or replace view temp_view_1 as
	select accounts.Email as email_1, 
		concat(First_Name, " ", Last_Name) as full_name,
		avg(Score) as avgScore 
    from accounts join customers_rate_owners where accounts.Email = customers_rate_owners.Owner_Email;

create or replace view temp_view_2 as
	select property.Owner_Email as email_1, 
		count(Property_Name) as numProperties, 
        avg(Score) as avgPropertyScore 
	from property natural join review; 
	
-- TEMP VIEWS FOR VIEW_OWNERS

create or replace view temp_view_0 as
    select owners.Email as email, concat(First_Name, " ", Last_Name) as full_name from accounts natural join owners;

select * from temp_view_0;

create or replace view temp_view_1 as
    select temp_view_0.email as Owner_Email, 
        temp_view_0.full_name as full_name,
        avg(Score) as avg_rating 
    from temp_view_0 left outer join customers_rate_owners on temp_view_0.email = customers_rate_owners.Owner_Email
    group by temp_view_0.email;

select * from temp_view_1;

create or replace view temp_view_11 as
    select temp_view_1.Owner_Email as Owner_Email_11, count(property.Owner_Email) as numProperties from property 
    right outer join temp_view_1 on temp_view_1.Owner_Email = property.Owner_Email group by temp_view_1.Owner_Email;
select * from temp_view_11;

create or replace view temp_view_2 as
    select temp_view_11.Owner_Email_11 as email_2, 
        temp_view_11.numProperties,
        avg(Score) as avgPropertyScore 
    from temp_view_11 left outer join review on temp_view_11.Owner_Email_11 = review.Owner_Email group by temp_view_11.Owner_Email_11;
select * from temp_view_2;
    
-- ID: 8b
-- Name: view_owners
create or replace view view_owners (
    owner_name, 
    avg_rating, 
    num_properties_owned, 
    avg_property_rating
) as
    select full_name, avg_rating, numProperties, avgPropertyScore from temp_view_1 
    left join temp_view_2 on temp_view_1.Owner_Email = temp_view_2.email_2;

-- ID: 9a
-- Name: process_date
drop procedure if exists process_date;
delimiter //
create procedure process_date ( 
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

drop table if exists flight_reservations;
create table flight_reservations(
	Customer_Email varchar(50),
	State char(2)
) as (select c.Email as Customer_Email, a.State
	from Book b join Flight f join Customer c join Airport a 
    on b.Flight_Num = f.Flight_Num and b.Airline_Name = f.Airline_Name and c.Email = b.Customer and a.Airport_Id = f.To_Airport 
    where b.Was_Cancelled = 0 and f.Flight_Date = i_current_date
);

update Customer, flight_reservations set Customer.Location = flight_reservations.State where Customer.Email = flight_reservations.Customer_Email;
    
end //
delimiter ;

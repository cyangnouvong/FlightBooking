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
if (i_owner_email not in (select Email from Customers)) then
	delete from Clients where Email = i_owner_email;
    delete from Accounts where Email = i_owner_email;
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
if (i_current_date >= (select Flight_Date from Flight where Flight_Num = p_flight_num and Airline_Name = p_airline_name)) then leave sp_main; end if;
-- if count with email, flight num, and airline name > 0, update num seats if enough available and booking not cancelled
if ((select count(Flight_Num) from Book where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name) > 0) then
	if (select Was_Cancelled from Book where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name) then leave sp_main; end if;
    if (@seats_remaining >= (i_num_seats - (select count(Flight_Num) from Book where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name))) then
		update Book set Num_Seats = i_num_seats where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name;
	end if;
-- if count of non-cancelled flights on that day = 0, book flight
elseif ((select count(Flight_Num) from Book, Flight where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name and Was_Cancelled = 0) = 0) then
	insert into Book values (i_customer_email, i_flight_num, i_airline_name, i_num_seats, 0);
end if;

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
if ((select count(Flight_Num) where Customer = i_customer_email and Flight_Num = i_flight_num and Airline_Name = i_airline_name) = 0) then leave sp_main; end if;
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
select flight.Flight_Num, Flight_Date, flight.Airline_Name, To_Airport, Cost, Capacity - sum(Num_Seats), sum(Cost + (Cost * 0.2 * Was_Cancelled))
	from flight natural join book;
    

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
select Property_Name, avg(customers_rate_owners.Score), Descr, concat(Street, ", ", City, ", ", State, ", ", Zip), Capacity, Cost
    from property natural join customers_rate_owners;

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
    ) as
    -- TODO: replace this select query with your solution
    select 'col1', 'col2', 'col3', 'col4', 'col5', 'col6', 'col7', 'col8' from reserve;

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

end //
delimiter ;


-- NOT AT ALL confident with this one lol
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
select Airport_Id, Airport_Name, Time_Zone, count(To_Airport), count(From_Airport), avg(Cost) from airport join flight 
	where airport.Airport_Id = flight.To_Airport 
		or airport.Airport_Id = flight.From_Airport;


-- ID: 7b
-- Name: view_airlines
create or replace view view_airlines (
    airline_name, 
    rating, 
    total_flights, 
    min_flight_cost
) as
select Airline_Name, Rating, count(*), min(Cost) from airline natural join flight;


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
select 'col1', 'col2', 'col3', 'col4', 'col5' from customer;

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
	
-- ID: 8b
-- Name: view_owners
create or replace view view_owners (
    owner_name, 
    avg_rating, 
    num_properties_owned, 
    avg_property_rating
) as
	select full_name, avgScore, numProperties, avgPropertyScore from temp_view_1 natural join temp_view_2;

-- ID: 9a
-- Name: process_date
drop procedure if exists process_date;
delimiter //
create procedure process_date ( 
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here
    
end //
delimiter ;

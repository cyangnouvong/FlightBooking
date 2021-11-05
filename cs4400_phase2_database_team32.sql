-- CS4400: Introduction to Database Systems (Fall 2021)
-- Phase II: Create Table & Insert Statements [v0] Thursday, October 4, 2021 @ 2:00pm EDT

-- Team 32
-- Chelsea Yangnouvong (cyangnouvong3)
-- Keely Culbertson (kculbertson3)
-- Rebecca Tafete (rtafete3)
-- Serena Gao (sgao97)

-- Directions:
-- Please follow all instructions for Phase II as listed on Canvas.
-- Fill in the team number and names and GT usernames for all members above.
-- Create Table statements must be manually written, not taken from an SQL Dump file.
-- This file must run without error for credit.

-- ------------------------------------------------------
-- CREATE TABLE STATEMENTS AND INSERT STATEMENTS BELOW
-- ------------------------------------------------------

DROP DATABASE IF EXISTS travel;
CREATE DATABASE IF NOT EXISTS travel;
USE travel;

-- admin table

DROP TABLE IF EXISTS admin;
CREATE TABLE admin (
	email varchar(50) NOT NULL,
    fname varchar(100),
    lname varchar(100),
    password varchar(50) NOT NULL,
    PRIMARY KEY (email)
);

-- client table

DROP TABLE IF EXISTS client;
CREATE TABLE client (
	email varchar(50) NOT NULL,
    fname varchar(100),
    lname varchar(100),
    password varchar(50) NOT NULL,
    phoneNumber char(12) NOT NULL,
    creditCardNum char(19),
    cvv char(3),
    expDate date,
    currentLocation varchar(50),
    isOwner boolean NOT NULL,
    isCustomer boolean NOT NULL,
    PRIMARY KEY (email),
    UNIQUE KEY (phoneNumber)
);

-- property table

DROP TABLE IF EXISTS property;
CREATE TABLE property (
	-- ownerPhone char(12) NOT NULL,
    email varchar(50) NOT NULL,
    name varchar(50) NOT NULL,
    description varchar(300),
    capacity int NOT NULL,
    nightlyCostPerPerson float NOT NULL,
    street varchar(50) NOT NULL,
    city varchar(50) NOT NULL,
    state char(2) NOT NULL,
    zip char(5) NOT NULL,
    PRIMARY KEY (name, email),
    UNIQUE KEY (street, city, state, zip), -- added idk if right
    FOREIGN KEY (email) REFERENCES client (email)
);

-- property amenities table

DROP TABLE IF EXISTS propertyAmenities;
CREATE TABLE propertyAmenities (
	email varchar(50) NOT NULL,
    propertyName varchar(50) NOT NULL,
    amenity varchar(50) NOT NULL,
    PRIMARY KEY (email, propertyName, amenity),
    FOREIGN KEY (email) REFERENCES property (email),
    FOREIGN KEY (propertyName) REFERENCES property (name)
);

-- airport table

DROP TABLE IF EXISTS airport;
CREATE TABLE airport (
	airportID char(3) NOT NULL,
    name varchar(50) NOT NULL,
    timeZone char(3) NOT NULL,
    street varchar(50) NOT NULL,
    city varchar(50) NOT NULL,
    state char(2) NOT NULL,
    zip char(5) NOT NULL,
    PRIMARY KEY (airportID),
    UNIQUE KEY (name)
);

-- airport attractions table

DROP TABLE IF EXISTS airportAttractions;
CREATE TABLE airportAttractions (
	airport char(3) NOT NULL,
    attraction varchar(50) NOT NULL,
    PRIMARY KEY (airport, attraction),
    FOREIGN KEY (airport) REFERENCES airport (airportID)
);

-- airline table

DROP TABLE IF EXISTS airline;
CREATE TABLE airline (
	name varchar(50) NOT NULL,
    rating float NOT NULL,
    PRIMARY KEY (name)
);

-- flight table

DROP TABLE IF EXISTS flight;
CREATE TABLE flight (
	airlineName varchar(50) NOT NULL,
    flightNum varchar(5) NOT NULL,
    departureAirport char(3) NOT NULL,
    arrivalAirport char(3) NOT NULL,
    departTime time NOT NULL,
    arriveTime time NOT NULL,
    date date NOT NULL,
    costPerSeat float NOT NULL,
    capacity int NOT NULL,
    PRIMARY KEY (flightNum, airlineName),
    FOREIGN KEY (airlineName) REFERENCES airline (name),
    FOREIGN KEY (departureAirport) REFERENCES airport (airportID),
    FOREIGN KEY (arrivalAirport) REFERENCES airport (airportID)
);

-- flight booking table

DROP TABLE IF EXISTS flightBooking;
CREATE TABLE flightBooking (
	email varchar(50) NOT NULL,
    airlineName varchar(50) NOT NULL,
    flightNum char(5) NOT NULL,
    numSeats int NOT NULL,
    PRIMARY KEY (email, airlineName, flightNum),
    FOREIGN KEY (email) REFERENCES client (email),
    FOREIGN KEY (airlineName) REFERENCES flight (airlineName),
    FOREIGN KEY (flightNum) REFERENCES flight (flightNum)
);

-- owner rating table

DROP TABLE IF EXISTS ownerRating;
CREATE TABLE ownerRating (
	ownerEmail varchar(50) NOT NULL,
    customerEmail varchar(50) NOT NULL,
    score int NOT NULL,
    PRIMARY KEY (ownerEmail, customerEmail),
    FOREIGN KEY (ownerEmail) REFERENCES client (email),
    FOREIGN KEY (customerEmail) REFERENCES client (email)
);

-- customer rating table

DROP TABLE IF EXISTS customerRating;
CREATE TABLE customerRating (
	ownerEmail varchar(50) NOT NULL,
    customerEmail varchar(50) NOT NULL,
    score int NOT NULL,
    PRIMARY KEY (ownerEmail, customerEmail),
    FOREIGN KEY (ownerEmail) REFERENCES client (email),
    FOREIGN KEY (customerEmail) REFERENCES client (email)
);

-- property review table

DROP TABLE IF EXISTS propertyReview;
CREATE TABLE propertyReview (
	propertyName varchar(50) NOT NULL,
    ownerEmail varchar(50) NOT NULL,
	customerEmail varchar(50) NOT NULL,
    content varchar(500) NOT NULL,
    score int NOT NULL,
    PRIMARY KEY (customerEmail, ownerEmail, propertyName),
    FOREIGN KEY (customerEmail) REFERENCES client (email),
    FOREIGN KEY (ownerEmail) REFERENCES property (email),
    FOREIGN KEY (propertyName) REFERENCES property (name)
);

-- property reservation

DROP TABLE IF EXISTS propertyReservation;
CREATE TABLE propertyReservation (
	propertyName varchar(50) NOT NULL,
    ownerEmail varchar(50) NOT NULL,
	customerEmail varchar(50) NOT NULL,
    startDate date NOT NULL,
    endDate date NOT NULL,
    numGuests int NOT NULL,
    PRIMARY KEY (propertyName, ownerEmail, customerEmail),
    FOREIGN KEY (customerEmail) REFERENCES client (email),
    FOREIGN KEY (ownerEmail) REFERENCES property (email),
    FOREIGN KEY (propertyName) REFERENCES property (name)
);

-- close airports table

DROP TABLE IF EXISTS closeAirport;
CREATE TABLE closeAirport (
	ownerEmail varchar(50) NOT NULL,
    propertyName varchar(50) NOT NULL,
    airport char(3) NOT NULL,
    distance float NOT NULL,
    PRIMARY KEY (ownerEmail, propertyName, airport),
    FOREIGN KEY (ownerEmail) REFERENCES property (email),
    FOREIGN KEY (propertyName) REFERENCES property (name),
    FOREIGN KEY (airport) REFERENCES airport (airportID)
);

-- -------------------------------------
-- AIR TRANSPORTATION INSERT STATEMENTS 
-- -------------------------------------

INSERT INTO airport VALUES
("ATL", "Atlanta Hartsfield Jackson Airport", "EST", "6000 N Terminal Pkwy", "Atlanta", "GA", "30320"),
("JFK", "John F Kennedy International Airport", "EST", "455 Airport Ave", "Queens", "NY", "11430"),
("LGA", "Laguardia Airport", "EST", "790 Airport St", "Queens", "NY", "11371"),
("LAX", "Lost Angeles International Airport", "PST", "1 World Way", "Los Angeles", "CA", "90045"),
("SJC", "Norman Y. Mineta San Jose International Airport", "PST", "1702 Airport Blvd", "San Jose", "CA", "95110"),
("ORD", "O'Hare International Airport", "CST", "10000 W O'Hare Ave", "Chicago", "IL", "60666"),
("MIA", "Miami International Airport", "EST", "2100 NW 42nd Ave", "Miami", "FL", "33126"),
("DFW", "Dallas International Airport", "CST", "2400 Aviation DR", "Dallas", "TX", "75261");

INSERT INTO airline VALUES
("Delta Airlines", 4.7),
("Southwest Airlines", 4.4),
("American Airlines", 4.6),
("United Airlines", 4.2),
("JetBlue Airways", 3.6),
("Spirit Airlines", 3.3),
("WestJet", 3.9),
("Interjet", 3.7);

INSERT INTO flight VALUES
("Delta Airlines", "1", "ATL", "JFK", "10:00:00", "12:00", "2021-10-18", 400, 150),
("Southwest Airlines", "2", "ORD", "MIA", "10:30:00", "14:30:00", "2021-10-18", 350, 125),
("American Airlines", "3", "MIA", "DFW", "13:00:00", "16:00:00",  "2021-10-18", 350, 125),
("United Airlines", "4", "ATL", "LGA", "16:30:00", "18:30:00", "2021-10-18", 400, 100),
("JetBlue Airways", "5", "LGA", "ATL", "11:00:00", "13:00:00", "2021-10-19", 400, 130),
("Spirit Airlines", "6", "SJC", "ATL", "12:30:00", "21:30:00", "2021-10-19", 650, 140),
("WestJet", "7", "LGA", "SJC", "13:00:00", "16:00:00", "2021-10-19", 700, 100),
("Interjet", 8, "MIA", "ORD", "19:30:00", "21:30:00", "2021-10-19", 350, 125),
("Delta Airlines", "9", "JFK", "ATL", "8:00:00", "10:00:00", "2021-10-20", 375, 150),
("Delta Airlines", "10", "LAX", "ATL", "9:15:00", "18:15:00", "2021-10-20", 700, 110),
("Southwest Airlines", "11", "LAX", "ORD", "12:07:00", "19:07:00", "2021-10-20", 600, 95),
("United Airlines", "12", "MIA", "ATL", "15:35:00", "17:35:00", "2021-10-20", 275, 115);

INSERT INTO airportAttractions VALUES
("ATL", "The Coke Factory"),
("ATL", "The Georgia Aquarium"),
("JFK", "The Statue of Liberty"),
("JFK", "The Empire State Building"),
("LGA", "The Statue of Liberty"),
("LGA", "The Empire State Building"),
("LAX", "Lost Angeles Lakers Stadium"),
("LAX", "Los Angeles Kings Stadium"),
("SJC", "Winchester Mystery House"),
("SJC", "San Jose Earthquakes Soccer Team"),
("ORD", "Chicago Blackhawks Stadium"),
("ORD", "Chicago Bulls Stadium"),
("MIA", "Crandon Park Beach"),
("MIA", "Miami Heat Basketball Stadium"),
("DFW", "Texas Longhorns Stadium"),
("DFW", "The Original Texas Roadhouse");

-- ---------------------------
-- ACCOUNTS INSERT STATEMENTS
-- ---------------------------

INSERT INTO admin VALUES
("mmoss1@travelagency.com", "Mark", "Moss", "password1"),
("asmith@travelagency.com", "Aviva", "Smith", "password2");

INSERT INTO client VALUES
("mscott22@gmail.com", "Michael", "Scott", "password3", "555-123-4567", null, null, null, null, TRUE, FALSE),
("arthurread@gmail.com", "Arthur", "Read", "password4", "555-234-5678", null, null, null, null, TRUE, FALSE),
("jwayne@gmail.com", "John", "Wayne", "password5", "555-345-6789", null, null, null, null, TRUE, FALSE),
("gburdell3@gmail.com", "George", "Burdell", "password6", "555-456-7890", null, null, null, null, TRUE, FALSE),
("mj23@gmail.com", "Michael", "Jordan", "password7", "555-567-8901", null, null, null, null, TRUE, FALSE),
("lebron6@gmail.com", "Lebron", "James", "password8", "555-678-9012", null, null, null, null, TRUE, FALSE),
("msmith5@gmail.com", "Michael", "Smith", "password9", "555-789-0123", null, null, null, null, TRUE, FALSE),
("ellie2@gmail.com", "Ellie", "Johnson", "password10", "555-890-1234", null, null, null, null, TRUE, FALSE),
("scooper3@gmail.com", "Sheldon", "Cooper", "password11", "678-123-4567", "6518 5559 7446 1663", "551", "2024-02-01", null, TRUE, TRUE),
("mgeller5@gmail.com", "Monica", "Geller", "password12", "678-234-5678", "2328 5670 4310 1965", "644", "2024-03-01", null, TRUE, TRUE),
("cbing10@gmail.com", "Chandler", "Bing", "password13", "678-345-6789", "8387 9523 9827 9291", "201", "2023-02-01", null, TRUE, TRUE),
("hwmit@gmail.com", "Howard", "Wolowitz", "password14", "678-456-7890", "6558 8596 9852 5299", "102", "2023-04-01", null, TRUE, TRUE),
("swilson@gmail.com", "Samantha", "Wilson", "password16", "770-123-4567", "9383 3212 4198 1836", "455", "2022-08-01", null, FALSE, TRUE),
("aray@tiktok.com", "Addison", "Ray", "password17", "770-234-5678", "3110 2669 7949 5605", "744", "2022-08-01", null, FALSE, TRUE),
("cdemilio@tiktok.com", "Charlie", "Demilio", "password18", "770-345-6789", "2272 3555 4078 4744", "606", "2025-02-01", null, FALSE, TRUE),
("bshelton@gmail.com", "Blake", "Shelton", "password19", "770-456-7890", "9276 7639 7883 4273", "862", "2023-09-01", null, FALSE, TRUE),
("lbryan@gmail.com", "Luke", "Bryan", "password20", "770-567-8901", "4652 3726 8864 3798", "258", "2023-05-01", null, FALSE, TRUE),
("tswift@gmail.com", "Taylor", "Swift", "password21", "770-678-9012", "5478 8420 4436 7471", "857", "2024-12-01", null, FALSE, TRUE),
("jseinfeld@gmail.com", "Jerry", "Seinfeld", "password22", "770-789-0123", "3616 8977 1296 3372", "295", "2022-06-01", null, FALSE, TRUE),
("maddiesmith@gmail.com", "Madison", "Smith", "password23", "770-890-1234", "9954 5698 6355 6952", "794", "2022-07-01", null, FALSE, TRUE),
("johnthomas@gmail.com", "John", "Thomas", "password24", "404-770-5555", "7580 3274 3724 5356", "269", "2025-10-01", null, FALSE, TRUE),
("boblee15@gmail.com", "Bob", "Lee", "password25", "404-678-5555", "7907 3513 7161 4248", "858", "2025-11-01", null, FALSE, TRUE);


-- -----------------------------
-- PROPERTIES INSERT STATEMENTS
-- -----------------------------

INSERT INTO property VALUES
("scooper3@gmail.com", "Atlanta Great Property", "This is right in the middle of Atlanta near many attractions!", 4, 600, "2nd St", "ATL", "GA", "30008"),
("gburdell3@gmail.com", "House near Georgia Tech", "Super close to bobby dodde stadium!", 3, 275, "North Ave", "ATL", "GA", "30008"),
("cbing10@gmail.com", "New York City Property", "A view of the whole city. Great property!", 2, 750, "123 Main St", "NYC", "NY", "10008"),
("mgeller5@gmail.com", "Statue of Libery Property", "You can see the statue of liberty from the porch", 5, 1000, "1st St", "NYC", "NY", "10009"),
("arthurread@gmail.com", "Los Angeles Property", null, 3, 700, "10th St", "LA", "CA", "90008"),
("arthurread@gmail.com", "LA Kings House", "This house is super close to the LA kinds stadium!", 4, 750, "Kings St", "La", "CA", "90011"),
("arthurread@gmail.com", "Beautiful San Jose Mansion", "Email", 12, 900, "Golden Bridge Pkwt", "San Jose", "CA", "90001"),
("lebron6@gmail.com", "LA Lakers Property", "This house is right near the LA lakers stadium. You might even meet Lebron James!", 4, 850, "Lebron Ave", "LA", "CA", "90011"),
("hwmit@gmail.com", "Chicago Blackhawks House", "This is a great property!", 3, 775, "Blackhawks St", "Chicago", "IL", "60176"),
("mj23@gmail.com", "Chicago Romantic Getaway", "This is a great property!", 2, 1050, "23rd Main St", "Chicago", "IL", "60176"),
("msmith5@gmail.com", "Beautiful Beach Property", "You can walk out of the house and be on the beach!", 2, 975, "456 Beach Ave", "Miami", "FL", "33101"),
("ellie2@gmail.com", "Family Beach House", "You can literally walk onto the beach and see it from the patio!", 6, 850, "1132 Beach Ave", "Miami", "FL", "33101"),
("mscott22@gmail.com", "Texas Roadhouse", "This property is right in the center of Dallas, Texas!", 3, 450, "17th Street", "Dallas", "TX", "75043"),
("mscott22@gmail.com", "Texas Longhorns House", "You can walk to the longhorns stadium from here!", 10, 600, "1125 Longhorns Way", "Dallas", "TX", "75001");


INSERT INTO propertyAmenities VALUES
("scooper3@gmail.com", "Atlanta Great Property", "A/C & Heating"),
("scooper3@gmail.com", "Atlanta Great Property", "Pets allowed"),
("scooper3@gmail.com", "Atlanta Great Property", "Wifi & TV"),
("scooper3@gmail.com", "Atlanta Great Property", "Washer and Dryer"),
("gburdell3@gmail.com", "House near Georgia Tech", "Wifi & TV"),
("gburdell3@gmail.com", "House near Georgia Tech", "Washer and Dryer"),
("gburdell3@gmail.com", "House near Georgia Tech", "Full Kitchen"),
("cbing10@gmail.com", "New York City Property", "A/C & Heating"),
("cbing10@gmail.com", "New York City Property", "Wifi & TV"),
("mgeller5@gmail.com", "Statue of Libery Property", "A/C & Heating"),
("mgeller5@gmail.com", "Statue of Libery Property", "Wifi & TV"),
("arthurread@gmail.com", "Los Angeles Property", "A/C & Heating"),
("arthurread@gmail.com", "Los Angeles Property", "Pets allowed"),
("arthurread@gmail.com", "Los Angeles Property", "Wifi & TV"),
("arthurread@gmail.com", "LA Kings House", "A/C & Heating"),
("arthurread@gmail.com", "LA Kings House", "Wifi & TV"),
("arthurread@gmail.com", "LA Kings House", "Washer and Dryer"),
("arthurread@gmail.com", "LA Kings House", "Full Kitchen"),
("arthurread@gmail.com", "Beautiful San Jose Mansion", "A/C & Heating"),
("arthurread@gmail.com", "Beautiful San Jose Mansion", "Pets allowed"),
("arthurread@gmail.com", "Beautiful San Jose Mansion", "Wifi & TV"),
("arthurread@gmail.com", "Beautiful San Jose Mansion", "Washer and Dryer"),
("arthurread@gmail.com", "Beautiful San Jose Mansion", "Full Kitchen"),
("lebron6@gmail.com", "LA Lakers Property", "A/C & Heating"),
("lebron6@gmail.com", "LA Lakers Property", "Wifi & TV"),
("lebron6@gmail.com", "LA Lakers Property", "Washer and Dryer"),
("lebron6@gmail.com", "LA Lakers Property", "Full Kitchen"),
("hwmit@gmail.com", "Chicago Blackhawks House", "A/C & Heating"),
("hwmit@gmail.com", "Chicago Blackhawks House", "Wifi & TV"),
("hwmit@gmail.com", "Chicago Blackhawks House", "Washer and Dryer"),
("hwmit@gmail.com", "Chicago Blackhawks House", "Full Kitchen"),
("mj23@gmail.com", "Chicago Romantic Getaway", "A/C & Heating"),
("mj23@gmail.com", "Chicago Romantic Getaway", "Wifi & TV"),
("msmith5@gmail.com", "Beautiful Beach Property", "A/C & Heating"),
("msmith5@gmail.com", "Beautiful Beach Property", "Wifi & TV"),
("msmith5@gmail.com", "Beautiful Beach Property", "Washer and Dryer"),
("ellie2@gmail.com", "Family Beach House", "A/C & Heating"),
("ellie2@gmail.com", "Family Beach House", "Pets allowed"),
("ellie2@gmail.com", "Family Beach House", "Wifi & TV"),
("ellie2@gmail.com", "Family Beach House", "Washer and Dryer"),
("ellie2@gmail.com", "Family Beach House", "Full Kitchen"),
("mscott22@gmail.com", "Texas Roadhouse", "A/C & Heating"),
("mscott22@gmail.com", "Texas Roadhouse", "Pets allowed"),
("mscott22@gmail.com", "Texas Roadhouse", "Wifi & TV"),
("mscott22@gmail.com", "Texas Roadhouse", "Washer and Dryer"),
("mscott22@gmail.com", "Texas Longhorns House", "A/C & Heating"),
("mscott22@gmail.com", "Texas Longhorns House", "Pets allowed"),
("mscott22@gmail.com", "Texas Longhorns House", "Wifi & TV"),
("mscott22@gmail.com", "Texas Longhorns House", "Washer and Dryer"),
("mscott22@gmail.com", "Texas Longhorns House", "Full Kitchen");

INSERT INTO closeAirport VALUES
("scooper3@gmail.com", "Atlanta Great Property", "ATL", 12),
("gburdell3@gmail.com", "House near Georgia Tech", "ATL", 7),
("cbing10@gmail.com", "New York City Property", "JFK", 10),
("mgeller5@gmail.com", "Statue of Libery Property", "JFK", 8),
("cbing10@gmail.com", "New York City Property", "LGA", 25),
("mgeller5@gmail.com", "Statue of Libery Property", "LGA", 19),
("arthurread@gmail.com", "Los Angeles Property", "LAX", 9),
("arthurread@gmail.com", "LA Kings House", "LAX", 12),
("arthurread@gmail.com", "Beautiful San Jose Mansion", "SJC", 8),
("arthurread@gmail.com", "Beautiful San Jose Mansion", "LAX", 30),
("lebron6@gmail.com", "LA Lakers Property", "LAX", 6),
("hwmit@gmail.com", "Chicago Blackhawks House", "ORD", 11),
("mj23@gmail.com", "Chicago Romantic Getaway", "ORD", 13),
("msmith5@gmail.com", "Beautiful Beach Property", "MIA", 21),
("ellie2@gmail.com", "Family Beach House", "MIA", 19),
("mscott22@gmail.com", "Texas Roadhouse", "DFW", 8),
("mscott22@gmail.com", "Texas Longhorns House", "DFW", 17);

-- ---------------------------
-- BOOKINGS INSERT STATEMENTS
-- ---------------------------

INSERT INTO flightBooking VALUES
("swilson@gmail.com", "JetBlue Airways", "5", 3),
("aray@tiktok.com", "Delta Airlines", "1", 2),
("bshelton@gmail.com", "United Airlines", "4", 4),
("lbryan@gmail.com", "WestJet", "7", 2),
("tswift@gmail.com", "WestJet", "7", 2),
("jseinfeld@gmail.com", "WestJet", "7", 4),
("maddiesmith@gmail.com", "Interjet", "8", 2),
("cbing10@gmail.com", "Southwest Airlines", "2", 2),
("hwmit@gmail.com", "Southwest Airlines", "2", 5);

INSERT INTO propertyReservation VALUES
("House near Georgia Tech", "gburdell3@gmail.com", "swilson@gmail.com", "2021-10-19", "2021-10-25", 3),
("New York City Property", "cbing10@gmail.com", "aray@tiktok.com", "2021-10-18", "2021-10-23", 2),
("New York City Property", "cbing10@gmail.com", "cdemilio@tiktok.com", "2021-10-24", "2021-10-30", 2),
("Statue of Libery Property", "mgeller5@gmail.com", "bshelton@gmail.com", "2021-10-18", "2021-10-22", 4),
("Los Angeles Property", "arthurread@gmail.com", "lbryan@gmail.com", "2021-10-19", "2021-10-25", 2),
("Beautiful San Jose Mansion", "arthurread@gmail.com", "tswift@gmail.com", "2021-10-19", "2021-10-22", 10),
("LA Lakers Property", "lebron6@gmail.com", "jseinfeld@gmail.com", "2021-10-19", "2021-10-24", 4),
("Chicago Blackhawks House", "hwmit@gmail.com", "maddiesmith@gmail.com", "2021-10-19", "2021-10-23", 2),
("Chicago Romantic Getaway", "mj23@gmail.com", "aray@tiktok.com", "2021-11-01", "2021-11-07", 2),
("Beautiful Beach Property", "msmith5@gmail.com", "cbing10@gmail.com", "2021-10-18", "2021-10-25", 2),
("Family Beach House", "ellie2@gmail.com", "hwmit@gmail.com", "2021-10-18", "2021-10-28", 5);

-- --------------------------------------
-- RATINGS AND REVIEWS INSERT STATEMENTS
-- --------------------------------------

INSERT INTO propertyReview VALUES
("House near Georgia Tech", "gburdell3@gmail.com", "swilson@gmail.com", "This was so much fun. I went and saw the coke factory, the falcons play, GT play, and the Georgia aquarium. Great time! Would highly recommend!", 5),
("New York City Property", "cbing10@gmail.com", "aray@tiktok.com", "This was the best 5 days ever! I saw so much of NYC!", 5),
("Statue of Libery Property", "mgeller5@gmail.com", "bshelton@gmail.com", "This was truly an excellent experience. I really could see the Statue of Liberty from the property!", 4),
("Los Angeles Property", "arthurread@gmail.com", "lbryan@gmail.com", "I had an excellent time!", 4),
("Beautiful San Jose Mansion", "arthurread@gmail.com", "tswift@gmail.com", "We had a great time, but the house wasn't fully cleaned when we arrived", 3),
("LA Lakers Property", "lebron6@gmail.com", "jseinfeld@gmail.com", "I was disappointed that I did not meet lebron james", 2),
("Chicago Blackhawks House", "hwmit@gmail.com", "maddiesmith@gmail.com", "This was awesome! I met one player on the chicago blackhawks!", 5);

INSERT INTO ownerRating VALUES
("gburdell3@gmail.com", "swilson@gmail.com", 5),
("cbing10@gmail.com", "aray@tiktok.com", 5),
("mgeller5@gmail.com", "bshelton@gmail.com", 4),
("arthurread@gmail.com", "lbryan@gmail.com", 4),
("arthurread@gmail.com", "tswift@gmail.com", 3),
("lebron6@gmail.com", "jseinfeld@gmail.com", 2),
("hwmit@gmail.com", "maddiesmith@gmail.com", 5);

INSERT INTO customerRating VALUES
("gburdell3@gmail.com", "swilson@gmail.com", 5),
("cbing10@gmail.com", "aray@tiktok.com", 5),
("mgeller5@gmail.com", "bshelton@gmail.com", 3),
("arthurread@gmail.com", "lbryan@gmail.com", 4),
("arthurread@gmail.com", "tswift@gmail.com", 4),
("lebron6@gmail.com", "jseinfeld@gmail.com", 1),
("hwmit@gmail.com", "maddiesmith@gmail.com", 2);

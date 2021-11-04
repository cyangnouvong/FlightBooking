-- CS4400: Introduction to Database Systems (Fall 2021)
-- Phase II: Create Table & Insert Statements [v0] Thursday, October 4, 2021 @ 2:00pm EDT

-- Team 32
-- Chelsea Yangnouvong (cyangnouvong3)
-- Keely Culbertson (GT username)
-- Rebecca Tafete (GT username)
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
    fname varchar(100) NOT NULL,
    lname varchar(100) NOT NULL,
    password varchar(50) NOT NULL,
    PRIMARY KEY (email)
);

-- client table

DROP TABLE IF EXISTS client;
CREATE TABLE client (
	email varchar(50) NOT NULL,
    fname varchar(100) NOT NULL,
    lname varchar(100) NOT NULL,
    password varchar(50) NOT NULL,
    phoneNumber char(12) NOT NULL,
    isOwner boolean NOT NULL,
    isCustomer boolean NOT NULL,
    currentLocation varchar(50) NOT NULL,
    cvv char(3) NOT NULL,
    expDate date NOT NULL,
    creditCardNum char(19) NOT NULL,
    PRIMARY KEY (email),
    UNIQUE KEY (phoneNumber)
);

-- property table

DROP TABLE IF EXISTS property;
CREATE TABLE property (
	ownerPhone char(12) NOT NULL,
    name varchar(50) NOT NULL,
    street varchar(50) NOT NULL,
    city varchar(50) NOT NULL,
    state char(2) NOT NULL,
    zip char(5) NOT NULL,
    nightlyCostPerPerson float NOT NULL,
    capacity int NOT NULL,
    description varchar(50) NOT NULL,
    PRIMARY KEY (name, ownerPhone),
    FOREIGN KEY (ownerPhone) REFERENCES client (phoneNumber)
);

-- property amenities table

DROP TABLE IF EXISTS propertyAmenities;
CREATE TABLE propertyAmenities (
	propertyOwner char(12) NOT NULL,
    propertyName varchar(50) NOT NULL,
    amenity varchar(50) NOT NULL,
    PRIMARY KEY (propertyOwner, propertyName),
    FOREIGN KEY (propertyOwner) REFERENCES property (ownerPhone),
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
    PRIMARY KEY (airportID)
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
	customerPhone char(10) NOT NULL,
    airlineName varchar(50) NOT NULL,
    flightNum char(5) NOT NULL,
    numSeats int NOT NULL,
    PRIMARY KEY (customerPhone, airlineName, flightNum),
    FOREIGN KEY (customerPhone) REFERENCES client (phoneNumber),
    FOREIGN KEY (airlineName) REFERENCES flight (airlineName),
    FOREIGN KEY (flightNum) REFERENCES flight (flightNum)
);

-- owner rating table

DROP TABLE IF EXISTS ownerRating;
CREATE TABLE ownerRating (
	ownerPhone char(12) NOT NULL,
    customerPhone char(12) NOT NULL,
    score float NOT NULL,
    PRIMARY KEY (ownerPhone, customerPhone),
    FOREIGN KEY (ownerPhone) REFERENCES client (phoneNumber),
    FOREIGN KEY (customerPhone) REFERENCES client (phoneNumber)
);

-- customer rating table

DROP TABLE IF EXISTS customerRating;
CREATE TABLE customerRating (
	ownerPhone char(12) NOT NULL,
    customerPhone char(12) NOT NULL,
    score float NOT NULL,
    PRIMARY KEY (ownerPhone, customerPhone),
    FOREIGN KEY (ownerPhone) REFERENCES client (phoneNumber),
    FOREIGN KEY (customerPhone) REFERENCES client (phoneNumber)
);

-- property review table

DROP TABLE IF EXISTS propertyReview;
CREATE TABLE propertyReview (
	customerPhone char(12) NOT NULL,
    propertyOwner char(12) NOT NULL,
    propertyName varchar(50) NOT NULL,
    content varchar(50) NOT NULL,
    score float NOT NULL,
    PRIMARY KEY (customerPhone, propertyOwner, propertyName),
    FOREIGN KEY (customerPhone) REFERENCES client (phoneNumber),
    FOREIGN KEY (propertyOwner) REFERENCES property (ownerPhone),
    FOREIGN KEY (propertyName) REFERENCES property (name)
);

-- property reservation

DROP TABLE IF EXISTS propertyReservation;
CREATE TABLE propertyReservation (
	customerPhone char(12) NOT NULL,
    propertyOwner char(12) NOT NULL,
    propertyName varchar(50) NOT NULL,
    startDate date NOT NULL,
    endDate date NOT NULL,
    numGuests int NOT NULL,
    PRIMARY KEY (customerPhone, propertyOwner, propertyName),
    FOREIGN KEY (customerPhone) REFERENCES client (phoneNumber),
    FOREIGN KEY (propertyOwner) REFERENCES property (ownerPhone),
    FOREIGN KEY (propertyName) REFERENCES property (name)
);

-- close airports table

DROP TABLE IF EXISTS closeAirport;
CREATE TABLE closeAirport (
	propertyOwner char(12) NOT NULL,
    propertyName varchar(50) NOT NULL,
    airport char(3) NOT NULL,
    distance float NOT NULL,
    PRIMARY KEY (propertyOwner, propertyName, airport),
    FOREIGN KEY (propertyOwner) REFERENCES property (ownerPhone),
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




















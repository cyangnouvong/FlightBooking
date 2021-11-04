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
    PRIMARY KEY (ownerPhone),
    UNIQUE KEY (name),
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
    timeZone timestamp NOT NULL,
    street varchar(50) NOT NULL,
    city varchar(50) NOT NULL,
    state char(2) NOT NULL,
    zip char(5) NOT NULL,
    PRIMARY KEY (airportID)
);

-- airport attractions table

DROP TABLE IF EXISTS airportAttrations;
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
    flightNum char(5) NOT NULL,
    departTime timestamp NOT NULL,
    arriveTime timestamp NOT NULL,
    date date NOT NULL,
    costPerSeat float NOT NULL,
    capacity int NOT NULL,
    departureAirport char(3) NOT NULL,
    arrivalAirport char(3) NOT NULL,
    PRIMARY KEY (airlineName),
    UNIQUE KEY (flightNum),
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







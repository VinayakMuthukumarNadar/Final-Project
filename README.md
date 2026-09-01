Airline Reservation System
Overview

The Airline Reservation System is a MySQL-based database project designed to manage airline operations such as flight information, customer records, seat availability, and booking management. The system uses a relational database structure to ensure data consistency and efficient reservation handling.

Features
Flight Management
Customer Management
Seat Availability Tracking
Flight Booking System
Booking Cancellation Support
Automatic Seat Status Updates using Triggers
Flight Availability Reports
Booking Summary Reports
Technologies Used
MySQL
SQL
MySQL Workbench
Database Structure
1. Flights Table

Stores flight details:

Flight Number
Airline Name
Source City
Destination City
Departure Time
Arrival Time
Base Fare
2. Customers Table

Stores customer information:

Customer ID
Full Name
Email
Phone Number
3. Seats Table

Stores seat details for each flight:

Seat Number
Seat Class (Business/Economy)
Seat Status (Available/Booked)
4. Bookings Table

Stores booking information:

Booking ID
Customer ID
Seat ID
Booking Date
Booking Status
Total Amount
Database Relationships
One Flight → Many Seats
One Customer → Many Bookings
One Seat → One Booking at a Time

Foreign keys are used to maintain referential integrity between tables.

Triggers Implemented
Before Booking Trigger
Validates seat availability.
Prevents booking of already reserved seats.
Calculates booking amount automatically.
Business Class Fare = Base Fare × 1.5
Economy Class Fare = Base Fare
After Booking Trigger
Automatically changes seat status to Booked after successful reservation.
Booking Update Trigger
If booking is cancelled, seat becomes Available.
If booking is confirmed again, seat becomes Booked.
Views Created
vw_flight_availability

Displays:

Flight Information
Total Seats
Available Seats
Booked Seats
vw_booking_summary

Displays:

Customer Details
Flight Details
Seat Information
Booking Status
Total Amount
Sample Operations
Search Flights
View Available Seats
Make Booking
Cancel Booking
Re-book Cancelled Seat
Generate Booking Reports
Check Flight Availability
Project Workflow
Create Database
Create Tables
Define Relationships and Constraints
Insert Sample Data
Implement Triggers
Create Views
Execute Queries
Generate Reports
How to Run
Open MySQL Workbench.
Create a new SQL connection.
Import and execute airline_reservation_system.sql.
The database, tables, sample data, triggers, and views will be created automatically.
Run the provided SQL queries to test system functionality.
Learning Outcomes

This project demonstrates:

Relational Database Design
Data Normalization
Primary and Foreign Keys
SQL Queries
Joins
Triggers
Views
Data Integrity Management
Reservation System Development
Conclusion

The Airline Reservation System provides an efficient solution for managing flights, customers, seats, and bookings using MySQL. The implementation of triggers and views automates reservation management and improves data consistency, making it a practical example of database application development.

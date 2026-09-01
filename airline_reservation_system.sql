/* ============================================================
   AIRLINE RESERVATION SYSTEM
   Database: airline_reservation
   DBMS: MySQL
   ============================================================ */


/* ============================================================
   1. CREATE DATABASE
   ============================================================ */

DROP DATABASE IF EXISTS airline_reservation;

CREATE DATABASE airline_reservation;

USE airline_reservation;


/* ============================================================
   2. FLIGHTS TABLE
   ============================================================ */

CREATE TABLE Flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL UNIQUE,
    airline_name VARCHAR(100) NOT NULL,
    source_city VARCHAR(50) NOT NULL,
    destination_city VARCHAR(50) NOT NULL,
    departure_datetime DATETIME NOT NULL,
    arrival_datetime DATETIME NOT NULL,
    base_fare DECIMAL(10,2) NOT NULL
);


/* ============================================================
   3. CUSTOMERS TABLE
   ============================================================ */

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


/* ============================================================
   4. SEATS TABLE
   ============================================================ */

CREATE TABLE Seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_class VARCHAR(20) NOT NULL,
    seat_status VARCHAR(20) DEFAULT 'Available',

    CONSTRAINT fk_seat_flight
        FOREIGN KEY (flight_id)
        REFERENCES Flights(flight_id),

    CONSTRAINT unique_flight_seat
        UNIQUE (flight_id, seat_number)
);


/* ============================================================
   5. BOOKINGS TABLE
   ============================================================ */

CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    seat_id INT NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_status VARCHAR(20) DEFAULT 'Confirmed',
    total_amount DECIMAL(10,2),

    CONSTRAINT fk_booking_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    CONSTRAINT fk_booking_seat
        FOREIGN KEY (seat_id)
        REFERENCES Seats(seat_id)
);


/* ============================================================
   6. INSERT FLIGHT DATA
   ============================================================ */

INSERT INTO Flights
(
    flight_number,
    airline_name,
    source_city,
    destination_city,
    departure_datetime,
    arrival_datetime,
    base_fare
)
VALUES
(
    'AR101',
    'Air India',
    'Mumbai',
    'Delhi',
    '2026-09-05 08:00:00',
    '2026-09-05 10:15:00',
    5500.00
),
(
    'AR102',
    'IndiGo',
    'Mumbai',
    'Bangalore',
    '2026-09-05 11:30:00',
    '2026-09-05 13:10:00',
    4200.00
),
(
    'AR103',
    'Vistara',
    'Delhi',
    'Mumbai',
    '2026-09-06 09:00:00',
    '2026-09-06 11:15:00',
    5800.00
),
(
    'AR104',
    'IndiGo',
    'Bangalore',
    'Delhi',
    '2026-09-06 14:00:00',
    '2026-09-06 16:45:00',
    5000.00
),
(
    'AR105',
    'Air India',
    'Mumbai',
    'Chennai',
    '2026-09-07 18:00:00',
    '2026-09-07 20:00:00',
    4600.00
);


/* ============================================================
   7. INSERT CUSTOMER DATA
   ============================================================ */

INSERT INTO Customers
(
    full_name,
    email,
    phone
)
VALUES
(
    'Rahul Sharma',
    'rahul.sharma@example.com',
    '9876500001'
),
(
    'Priya Patil',
    'priya.patil@example.com',
    '9876500002'
),
(
    'Amit Kumar',
    'amit.kumar@example.com',
    '9876500003'
),
(
    'Sneha Joshi',
    'sneha.joshi@example.com',
    '9876500004'
),
(
    'Arjun Mehta',
    'arjun.mehta@example.com',
    '9876500005'
),
(
    'Neha Singh',
    'neha.singh@example.com',
    '9876500006'
);


/* ============================================================
   8. INSERT SEAT DATA
   6 SEATS FOR EACH FLIGHT
   1A, 1B = BUSINESS
   2A, 2B, 3A, 3B = ECONOMY
   ============================================================ */

INSERT INTO Seats
(
    flight_id,
    seat_number,
    seat_class
)
VALUES
/* Flight 1 - AR101 */
(1, '1A', 'Business'),
(1, '1B', 'Business'),
(1, '2A', 'Economy'),
(1, '2B', 'Economy'),
(1, '3A', 'Economy'),
(1, '3B', 'Economy'),

/* Flight 2 - AR102 */
(2, '1A', 'Business'),
(2, '1B', 'Business'),
(2, '2A', 'Economy'),
(2, '2B', 'Economy'),
(2, '3A', 'Economy'),
(2, '3B', 'Economy'),

/* Flight 3 - AR103 */
(3, '1A', 'Business'),
(3, '1B', 'Business'),
(3, '2A', 'Economy'),
(3, '2B', 'Economy'),
(3, '3A', 'Economy'),
(3, '3B', 'Economy'),

/* Flight 4 - AR104 */
(4, '1A', 'Business'),
(4, '1B', 'Business'),
(4, '2A', 'Economy'),
(4, '2B', 'Economy'),
(4, '3A', 'Economy'),
(4, '3B', 'Economy'),

/* Flight 5 - AR105 */
(5, '1A', 'Business'),
(5, '1B', 'Business'),
(5, '2A', 'Economy'),
(5, '2B', 'Economy'),
(5, '3A', 'Economy'),
(5, '3B', 'Economy');


/* ============================================================
   9. TRIGGER - BEFORE BOOKING
   Checks whether seat is available.
   Calculates booking amount based on seat class.
   ============================================================ */

DELIMITER $$

CREATE TRIGGER trg_before_booking_insert
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN

    DECLARE v_status VARCHAR(20);
    DECLARE v_class VARCHAR(20);
    DECLARE v_base_fare DECIMAL(10,2);

    /* Get seat information */
    SELECT
        s.seat_status,
        s.seat_class,
        f.base_fare
    INTO
        v_status,
        v_class,
        v_base_fare
    FROM Seats s
    JOIN Flights f
        ON s.flight_id = f.flight_id
    WHERE s.seat_id = NEW.seat_id;

    /* Check whether seat exists */
    IF v_status IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid seat selected';

    /* Check whether seat is available */
    ELSEIF v_status <> 'Available' THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Selected seat is not available';

    ELSE

        /* Calculate amount */
        IF v_class = 'Business' THEN

            SET NEW.total_amount = v_base_fare * 1.50;

        ELSE

            SET NEW.total_amount = v_base_fare;

        END IF;

        /* Set booking status */
        SET NEW.booking_status = 'Confirmed';

    END IF;

END$$


/* ============================================================
   10. TRIGGER - AFTER BOOKING
   Changes seat status to Booked.
   ============================================================ */

CREATE TRIGGER trg_after_booking_insert
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN

    UPDATE Seats
    SET seat_status = 'Booked'
    WHERE seat_id = NEW.seat_id;

END$$


/* ============================================================
   11. TRIGGER - AFTER BOOKING UPDATE
   Cancelled booking -> seat becomes Available
   Confirmed booking -> seat becomes Booked
   ============================================================ */

CREATE TRIGGER trg_after_booking_update
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN

    /* Confirmed -> Cancelled */
    IF OLD.booking_status = 'Confirmed'
       AND NEW.booking_status = 'Cancelled' THEN

        UPDATE Seats
        SET seat_status = 'Available'
        WHERE seat_id = NEW.seat_id;

    /* Cancelled -> Confirmed */
    ELSEIF OLD.booking_status = 'Cancelled'
       AND NEW.booking_status = 'Confirmed' THEN

        UPDATE Seats
        SET seat_status = 'Booked'
        WHERE seat_id = NEW.seat_id;

    END IF;

END$$

DELIMITER ;


/* ============================================================
   12. INSERT INITIAL BOOKINGS
   ============================================================ */

INSERT INTO Bookings
(
    customer_id,
    seat_id
)
VALUES
(1, 1),
(2, 3),
(3, 7),
(4, 9),
(5, 13),
(6, 19);


/* ============================================================
   13. VIEW - FLIGHT AVAILABILITY
   Shows total seats, available seats and booked seats.
   ============================================================ */

CREATE OR REPLACE VIEW vw_flight_availability AS
SELECT
    f.flight_id,
    f.flight_number,
    f.airline_name,
    f.source_city,
    f.destination_city,
    f.departure_datetime,
    f.arrival_datetime,

    COUNT(s.seat_id) AS total_seats,

    SUM(
        CASE
            WHEN s.seat_status = 'Available'
            THEN 1
            ELSE 0
        END
    ) AS available_seats,

    SUM(
        CASE
            WHEN s.seat_status = 'Booked'
            THEN 1
            ELSE 0
        END
    ) AS booked_seats

FROM Flights f
JOIN Seats s
    ON f.flight_id = s.flight_id

GROUP BY
    f.flight_id,
    f.flight_number,
    f.airline_name,
    f.source_city,
    f.destination_city,
    f.departure_datetime,
    f.arrival_datetime;


/* ============================================================
   14. VIEW - BOOKING SUMMARY
   Combines customer, flight, seat and booking information.
   ============================================================ */

CREATE OR REPLACE VIEW vw_booking_summary AS
SELECT

    b.booking_id,

    c.full_name AS customer_name,

    c.email,

    f.flight_number,

    f.airline_name,

    f.source_city,

    f.destination_city,

    f.departure_datetime,

    f.arrival_datetime,

    s.seat_number,

    s.seat_class,

    b.booking_date,

    b.booking_status,

    b.total_amount

FROM Bookings b

JOIN Customers c
    ON b.customer_id = c.customer_id

JOIN Seats s
    ON b.seat_id = s.seat_id

JOIN Flights f
    ON s.flight_id = f.flight_id;


/* ============================================================
   15. BASIC VERIFICATION
   ============================================================ */

SELECT DATABASE();


SELECT *
FROM Flights;


SELECT *
FROM Customers;


SELECT *
FROM Seats;


SELECT *
FROM Bookings;


/* ============================================================
   16. SEARCH FLIGHT
   Mumbai -> Delhi
   ============================================================ */

SELECT

    flight_number,
    airline_name,
    source_city,
    destination_city,
    departure_datetime,
    arrival_datetime,
    base_fare

FROM Flights

WHERE source_city = 'Mumbai'
  AND destination_city = 'Delhi';


/* ============================================================
   17. SHOW AVAILABLE SEATS
   ============================================================ */

SELECT

    f.flight_number,
    f.source_city,
    f.destination_city,
    s.seat_number,
    s.seat_class,
    s.seat_status

FROM Flights f

JOIN Seats s
    ON f.flight_id = s.flight_id

WHERE s.seat_status = 'Available'

ORDER BY
    f.flight_number,
    s.seat_id;


/* ============================================================
   18. SHOW FLIGHT AVAILABILITY VIEW
   ============================================================ */

SELECT *
FROM vw_flight_availability;


/* ============================================================
   19. SHOW BOOKING SUMMARY VIEW
   ============================================================ */

SELECT *
FROM vw_booking_summary
ORDER BY booking_id;


/* ============================================================
   20. DEMONSTRATE BOOKING CANCELLATION
   Booking #2 is cancelled.
   Trigger automatically makes Seat #3 Available.
   ============================================================ */

UPDATE Bookings

SET booking_status = 'Cancelled'

WHERE booking_id = 2;


/* Check cancelled booking */

SELECT *

FROM Bookings

WHERE booking_id = 2;


/* Check seat after cancellation */

SELECT
    seat_id,
    flight_id,
    seat_number,
    seat_class,
    seat_status

FROM Seats

WHERE seat_id = 3;


/* ============================================================
   21. RE-BOOK THE CANCELLED SEAT
   Seat #3 is available again, so it can be booked.
   ============================================================ */

INSERT INTO Bookings
(
    customer_id,
    seat_id
)

VALUES
(
    2,
    3
);


/* ============================================================
   22. VERIFY NEW BOOKING
   ============================================================ */

SELECT *

FROM Bookings

ORDER BY booking_id DESC

LIMIT 1;


/* ============================================================
   23. VERIFY SEAT IS BOOKED AGAIN
   ============================================================ */

SELECT

    seat_id,
    flight_id,
    seat_number,
    seat_class,
    seat_status

FROM Seats

WHERE seat_id = 3;


/* ============================================================
   24. FINAL BOOKING SUMMARY
   ============================================================ */

SELECT *

FROM vw_booking_summary

ORDER BY booking_id;


/* ============================================================
   25. FINAL FLIGHT AVAILABILITY
   ============================================================ */

SELECT *

FROM vw_flight_availability;


/* ============================================================
   END OF AIRLINE RESERVATION SYSTEM
   ============================================================ */
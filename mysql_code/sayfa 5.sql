-- INSERT(x5), DELETE(x5), UPDATE(x5) 

INSERT INTO AIRPLANE VALUES('00000014', 'Airbus', 84, 'Air-007');
INSERT INTO FLIGHT VALUES ('AJ-2', 'Anadolu Jet', 'Pazartesi');
INSERT INTO FARE VALUES ('AJ-2', 'P-00000081', '122.25', 'Ekonomi');
INSERT INTO FLIGHT_LEG VALUES ('AJ-2', 'AJ-27786', 'SAW', '18:00:00', 'ESB', '18:55:00', 460);
INSERT INTO LEG_INSTANCE VALUES ('AJ-2', 'AJ-27786', '2001-11-01', 83, '00000014', 'SAW', 'ESB', '18:00:00', '18:55:00');

UPDATE LEG_INSTANCE 
SET Departure_time='12:00:00', Arrival_time='13:00:00'
WHERE Flight_number = 'XQ-5' AND Leg_number='XQ-53114' AND Flight_date = '2001-05-01';

UPDATE AIRPLANE_COMPANY 
SET Company_name='ASTON Martin' 
WHERE Company_name='Lockheed Martin';

UPDATE AIRPLANE_TYPE
SET Max_seats = 159
WHERE Airplane_type_name='DGK-0' AND Company = 'TUSAŞ';

UPDATE CUSTOMER 
SET Customer_phone = 905546591223
WHERE Passport_number='13545123523';

UPDATE SEAT_RESERVATION
SET Seat_number=6
WHERE Flight_number = 'TK-7' AND Leg_number = 'TK-74915' AND Flight_date = '2001-09-30' AND Seat_number = 27;

DELETE FROM AIRPLANE_COMPANY WHERE Company_name = 'Saab';
DELETE FROM CUSTOMER WHERE Passport_number = 92545128973;
DELETE FROM FFC_SERVICE WHERE Membership_no= 1 ;
DELETE FROM SEAT_RESERVATION WHERE Passport_number='13545123523' AND Flight_date = '2001-08-21';
DELETE FROM CUSTOMER_FLIGHT_RECORDS WHERE Passport_number='23545123523' AND Flight_date = '2001-08-25';

-- 2 TABLE SELECT (x3)

-- Customers that have FFC Service and mileage above 6000
SELECT CUSTOMER.Customer_name, CUSTOMER.Customer_phone, FFC_SERVICE.Mileage
FROM CUSTOMER, FFC_SERVICE
WHERE CUSTOMER.Passport_number = FFC_SERVICE.Customer_Passport AND FFC_SERVICE.Mileage > 6000
ORDER BY FFC_SERVICE.Mileage;

-- Number of departure flights in each airport
SELECT AIRPORT.Airport_name, COUNT(*)
AS Number_Of_Flights
FROM AIRPORT, LEG_INSTANCE
WHERE  AIRPORT.Airport_code = LEG_INSTANCE.Departure_airport_code
GROUP BY Airport_name;

-- A table for reserved seat's owner and owner's phone number
SELECT SEAT_RESERVATION.Seat_number, CUSTOMER.Customer_name, CUSTOMER.Customer_phone
FROM CUSTOMER, SEAT_RESERVATION
WHERE CUSTOMER.Passport_number =  SEAT_RESERVATION.Passport_number
ORDER BY CUSTOMER.Customer_name;

-- 3 TABLE SELECT (x4)

-- A comparion of scheduled departure times and real departure times in an airport
SELECT AIRPORT.Airport_name, LEG_INSTANCE.Departure_time, FLIGHT_LEG.Scheduled_departure_time
FROM AIRPORT, LEG_INSTANCE, FLIGHT_LEG
WHERE AIRPORT.Airport_code = LEG_INSTANCE.Departure_airport_code AND AIRPORT.Airport_code = FLIGHT_LEG.Departure_airport_code
ORDER BY AIRPORT.Airport_name;

-- Each airplane id's total of fare amounts
SELECT DISTINCT AIRPLANE.Airplane_id, LEG_INSTANCE.Flight_number, LEG_INSTANCE.Leg_number, LEG_INSTANCE.Flight_date, SUM(FARE.Amount) AS Total_Amount
FROM AIRPLANE, LEG_INSTANCE, FARE
WHERE AIRPLANE.Airplane_id = LEG_INSTANCE.Airplane_id AND FARE.Flight_number = LEG_INSTANCE.Flight_number
GROUP BY AIRPLANE.Airplane_id
ORDER BY Total_Amount DESC;

-- Each customer's amount of prices that they paid
SELECT CUSTOMER.Customer_name, SUM(FARE.Amount)
AS Sum_Of_Payments
FROM CUSTOMER, SEAT_RESERVATION, FARE
WHERE CUSTOMER.Passport_number = SEAT_RESERVATION.Passport_number AND SEAT_RESERVATION.Fare_code = FARE.Fare_code
GROUP BY CUSTOMER.Customer_name
ORDER BY Sum_Of_Payments DESC;

-- Each weekday that an airplane departures from İzmir
SELECT DISTINCT FLIGHT.Week_days
FROM FLIGHT, LEG_INSTANCE, AIRPORT
WHERE FLIGHT.Flight_number = LEG_INSTANCE.Flight_number AND AIRPORT.Airport_code = LEG_INSTANCE.Departure_airport_code AND AIRPORT.City = 'İzmir';

-- 4 TABLE SELECT (x3)

-- Money spent at each airport.
SELECT AIRPORT.Airport_name, SUM(FARE.Amount) as Total_Amount
FROM AIRPORT, FLIGHT_LEG, FLIGHT, FARE
WHERE AIRPORT.Airport_code = FLIGHT_LEG.Departure_airport_code AND FLIGHT_LEG.Flight_number = FLIGHT.Flight_number AND FLIGHT.Flight_number = FARE.Flight_number
GROUP BY AIRPORT.Airport_name
ORDER BY Total_Amount DESC;

-- Each customers number of being at an airport
SELECT AIRPORT.Airport_name, CUSTOMER.Customer_name, COUNT(*)
FROM CUSTOMER, SEAT_RESERVATION, LEG_INSTANCE, AIRPORT
WHERE CUSTOMER.Passport_number = SEAT_RESERVATION.Passport_number AND SEAT_RESERVATION.Leg_number = LEG_INSTANCE.Leg_number AND SEAT_RESERVATION.Flight_number = LEG_INSTANCE.Flight_number AND
LEG_INSTANCE.Departure_airport_code = AIRPORT.Airport_code
GROUP BY CUSTOMER.Customer_name
ORDER BY CUSTOMER.Customer_name;

-- Each customers total amount of miles traveled.
SELECT CUSTOMER.Customer_name, SUM(FLIGHT_LEG.Miles) As Mileage
FROM CUSTOMER, SEAT_RESERVATION, LEG_INSTANCE, FLIGHT_LEG
WHERE CUSTOMER.Passport_number = SEAT_RESERVATION.Passport_number AND SEAT_RESERVATION.Leg_number = LEG_INSTANCE.Leg_number AND SEAT_RESERVATION.Flight_number = LEG_INSTANCE.Flight_number AND
SEAT_RESERVATION.Flight_number = FLIGHT_LEG.Flight_number
GROUP BY CUSTOMER.Customer_name
ORDER BY Mileage DESC;

-- NESTED SELECT (x4)

-- Each airline that have business restriction for a flight.
SELECT DISTINCT FLIGHT.Airline
FROM FLIGHT
WHERE Airline IN ( SELECT FLIGHT.Airline
              FROM FARE, FLIGHT
              WHERE FLIGHT.Flight_number = FARE.Flight_number AND FARE.Restrictions = 'Business');

-- Number of foreigners in each flight
SELECT SEAT_RESERVATION.Leg_number, SEAT_RESERVATION.Flight_date, COUNT(*)
AS Number_Of_Foreigners
FROM SEAT_RESERVATION
WHERE Passport_number IN   (SELECT Passport_Number
									FROM CUSTOMER
									WHERE NOT Country = 'Türkiye')
GROUP BY SEAT_RESERVATION.Leg_number, SEAT_RESERVATION.Flight_date;

-- AIR-007 type airplane's every leg instance information that departures from İstanbul
SELECT LEG_INSTANCE.Leg_number, LEG_INSTANCE.Flight_date
FROM   AIRPLANE, LEG_INSTANCE
WHERE  LEG_INSTANCE.Airplane_id = AIRPLANE.Airplane_id 
		AND AIRPLANE.Airplane_type_name = 'Air-007'	AND LEG_INSTANCE.Flight_number IN (SELECT DISTINCT LEG_INSTANCE.Flight_number
																						FROM LEG_INSTANCE, AIRPORT
																						WHERE AIRPORT.Airport_code = LEG_INSTANCE.Departure_airport_code AND AIRPORT.City = 'İstanbul');

-- Leg instances that has fare amount higher than 150
SELECT SEAT_RESERVATION.Leg_number
FROM SEAT_RESERVATION
WHERE Fare_code IN (SELECT FARE.Fare_code 
            FROM FARE
            WHERE FARE.Amount > 150);

-- EXISTS SELECT (x2)

-- Every customer that is not in FFC service.
SELECT Customer_name, Passport_number
FROM CUSTOMER
WHERE NOT EXISTS (SELECT Customer_passport
		       FROM FFC_Service
		       WHERE FFC_Service.Customer_passport = CUSTOMER.Passport_number);

-- Airplane companies that have their airplane's flight from İstanbul
SELECT DISTINCT AIRPLANE_TYPE.Company
FROM AIRPLANE_TYPE
WHERE EXISTS( SELECT LEG_INSTANCE.Airplane_id
		FROM LEG_INSTANCE
		WHERE LEG_INSTANCE.Departure_airport_code = 'IST');

-- LEFT, RIGHT and FULL OUTER JOIN SELECT

SELECT AIRPLANE_TYPE.Airplane_type_name, AIRPLANE.Airplane_id
FROM AIRPLANE_TYPE
LEFT OUTER JOIN AIRPLANE ON AIRPLANE_TYPE.Airplane_type_name = AIRPLANE.Airplane_type_name
ORDER BY AIRPLANE_TYPE.Airplane_type_name;

SELECT CUSTOMER.Customer_name, FFC_SERVICE.Membership_no
FROM FFC_SERVICE
RIGHT OUTER JOIN CUSTOMER ON CUSTOMER.Passport_number = FFC_SERVICE.Customer_passport
ORDER BY CUSTOMER.Customer_name;

(SELECT CUSTOMER_FLIGHT_RECORDS.Record_no, FFC_SERVICE.Membership_no
FROM CUSTOMER_FLIGHT_RECORDS
LEFT OUTER JOIN FFC_SERVICE ON CUSTOMER_FLIGHT_RECORDS.Passport_number = FFC_SERVICE.Customer_passport)
UNION
(SELECT CUSTOMER_FLIGHT_RECORDS.Record_no, FFC_SERVICE.Membership_no
FROM FFC_SERVICE
RIGHT OUTER JOIN CUSTOMER_FLIGHT_RECORDS ON CUSTOMER_FLIGHT_RECORDS.Passport_number = FFC_SERVICE.Customer_passport);

-- VIEW (x5)

-- Number Of Airplane Types That Can Land To Airports
CREATE VIEW Number_Of_Airplane_Types_That_Can_Land_To_Airports 
AS SELECT AIRPORT.Airport_name, COUNT(*) AS Number_of_airplane_types
	FROM AIRPORT, CAN_LAND
	WHERE AIRPORT.Airport_code = CAN_LAND.Airport_code
	GROUP BY AIRPORT.Airport_name;

-- Extended Version Of FFC Servie
CREATE VIEW Extended_FFC
AS SELECT CUSTOMER.Passport_number, CUSTOMER.Customer_name, CUSTOMER.E_mail, CUSTOMER.Customer_phone, FFC_SERVICE.Membership_no, FFC_SERVICE.Mileage
	FROM FFC_SERVICE, CUSTOMER
	WHERE CUSTOMER.Passport_number = FFC_SERVICE.Customer_passport;

-- Extended Version Of Flight
CREATE VIEW Flight_with_price
AS SELECT FLIGHT.Flight_number, FLIGHT.Airline, FARE.Amount, FARE.Restrictions
	FROM FLIGHT,FARE
	WHERE FLIGHT.Flight_number = FARE.Flight_number;

-- Number Of Customers in a Leg Instance
CREATE VIEW Flight_Instance (Leg_Instance, Number_of_customers)
AS SELECT LEG_INSTANCE.Leg_number, COUNT(*)
	FROM LEG_INSTANCE, SEAT_RESERVATION
	WHERE LEG_INSTANCE.Leg_number = SEAT_RESERVATION.Leg_number AND LEG_INSTANCE.Flight_date = SEAT_RESERVATION.Flight_date
	GROUP BY LEG_INSTANCE.Leg_number;

-- Customer Flight Records With Fare Amounts
CREATE VIEW Customer_flight_records_with_fare_amounts 
AS SELECT CUSTOMER_FLIGHT_RECORDS.Record_no, CUSTOMER.Customer_name, CUSTOMER_FLIGHT_RECORDS.Leg_number, CUSTOMER_FLIGHT_RECORDS.Flight_date, FARE.Amount as Fare_amount
	FROM CUSTOMER, CUSTOMER_FLIGHT_RECORDS, FARE
    WHERE CUSTOMER.Passport_number = CUSTOMER_FLIGHT_RECORDS.Passport_number AND CUSTOMER_FLIGHT_RECORDS.Fare_code = FARE.Fare_code
    ORDER BY CUSTOMER_FLIGHT_RECORDS.Record_no;

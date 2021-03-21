-- CREATING THE DATABASE AND ITS TABLES

CREATE DATABASE proje;

USE proje;

CREATE TABLE AIRPORT
(Airport_code 	CHAR(3) 		NOT NULL,
Airport_name 	VARCHAR(40),
City 			VARCHAR(20),
State 			VARCHAR(20),

PRIMARY KEY(Airport_code)
);

CREATE TABLE AIRPLANE_COMPANY
(Company_name 	VARCHAR(30) 	NOT NULL,

PRIMARY KEY(Company_name)
);

CREATE TABLE AIRLINE_COMPANY
(Company_name 	VARCHAR(30) 	NOT NULL,

PRIMARY KEY(Company_name)
);

CREATE TABLE AIRPLANE_TYPE
(Airplane_type_name 	VARCHAR(20) 	NOT NULL,
Company 				VARCHAR(40),
Max_seats 				INT				DEFAULT 150,

PRIMARY KEY(Airplane_type_name),

FOREIGN KEY(Company) REFERENCES AIRPLANE_COMPANY(Company_name) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE CAN_LAND
(Airport_code 		CHAR(3),
Airplane_type_name 	VARCHAR(20),

PRIMARY KEY(Airport_code, Airplane_type_name),

FOREIGN KEY(Airport_code) 		REFERENCES AIRPORT(Airport_code) ON DELETE NO ACTION ON UPDATE CASCADE,
FOREIGN KEY(Airplane_type_name) REFERENCES AIRPLANE_TYPE(Airplane_type_name) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE AIRPLANE
(Airplane_id 			VARCHAR(20) 	NOT NULL,
Company 				VARCHAR(40),
Total_number_of_seats 	INT 			DEFAULT 150,
Airplane_type_name 		VARCHAR(20),

PRIMARY KEY(Airplane_id),

FOREIGN KEY(Company) 			REFERENCES AIRPLANE_COMPANY(Company_name) ON DELETE NO ACTION ON UPDATE CASCADE,
FOREIGN KEY(Airplane_type_name) REFERENCES AIRPLANE_TYPE(Airplane_type_name) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE FLIGHT
(Flight_number 	CHAR(4) 		NOT NULL,
Airline			VARCHAR(30),
Week_days 		VARCHAR(10),

PRIMARY KEY(Flight_number),

FOREIGN KEY(Airline) REFERENCES AIRLINE_COMPANY(Company_name) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE FARE
(Flight_number 	CHAR(4),
Fare_code 		CHAR(10) 		NOT NULL,
Amount 			DECIMAL(6,2) 	NOT NULL,
Restrictions 	VARCHAR(10)		DEFAULT 'Ekonomi',

PRIMARY KEY(Flight_number, Fare_code),

FOREIGN KEY(Flight_number) REFERENCES FLIGHT(Flight_number) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE FLIGHT_LEG
(Flight_number 				CHAR(4),
Leg_number 					VARCHAR(10) 	NOT NULL,
Departure_airport_code 		CHAR(3),
Scheduled_departure_time 	TIME			NOT NULL,
Arrival_airport_code 		CHAR(3),
Scheduled_arrival_time 		TIME			NOT NULL,
Miles 						INT 			NOT NULL,

PRIMARY KEY(Flight_number, Leg_number),

FOREIGN KEY(Flight_number) 			REFERENCES FLIGHT(Flight_number) ON DELETE NO ACTION ON UPDATE CASCADE,
FOREIGN KEY(Departure_airport_code) REFERENCES AIRPORT(Airport_code) ON DELETE NO ACTION ON UPDATE CASCADE,
FOREIGN KEY(Arrival_airport_code) 	REFERENCES AIRPORT(Airport_code) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE LEG_INSTANCE
(Flight_number 				CHAR(4),
Leg_number 					VARCHAR(10),
Flight_date					DATE 			NOT NULL,
Number_of_available_seats	INT				DEFAULT 150,
Airplane_id 				VARCHAR(20),
Departure_airport_code 		CHAR(3),
Arrival_airport_code 		CHAR(3),
Departure_time 				TIME	 		NOT NULL,
Arrival_time 				TIME	 		NOT NULL,

PRIMARY KEY(Flight_number, Leg_number, Flight_date),

FOREIGN KEY(Flight_number, Leg_number) 		REFERENCES FLIGHT_LEG(Flight_number, Leg_number) ON DELETE NO ACTION ON UPDATE CASCADE,
FOREIGN KEY(Airplane_id) 					REFERENCES AIRPLANE(Airplane_id) ON DELETE NO ACTION ON UPDATE CASCADE,
FOREIGN KEY(Departure_airport_code) 		REFERENCES AIRPORT(Airport_code) ON DELETE NO ACTION ON UPDATE CASCADE,
FOREIGN KEY(Arrival_airport_code) 			REFERENCES AIRPORT(Airport_code) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE CUSTOMER
(Passport_number 	CHAR(11) 		NOT NULL,
Customer_name 		VARCHAR(30) 	NOT NULL,
Customer_phone		VARCHAR(20) 	NOT NULL,
Country				VARCHAR(20)		NOT NULL,
E_mail 				VARCHAR(30),
Address 			VARCHAR(50),
Flight_count 		INT		 		DEFAULT 0,

PRIMARY KEY(Passport_number)
);

CREATE TABLE SEAT_RESERVATION
(Flight_number 				CHAR(4),
Leg_number 					VARCHAR(10),
Flight_date					DATE,
Seat_number					INT				NOT NULL,
Passport_number		 		CHAR(11),
Fare_code 					CHAR(10),

PRIMARY KEY(Flight_number, Leg_number, Flight_date, Fare_code, Seat_number),

FOREIGN KEY(Flight_number, Leg_number, Flight_date) 	REFERENCES LEG_INSTANCE(Flight_number, Leg_number, Flight_date) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(Passport_number) 							REFERENCES CUSTOMER(Passport_number) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(Flight_number, Fare_code) 					REFERENCES FARE(Flight_number, Fare_code) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE CHECK_IN
(Passport_number		 	CHAR(11),
Flight_number 				CHAR(4),
Leg_number 					VARCHAR(10),
Flight_date					DATE,
Is_physical					INT 			DEFAULT 1,

PRIMARY KEY(Passport_number, Flight_number, Leg_number, Flight_date),

FOREIGN KEY(Passport_number) 							REFERENCES CUSTOMER(Passport_number) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(Flight_number, Leg_number, Flight_date) 	REFERENCES LEG_INSTANCE(Flight_number, Leg_number, Flight_date) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE CUSTOMER_FLIGHT_RECORDS
(Record_no					INT 			AUTO_INCREMENT,
Passport_number			 	CHAR(11),
Flight_number 				CHAR(4),
Leg_number 					VARCHAR(10),
Flight_date					DATE,
Fare_code 					CHAR(10),
Seat_number					INT				NOT NULL,

PRIMARY KEY(Record_no, Passport_number),

FOREIGN KEY(Passport_number) 													REFERENCES CUSTOMER(Passport_number) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(Flight_number, Leg_number, Flight_date, Fare_code, Seat_number) 	REFERENCES SEAT_RESERVATION(Flight_number, Leg_number, Flight_date, Fare_code, Seat_number) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE FFC_SERVICE
(Membership_no	 	INT				AUTO_INCREMENT,
Mileage				INT				NOT NULL,
Customer_passport 	CHAR(11) 		NOT NULL,
Membership_type 	VARCHAR(10)		NOT NULL,		

PRIMARY KEY(Membership_no),

FOREIGN KEY(Customer_passport) 	REFERENCES CUSTOMER(Passport_number) ON DELETE CASCADE ON UPDATE CASCADE
);

-- CHECK CONSTRAINTS

ALTER TABLE FARE ADD CONSTRAINT fare_restrictions_list
CHECK (Restrictions IN ('Ekonomi', 'Business')
);

ALTER TABLE FARE ADD CONSTRAINT fare_amount_list
CHECK (Amount > 50
);

ALTER TABLE FLIGHT ADD CONSTRAINT flight_week_days_list
CHECK (Week_days IN ('Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar')
);

ALTER TABLE AIRLINE_COMPANY ADD CONSTRAINT airline_company_name_list
CHECK (Company_name IN ('Türk Hava Yolları', 'Pegasus', 'Anadolu Jet', 'SunExpress', 'Onur Air')
);

ALTER TABLE AIRPORT ADD CONSTRAINT airport_code_list
CHECK (Airport_code IN ('ADB', 'SAW', 'ESB', 'DLM', 'IST')
);

-- TRIGGERS

-- Creating a customer flight record after that customer checked in a flight physically.

DELIMITER &&
CREATE TRIGGER create_customer_flight_records 
    AFTER INSERT ON CHECK_IN
	FOR EACH ROW
BEGIN
		IF NEW.Is_physical = 1 THEN 
			INSERT INTO CUSTOMER_FLIGHT_RECORDS(Passport_number, Flight_number, Leg_number, Flight_date, Fare_code, Seat_number) 
            VALUES (NEW.Passport_number, NEW.Flight_number, NEW.Leg_number, NEW.Flight_date , (SELECT SEAT_RESERVATION.Fare_code
																								FROM SEAT_RESERVATION
																								WHERE NEW.Leg_number = SEAT_RESERVATION.Leg_number AND
																									  NEW.Flight_number = SEAT_RESERVATION.Flight_number AND
                                                                                                      NEW.Flight_date = SEAT_RESERVATION.Flight_date AND
                                                                                                      NEW.Passport_number = SEAT_RESERVATION.Passport_number),
                                                                                                
																								(SELECT SEAT_RESERVATION.Seat_number
																								FROM SEAT_RESERVATION
																								WHERE NEW.Leg_number = SEAT_RESERVATION.Leg_number AND
																									  NEW.Flight_number = SEAT_RESERVATION.Flight_number AND
                                                                                                      NEW.Flight_date = SEAT_RESERVATION.Flight_date AND
                                                                                                      NEW.Passport_number = SEAT_RESERVATION.Passport_number));
		END IF;   
END&&
DELIMITER ;

-- After a custermer flight record created, adding 1 to that customer's customer flight count .

DELIMITER &&
CREATE TRIGGER flight_count_update 
    BEFORE INSERT ON CUSTOMER_FLIGHT_RECORDS
	FOR EACH ROW
BEGIN
			UPDATE CUSTOMER
			SET CUSTOMER.Flight_count = CUSTOMER.Flight_count + 1
			WHERE CUSTOMER.Passport_number = NEW.Passport_number;  
END&&
DELIMITER ;

-- Creating a FFC Service membership when a customer have 5 customer flight record.

DELIMITER &&
CREATE TRIGGER create_ffc 
    AFTER INSERT ON CUSTOMER_FLIGHT_RECORDS
	FOR EACH ROW
BEGIN
		IF (SELECT CUSTOMER.Flight_count
			FROM CUSTOMER
			WHERE NEW.Passport_number = CUSTOMER.Passport_number) = 5 THEN 
            
			INSERT INTO FFC_SERVICE(Customer_passport, Mileage, Membership_type) VALUES (NEW.Passport_number, (SELECT SUM(Miles) FROM FLIGHT_LEG WHERE Miles IN (SELECT FLIGHT_LEG.Miles
																							                                                    FROM FLIGHT_LEG, CUSTOMER_FLIGHT_RECORDS
																																				WHERE NEW.Passport_number = CUSTOMER_FLIGHT_RECORDS.Passport_number AND
																																						CUSTOMER_FLIGHT_RECORDS.Flight_number = FLIGHT_LEG.Flight_number AND
																																						CUSTOMER_FLIGHT_RECORDS.Leg_number = FLIGHT_LEG.Leg_number)), 'Normal');
            
		END IF;
END&&
DELIMITER ;

-- Updating a FFC Service member's mileage after a customer flight record created for that member.

DELIMITER &&
CREATE TRIGGER updating_the_ffc_mileage 
    AFTER INSERT ON CUSTOMER_FLIGHT_RECORDS
	FOR EACH ROW
BEGIN
		IF (SELECT CUSTOMER.Flight_count
			FROM CUSTOMER
			WHERE NEW.Passport_number = CUSTOMER.Passport_number) > 5 THEN 
            
			UPDATE FFC_Service
			SET FFC_Service.Mileage = FFC_Service.Mileage + (SELECT FLIGHT_LEG.Miles
															FROM FLIGHT_LEG
															WHERE NEW.Leg_number = FLIGHT_LEG.Leg_number AND
																NEW.Flight_number = FLIGHT_LEG.Flight_number)
			WHERE FFC_Service.Customer_passport = NEW.Passport_number;
        END IF; 
        
        UPDATE FFC_SERVICE
		SET Membership_type = 'Gold'
		WHERE Mileage > 7000 AND FFC_Service.Customer_passport = NEW.Passport_number; 
END&&
DELIMITER ;

-- Number_of_available_seats -= 1 (her seat_reservation yapıldığında.)

DELIMITER &&
CREATE TRIGGER available_seat_update 
    AFTER INSERT ON SEAT_RESERVATION
	FOR EACH ROW
BEGIN
		UPDATE LEG_INSTANCE
        JOIN SEAT_RESERVATION ON NEW.Flight_number = LEG_INSTANCE.Flight_number AND NEW.Leg_number = LEG_INSTANCE.Leg_number AND NEW.Flight_date = LEG_INSTANCE.Flight_date
		SET LEG_INSTANCE.Number_of_available_seats = LEG_INSTANCE.Number_of_available_seats - 1;
END&&
DELIMITER ;



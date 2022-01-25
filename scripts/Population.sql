-- CUSTOMERS POPULATION

DECLARE
i INTEGER;
nCustomers INTEGER := 50000;
type nameArray IS VARRAY(12) OF Customers.CName%TYPE;
type sexArray IS VARRAY(2) OF Customers.Sex%TYPE;
type dateArray IS VARRAY(5) OF Customers.DoB%TYPE;
type cityArray IS VARRAY(10) OF Customers.City%TYPE;
cNames nameArray := nameArray('John','Klaire','Luke','Marie','Mike','Lucy','Rick','Nicole','George','Andrea','Karl','Elizabeth');
sexes sexArray := sexArray('M', 'F');
dates dateArray := dateArray('23-MAY-1998','10-FEB-1980','12-JUL-1990','26-DEC-1991','6-SEP-1996');
cities cityArray := cityArray('Rome', 'Milan', 'Florence', 'Bari', 'Turin', 'Venice', 'Verona', 'Palermo', 'Naples', 'Genova');
BEGIN
FOR i IN 1..nCustomers LOOP
    INSERT INTO Customers VALUES (dbms_random.string('X', 16), cNames(1 + MOD(i, 12)), sexes(1 + MOD(i, 2)), TO_DATE(TRUNC(DBMS_RANDOM.VALUE(2451545, 5373484)), 'J'), cities(DBMS_RANDOM.VALUE(1,10)), DBMS_RANDOM.VALUE(3000000000,4000000000), dbms_random.string('l', 8) || '@mail.com');
END LOOP;
END;
/


-- HOTELS POPULATION

DECLARE
i INTEGER;
nHotels INTEGER := 20;
type cityArray IS VARRAY(15) OF Hotels.City%TYPE;
cities cityArray := cityArray('Rome', 'Milan', 'Florence', 'Bari', 'Turin', 'Venice', 'Verona', 'Palermo', 'Naples', 'Genova', 'Ancona', 'Pisa', 'Lecce', 'Cagliari', 'Aosta');
BEGIN
FOR i IN 1..nHotels LOOP
    INSERT INTO Hotels VALUES ('SH' || i, cities(DBMS_RANDOM.VALUE(1,15)));
END LOOP;
END;
/


-- ROOMS POPULATION

DECLARE
i INTEGER;
j INTEGER;
nHotels INTEGER := 20;
nRooms INTEGER := 150;
hotel Rooms.Hotel%TYPE;
type smokersArray IS VARRAY(2) OF Rooms.Smokers%TYPE;
smokers smokersArray := smokersArray('T', 'F');
BEGIN
FOR i IN 1..nHotels LOOP
    SELECT REF(h) into hotel from Hotels h WHERE HName = 'SH' || i;
    FOR j IN 1..nRooms LOOP
        INSERT INTO Rooms VALUES (j, TRUNC(DBMS_RANDOM.VALUE(50, 1500),2), DBMS_RANDOM.VALUE(1,2), smokers(DBMS_RANDOM.VALUE(1,2)), hotel);
    END LOOP;
END LOOP;
END;
/


-- BOOKINGS, RESERVE, INVOICES POPULATION

ALTER TRIGGER bookingCheck DISABLE;
/
SET SERVEROUTPUT OFF;
DECLARE
i INTEGER;
nBookings INTEGER := 150000;
type methodArray IS VARRAY(3) OF Bookings.BookMethod%TYPE;
type parkArray IS VARRAY(2) OF Bookings.Park%TYPE;
met methodArray := methodArray('Phone', 'Mail', 'Website');
park parkArray := parkArray('T', 'F');
d DATE;
cust Customers.FC%TYPE;
room Rooms.Code%TYPE;
hotel INTEGER;
BEGIN
FOR i IN 1..nBookings LOOP
    SELECT FC INTO cust FROM Customers SAMPLE(1) FETCH NEXT 1 ROWS ONLY;
    d := TO_DATE(TRUNC(DBMS_RANDOM.VALUE(2451545, 2460000)), 'J');
    hotel := DBMS_RANDOM.VALUE(1,20);
    room := DBMS_RANDOM.VALUE(1,150);
    recordBooking(100000 + i, met(DBMS_RANDOM.VALUE(1,3)), park(DBMS_RANDOM.VALUE(1,2)), cust, d, d + 2, 'SH' || hotel, room);
    IF (DBMS_RANDOM.VALUE(1,10) <= 9) THEN
        confirmBooking(100000 + i, 'T', NULL);
        printInvoice(100000 + i, 'SH' || hotel, room, 1000000000 + i, TRUNC(DBMS_RANDOM.VALUE(0, 100),2));
    END IF;
END LOOP;
END;
/
ALTER TRIGGER bookingCheck ENABLE;
/

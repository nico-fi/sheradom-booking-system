-- PROCEDURES

CREATE OR REPLACE PROCEDURE recordBooking(bookID INTEGER, met VARCHAR2, park CHAR, custFC CHAR, arr DATE, dep DATE, hotelName VARCHAR2, room INTEGER) AS
res REF ReserveTy;
BEGIN
INSERT INTO Reserve r VALUES (arr, dep, (SELECT REF(r) FROM Rooms r WHERE Code=room AND DEREF(Hotel).HName=hotelName), NULL) RETURNING REF(r) INTO res;
INSERT INTO Bookings VALUES (bookID, met, park, NULL, (SELECT REF(c) FROM Customers c WHERE FC=custFC), NULL, ReserveArray(res));
END;
/
CREATE OR REPLACE PROCEDURE confirmBooking(bookID INTEGER, prepayment CHAR, card INTEGER) AS
BEGIN
UPDATE Bookings SET Confirm=ConfirmTy(prepayment, card) WHERE BookingID=bookID;
END;
/
CREATE OR REPLACE FUNCTION roomAvailability(hotelName VARCHAR2, room INTEGER, startDate DATE, endDate DATE) RETURN VARCHAR2 AS
i INTEGER;
d DATE := startDate;
r REF RoomTy;
results VARCHAR2(30000);
BEGIN
SELECT REF(ro) into r FROM Rooms ro WHERE Code=room AND DEREF(Hotel).HName=hotelName;
WHILE d < endDate LOOP
    SELECT COUNT(*) INTO i FROM Reserve WHERE Room=r AND d >= Arrival AND d < Departure;
    IF i = 0 THEN
        results := results || d || ': Available' || CHR(10);
    ELSE
        results := results || d || ': Not Available' || CHR(10);
    END IF;
    d := d + 1;
END LOOP;
RETURN results;
END;
/
CREATE OR REPLACE PROCEDURE confirmArrival(bookID INTEGER) AS
BEGIN
UPDATE Bookings SET CheckIn=SYSDATE WHERE BookingID=bookID;
END;
/
CREATE OR REPLACE PROCEDURE printInvoice(bookID INTEGER, hotelName VARCHAR2, roomCode INTEGER, transID INTEGER, additional NUMBER) AS
i INTEGER;
x INTEGER;
rList ReserveArray;
roomCost Invoices.Total%TYPE;
inv InvoiceTy;
iRef REF InvoiceTy;
BEGIN
SELECT ReserveList INTO rList FROM Bookings WHERE BookingID=bookID;
FOR i IN 1..rList.COUNT LOOP
    SELECT COUNT(*) INTO x FROM DUAL WHERE DEREF(DEREF(rList(i)).Room).Code=roomCode AND DEREF(DEREF(DEREF(rList(i)).Room).Hotel).HName=hotelName;
    IF x <> 0 THEN
        SELECT DEREF(rList(i)).getRoomCost() INTO roomCost FROM DUAL;
        inv := InvoiceTy(transID, roomCost + additional, 'Room: ' || roomCost || ' Additional: ' || additional);
        INSERT INTO Invoices v VALUES inv RETURNING REF(v) INTO iRef;
        UPDATE Reserve res SET Invoice=iRef WHERE REF(res)=rList(i);
        DBMS_OUTPUT.PUT_LINE(hotelName || ':' || roomCode || ' ' || inv.Balance);
    END IF;
END LOOP;
IF inv IS NULL THEN
    RAISE_APPLICATION_ERROR(-20995, 'Wrong data');
END IF;    
END;
/
CREATE OR REPLACE PROCEDURE unpaidCustomers AS
CURSOR cur IS SELECT * FROM Bookings WHERE Confirm IS NULL;
c CustomerTy;
BEGIN
FOR b in cur LOOP
    SELECT DEREF(b.Customer) INTO c FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(c.FC || ' ' || c.CName || ' ' || c.DoB);
END LOOP;
END;
/

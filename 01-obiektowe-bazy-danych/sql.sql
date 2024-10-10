--- 1
CREATE TYPE samochod AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10,2)
);
CREATE TABLE samochody OF samochod;
INSERT INTO samochody VALUES (NEW samochod('FIAT', 'BRAVA', 60000, '30-11-1999', 25000));
INSERT INTO samochody VALUES (NEW samochod('FORD', 'MONDEO', 80000, '10-05-1997', 45000));
INSERT INTO samochody VALUES (NEW samochod('MAZDA', '323', 12000, '22-09-2000', 52000));
DESC samochod;
SELECT * FROM samochody;

--- 2
CREATE TABLE wlasciciele (
    IMIE VARCHAR2(100),
    NAZWISKO VARCHAR2(100),
    AUTO SAMOCHOD
);
INSERT INTO wlasciciele VALUES (
    'JAN', 
    'KOWALSKI', 
    NEW samochod(
        'FIAT', 
        'SEICENTO', 
        30000, 
        '02-12-0010', 
        19500
    )
);
INSERT INTO wlasciciele VALUES (
    'ADAM',
    'NOWAK',
    NEW samochod(
        'OPEL',
        'ASTRA',
        34000,
        '01-06-0009',
        33700
    )
);
DESC wlasciciele;
SELECT * FROM wlasciciele;

--- 3
ALTER TYPE SAMOCHOD ADD MEMBER FUNCTION WARTOSC RETURN NUMBER CASCADE;
CREATE OR REPLACE TYPE BODY SAMOCHOD AS 
    MEMBER FUNCTION WARTOSC RETURN NUMBER IS
    BEGIN
        RETURN SELF.CENA * POWER(
            0.9,
            EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM SELF.DATA_PRODUKCJI)
        );
    END WARTOSC;
END;
SELECT 
    s.marka, 
    s.cena, 
    EXTRACT(YEAR FROM SYSDATE) aktualny_rok, 
    EXTRACT(YEAR FROM s.data_produkcji) rok_produkcji, 
    s.wartosc() 
FROM SAMOCHODY s;

--- 4
ALTER TYPE SAMOCHOD ADD MAP MEMBER FUNCTION odwzoruj RETURN NUMBER CASCADE INCLUDING TABLE DATA;
CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION WARTOSC RETURN NUMBER IS
    BEGIN
        RETURN SELF.CENA * POWER(
            0.9,
            EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM SELF.DATA_PRODUKCJI)
        );
    END WARTOSC;

    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM DATA_PRODUKCJI) + KILOMETRY/10000;
    END odwzoruj;
END;
SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);

--- 5
CREATE TYPE wlasciciel AS OBJECT (
    IMIE VARCHAR2(100),
    NAZWISKO VARCHAR2(100),
    AUTO REF SAMOCHOD
);
CREATE TABLE wlascicieleref OF wlasciciel;
INSERT INTO WLASCICIELEREF VALUES (
    NEW WLASCICIEL(
        'MIKOŁAJ',
        'BARTKOWIAK',
        (SELECT REF(s) FROM SAMOCHODY s WHERE s.MARKA LIKE 'MAZDA')
    )
);
INSERT INTO WLASCICIELEREF VALUES (
    NEW WLASCICIEL(
        'MACIEJ',
        'BILIŃSKI',
        (SELECT REF(s) FROM SAMOCHODY s WHERE s.MARKA LIKE 'FIAT')
    )
);
INSERT INTO WLASCICIELEREF VALUES (
    NEW WLASCICIEL(
        'BARTOSZ',
        'ADAMCZYK',
        (SELECT REF(s) FROM SAMOCHODY s WHERE s.MARKA LIKE 'FORD')
    )
);
SELECT * FROM WLASCICIELEREF;

--- 6
DECLARE
    TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
    moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
    moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.EXTEND(9);
    FOR i IN 2..10 LOOP
        moje_przedmioty(i) := 'PRZEDMIOT_' || i;
    END LOOP;
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;
    moje_przedmioty.TRIM(2);
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.EXTEND();
    moje_przedmioty(9) := 9;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.DELETE();
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;

--- 7
DECLARE
    TYPE t_tytul_ksiazki IS VARRAY(15) OF VARCHAR2(100);
    tytuly t_tytul_ksiazki := t_tytul_ksiazki('');
BEGIN
    tytuly(1) := 'METRO 2033';
    FOR i IN tytuly.FIRST()..tytuly.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(tytuly(i));
    END LOOP;

    tytuly.EXTEND(2);
    tytuly(2) := 'DIUNA';
    tytuly(3) := 'WIEDŹMIN';
    FOR i IN tytuly.FIRST()..tytuly.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(tytuly(i));
    END LOOP;
    
    tytuly.TRIM(2);
    FOR i IN tytuly.FIRST()..tytuly.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(tytuly(i));
    END LOOP;
END;

--- 8
declare
   type t_wykladowcy is
      table of varchar2(20);
   moi_wykladowcy t_wykladowcy := t_wykladowcy();
begin
   moi_wykladowcy.extend(2);
   moi_wykladowcy(1) := 'MORZY';
   moi_wykladowcy(2) := 'WOJCIECHOWSKI';
   moi_wykladowcy.extend(8);
   for i in 3..10 loop
      moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
   end loop;
   for i in moi_wykladowcy.first()..moi_wykladowcy.last() loop
      dbms_output.put_line(moi_wykladowcy(i));
   end loop;
   moi_wykladowcy.trim(2);
   for i in moi_wykladowcy.first()..moi_wykladowcy.last() loop
      dbms_output.put_line(moi_wykladowcy(i));
   end loop;
   moi_wykladowcy.delete(
      5,
      7
   );
   dbms_output.put_line('Limit: ' || moi_wykladowcy.limit());
   dbms_output.put_line('Liczba elementow: ' || moi_wykladowcy.count());
   for i in moi_wykladowcy.first()..moi_wykladowcy.last() loop
      if moi_wykladowcy.exists(i) then
         dbms_output.put_line(moi_wykladowcy(i));
      end if;
   end loop;
   moi_wykladowcy(5) := 'ZAKRZEWICZ';
   moi_wykladowcy(6) := 'KROLIKOWSKI';
   moi_wykladowcy(7) := 'KOSZLAJDA';
   for i in moi_wykladowcy.first()..moi_wykladowcy.last() loop
      if moi_wykladowcy.exists(i) then
         dbms_output.put_line(moi_wykladowcy(i));
      end if;
   end loop;
   dbms_output.put_line('Limit: ' || moi_wykladowcy.limit());
   dbms_output.put_line('Liczba elementow: ' || moi_wykladowcy.count());
end;

--- 9
DECLARE
    TYPE t_miesiace IS TABLE OF VARCHAR2(20);
    miesiace t_miesiace := t_miesiace();
    v_miesiac VARCHAR2(20);
BEGIN
    miesiace.EXTEND(12);
    FOR i IN 0 .. 11 LOOP
        v_miesiac := TO_CHAR(ADD_MONTHS(TO_DATE('2024-01-01', 'YYYY-MM-DD'), i), 'Month', 'NLS_DATE_LANGUAGE=POLISH');
        miesiace(i+1) := v_miesiac;
    END LOOP;
    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(miesiace(i));
    END LOOP;
    
    miesiace.delete(8, 9);
    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
        IF miesiace.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(miesiace(i));
        END IF;
    END LOOP;
END;

--- 10
create type jezyki_obce as
   varray(10) of varchar2(20);
/
create type stypendium as object (
      nazwa  varchar2(50),
      kraj   varchar2(30),
      jezyki jezyki_obce
);
/
create table stypendia of stypendium;
insert into stypendia values ( 'SOKRATES',
                               'FRANCJA',
                               jezyki_obce(
                                  'ANGIELSKI',
                                  'FRANCUSKI',
                                  'NIEMIECKI'
                               ) );
insert into stypendia values ( 'ERASMUS',
                               'NIEMCY',
                               jezyki_obce(
                                  'ANGIELSKI',
                                  'NIEMIECKI',
                                  'HISZPANSKI'
                               ) );
select *
  from stypendia;
select s.jezyki
  from stypendia s;
update stypendia
   set
   jezyki = jezyki_obce(
      'ANGIELSKI',
      'NIEMIECKI',
      'HISZPANSKI',
      'FRANCUSKI'
   )
 where nazwa = 'ERASMUS';
create type lista_egzaminow as
   table of varchar2(20);
/
create type semestr as object (
      numer    number,
      egzaminy lista_egzaminow
);
/
create table semestry of semestr
nested table egzaminy store as tab_egzaminy;
insert into semestry values ( semestr(
   1,
   lista_egzaminow(
      'MATEMATYKA',
      'LOGIKA',
      'ALGEBRA'
   )
) );
insert into semestry values ( semestr(
   2,
   lista_egzaminow(
      'BAZY DANYCH',
      'SYSTEMY OPERACYJNE'
   )
) );
select s.numer,
       e.*
  from semestry s,
       table ( s.egzaminy ) e;
select e.*
  from semestry s,
       table ( s.egzaminy ) e;
select *
  from table (
   select s.egzaminy
     from semestry s
    where numer = 1
);
insert into table (
   select s.egzaminy
     from semestry s
    where numer = 2
) values ( 'METODY NUMERYCZNE' );
update table (
   select s.egzaminy
     from semestry s
    where numer = 2
) e
   set
   e.column_value = 'SYSTEMY ROZPROSZONE'
 where e.column_value = 'SYSTEMY OPERACYJNE';
delete from table (
   select s.egzaminy
     from semestry s
    where numer = 2
) e
 where e.column_value = 'BAZY DANYCH';

--- 11
CREATE TYPE produkt AS OBJECT (
    nazwa VARCHAR2(50),
    cena NUMBER
);
CREATE TYPE koszyk_produktow AS TABLE OF produkt;
CREATE TYPE t_zakupy AS OBJECT(
    data_zakupu DATE,
    koszyk koszyk_produktow
);
CREATE TABLE zakupy OF t_zakupy NESTED TABLE koszyk STORE AS t_koszyk;
INSERT INTO zakupy VALUES (
    NEW t_zakupy(
        SYSDATE,
        NEW KOSZYK_PRODUKTOW(
            NEW PRODUKT(
                'BANAN',
                1.20
            ),
            NEW PRODUKT(
                'JABŁKO',
                2.50
            )
        )
    )
);
INSERT INTO zakupy VALUES (
    NEW t_zakupy(
        SYSDATE,
        NEW KOSZYK_PRODUKTOW(
            NEW PRODUKT(
                'BANAN',
                1.20
            ),
            NEW PRODUKT(
                'POMARAŃCZA',
                1.70
            )
        )
    )
);
SELECT 
    z.data_zakupu,
    k.nazwa,
    k.cena
FROM 
    zakupy z,
    TABLE(z.koszyk) k;
DELETE FROM zakupy z
WHERE EXISTS (
    SELECT 1
    FROM TABLE(z.koszyk) k
    WHERE k.nazwa = 'BANAN'
);
SELECT 
    z.data_zakupu,
    k.nazwa,
    k.cena
FROM 
    zakupy z,
    TABLE(z.koszyk) k;


--- 12
create type instrument as object (
      nazwa  varchar2(20),
      dzwiek varchar2(20),
      member function graj return varchar2
) not final;
create type body instrument as
   member function graj return varchar2 is
   begin
      return dzwiek;
   end;
end;
/
create type instrument_dety under instrument (
      material varchar2(20),
      overriding member function graj return varchar2,
      member function graj (
           glosnosc varchar2
        ) return varchar2
);
create or replace type body instrument_dety as overriding
   member function graj return varchar2 is
   begin
      return 'dmucham: ' || dzwiek;
   end;
   member function graj (
      glosnosc varchar2
   ) return varchar2 is
   begin
      return glosnosc
             || ':'
             || dzwiek;
   end;
end;
/
create type instrument_klawiszowy under instrument (
      producent varchar2(20),
      overriding member function graj return varchar2
);
create or replace type body instrument_klawiszowy as overriding
   member function graj return varchar2 is
   begin
      return 'stukam w klawisze: ' || dzwiek;
   end;
end;
/
declare
   tamburyn  instrument := instrument(
      'tamburyn',
      'brzdek-brzdek'
   );
   trabka    instrument_dety := instrument_dety(
      'trabka',
      'tra-ta-ta',
      'metalowa'
   );
   fortepian instrument_klawiszowy := instrument_klawiszowy(
      'fortepian',
      'ping-
ping',
      'steinway'
   );
begin
   dbms_output.put_line(tamburyn.graj);
   dbms_output.put_line(trabka.graj);
   dbms_output.put_line(trabka.graj('glosno'));
   dbms_output.put_line(fortepian.graj);
end;

--- 13
create type istota as object (
      nazwa varchar2(20),
      not instantiable member function poluj (
           ofiara char
        ) return char
) not instantiable not final;
create type lew under istota (
      liczba_nog number,
      overriding member function poluj (
           ofiara char
        ) return char
);
create or replace type body lew as overriding
   member function poluj (
      ofiara char
   ) return char is
   begin
      return 'upolowana ofiara: ' || ofiara;
   end;
end;
declare
   krollew    lew := lew(
      'LEW',
      4
   );
   innaistota istota := istota('JAKIES ZWIERZE');
begin
   dbms_output.put_line(krollew.poluj('antylopa'));
end;

--- 14
declare
   tamburyn instrument;
   cymbalki instrument;
   trabka   instrument_dety;
   saksofon instrument_dety;
begin
   tamburyn := instrument(
      'tamburyn',
      'brzdek-brzdek'
   );
   cymbalki := instrument_dety(
      'cymbalki',
      'ding-ding',
      'metalowe'
   );
   trabka := instrument_dety(
      'trabka',
      'tra-ta-ta',
      'metalowa'
   );
    -- saksofon := instrument('saksofon','tra-taaaa');
    -- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
end;

--- 15
create table instrumenty of instrument;
insert into instrumenty values ( instrument(
   'tamburyn',
   'brzdek-brzdek'
) );
insert into instrumenty values ( instrument_dety(
   'trabka',
   'tra-ta-ta',
   'metalowa'
) );
insert into instrumenty values ( instrument_klawiszowy(
   'fortepian',
   'ping-
ping',
   'steinway'
) );
select i.nazwa,
       i.graj()
  from instrumenty i;
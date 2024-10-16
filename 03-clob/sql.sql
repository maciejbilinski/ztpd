-- 1
CREATE TABLE DOKUMENTY (
    ID NUMBER(12) PRIMARY KEY,
    DOKUMENT CLOB
);

-- 2
DECLARE
    V_TEXT CLOB := '';
BEGIN
    FOR i IN 1..10000 LOOP
        V_TEXT := V_TEXT || 'Oto tekst. ';
    END LOOP;
    INSERT INTO DOKUMENTY (ID, DOKUMENT) VALUES (1, V_TEXT);
END;

-- 3A
SELECT * FROM DOKUMENTY;

-- 3B
SELECT ID, UPPER(DOKUMENT) FROM DOKUMENTY;

-- 3C
SELECT ID, LENGTH(DOKUMENT) FROM DOKUMENTY;

-- 3D
SELECT ID, DBMS_LOB.GETLENGTH(DOKUMENT) FROM DOKUMENTY;

-- 3E
SELECT ID, SUBSTR(DOKUMENT, 5, 1000) FROM DOKUMENTY;

-- 3F
SELECT ID, DBMS_LOB.SUBSTR(DOKUMENT, 1000, 5) FROM DOKUMENTY;

-- 4
INSERT INTO DOKUMENTY (ID, DOKUMENT) VALUES (2, EMPTY_CLOB());

-- 5
INSERT INTO DOKUMENTY (ID, DOKUMENT) VALUES (3, NULL);

-- 6
SELECT * FROM DOKUMENTY;
SELECT ID, UPPER(DOKUMENT) FROM DOKUMENTY;
SELECT ID, LENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT ID, DBMS_LOB.GETLENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT ID, SUBSTR(DOKUMENT, 5, 1000) FROM DOKUMENTY;
SELECT ID, DBMS_LOB.SUBSTR(DOKUMENT, 1000, 5) FROM DOKUMENTY;

-- 7
DECLARE
    V_FILE BFILE := BFILENAME('TPD_DIR', 'dokument.txt');
    V_CLOB CLOB;
    doffset integer := 1;
    soffset integer := 1;
    bfilecsid integer := 0;
    langctx integer := 0;
    warn integer := null;
BEGIN
    SELECT DOKUMENT INTO V_CLOB FROM DOKUMENTY WHERE ID = 2 FOR UPDATE;
    DBMS_LOB.FILEOPEN(V_FILE, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADCLOBFROMFILE(V_CLOB, V_FILE, DBMS_LOB.LOBMAXSIZE, doffset, soffset, bfilecsid, langctx, warn);
    DBMS_LOB.FILECLOSE(V_FILE);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Status operacji: '||warn);
END;
SELECT * FROM DOKUMENTY WHERE ID = 2;

-- 8
UPDATE DOKUMENTY
SET DOKUMENT = TO_CLOB(BFILENAME('TPD_DIR', 'dokument.txt'))
WHERE ID = 3;
SELECT * FROM DOKUMENTY WHERE ID = 3;

-- 9
SELECT * FROM DOKUMENTY;

-- 10
SELECT ID, DBMS_LOB.GETLENGTH(DOKUMENT) FROM DOKUMENTY;

-- 11
DROP TABLE DOKUMENTY;

-- 12
CREATE OR REPLACE PROCEDURE CLOB_CENSOR (
    P_CLOB IN OUT CLOB, 
    P_CENS VARCHAR2
)
AS
    V_OFFSET INTEGER := 1;
    V_CENS_LEN INTEGER := LENGTH(P_CENS);
BEGIN
    LOOP EXIT WHEN V_OFFSET > DBMS_LOB.GETLENGTH(P_CLOB);
        V_OFFSET := DBMS_LOB.INSTR(
            P_CLOB,
            P_CENS,
            V_OFFSET
        );

        IF (V_OFFSET = 0) THEN
            EXIT;
        END IF;

        DBMS_LOB.WRITE(P_CLOB, V_CENS_LEN, V_OFFSET, RPAD('.', V_CENS_LEN, '.'));
        V_OFFSET := V_OFFSET + V_CENS_LEN;
    END LOOP;
END;

-- 13
CREATE TABLE BIOGRAPHIES AS SELECT * FROM ZTPD.BIOGRAPHIES;
DESC BIOGRAPHIES;
SELECT * FROM BIOGRAPHIES;
DECLARE
    V_CLOB CLOB;
BEGIN
    SELECT BIO INTO V_CLOB FROM BIOGRAPHIES WHERE ID = 1 FOR UPDATE;
    CLOB_CENSOR(V_CLOB, 'Cimrman');
END;
SELECT * FROM BIOGRAPHIES;

-- 14
DROP TABLE BIOGRAPHIES;
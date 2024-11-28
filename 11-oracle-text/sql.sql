-- Operator CONTAINS - Podstawy
-- 1
CREATE TABLE CYTATY AS SELECT * FROM ZTPD.CYTATY;

-- 2
SELECT 
    AUTOR, 
    TEKST 
FROM 
    CYTATY 
WHERE 
    LOWER(TEKST) LIKE '%optymista%'
AND
    LOWER(TEKST) LIKE '%pesymista%';

-- 3
CREATE INDEX CYTATY_IDX ON
CYTATY(TEKST)
INDEXTYPE IS CTXSYS.CONTEXT;

-- 4
SELECT 
    AUTOR, 
    TEKST
FROM 
    CYTATY 
WHERE 
    CONTAINS(TEKST, 'optymista AND pesymista') > 0;

-- 5
SELECT 
    AUTOR, 
    TEKST
FROM 
    CYTATY 
WHERE 
    CONTAINS(TEKST, 'pesymista NOT optymista') > 0;

-- 6
SELECT 
    AUTOR,
    TEKST
FROM 
    CYTATY
WHERE 
    CONTAINS(TEKST, 'NEAR((optymista, pesymista), 3)') > 0;

-- 7
SELECT 
    AUTOR,
    TEKST
FROM 
    CYTATY
WHERE 
    CONTAINS(TEKST, 'NEAR((optymista, pesymista), 10)') > 0;

-- 8
SELECT 
    AUTOR,
    TEKST
FROM 
    CYTATY
WHERE 
    CONTAINS(TEKST, 'życi%') > 0;

-- 9
SELECT 
    AUTOR,
    TEKST,
    SCORE(1) DOPASOWANIE
FROM 
    CYTATY
WHERE 
    CONTAINS(TEKST, 'życi%', 1) > 0;

-- 10
SELECT * FROM (
    SELECT 
        AUTOR,
        TEKST,
        SCORE(1) DOPASOWANIE
    FROM 
        CYTATY
    WHERE 
        CONTAINS(TEKST, 'życi%', 1) > 0
    ORDER BY
        DOPASOWANIE DESC
) WHERE ROWNUM <= 1;

-- 11
SELECT 
    AUTOR,
    TEKST
FROM 
    CYTATY
WHERE 
    CONTAINS(TEKST, 'FUZZY(probelm)', 1) > 0;

-- 12
INSERT INTO CYTATY VALUES((
    SELECT MAX(ID) + 1 FROM CYTATY
), 'Bertrand Russell', 'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.');
COMMIT;

-- 13 (nie działa, bo indeks nie został zaktualizowany)
SELECT
    AUTOR,
    TEKST 
FROM 
    CYTATY
WHERE 
    CONTAINS(TEKST, 'głupcy') > 0;

-- 14 (nie zawiera)
SELECT * FROM DR$CYTATY_IDX$I WHERE TOKEN_TEXT = 'GŁUPCY';

-- 15
DROP INDEX CYTATY_IDX;
CREATE INDEX CYTATY_IDX ON
CYTATY(TEKST)
INDEXTYPE IS CTXSYS.CONTEXT;

-- 16 (pojawiło się i rekord jest poprawnie zwracany)
SELECT * FROM DR$CYTATY_IDX$I WHERE TOKEN_TEXT = 'GŁUPCY';
SELECT
    AUTOR,
    TEKST 
FROM 
    CYTATY
WHERE 
    CONTAINS(TEKST, 'głupcy') > 0;

-- 17
DROP INDEX CYTATY_IDX;
DROP TABLE CYTATY;

-- Zaawansowane indeksowanie i wyszukiwan
-- 1
CREATE TABLE QUOTES AS SELECT * FROM ZTPD.QUOTES;
DESCRIBE QUOTES;

-- 2
CREATE INDEX QUOTES_IDX ON
QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT;

-- 3
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'work') > 0;
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '$work') > 0;
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'working') > 0;
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '$working') > 0;

-- 4 (ponieważ it jest stopwordem)
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'it') > 0;

-- 5 (wykorzystał DEFAULT_STOPLIST)
SELECT * FROM CTX_STOPLISTS;

-- 6
SELECT * FROM CTX_STOPWORDS;

-- 7
DROP INDEX QUOTES_IDX;
CREATE INDEX QUOTES_IDX ON
QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS('stoplist CTXSYS.EMPTY_STOPLIST');

-- 8 (tak, zwrócił 4 rekordy)
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'it') > 0;

-- 9
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'fool AND humans') > 0;

-- 10
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'fool AND computer') > 0;

-- 11
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '(fool AND computer) WITHIN SENTENCE') > 0;

-- 12
DROP INDEX QUOTES_IDX;

-- 13
begin
    ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup', 'SENTENCE');
    ctx_ddl.add_special_section('nullgroup', 'PARAGRAPH');
end;

-- 14
CREATE INDEX QUOTES_IDX ON
QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS('section group nullgroup');

-- 15 (działa)
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '(fool AND humans) WITHIN SENTENCE') > 0;
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '(fool AND computer) WITHIN SENTENCE') > 0;

-- 16 (zwraca również non-humans)
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'humans') > 0;

-- 17
DROP INDEX QUOTES_IDX;
begin
    ctx_ddl.create_preference('lex_z_m','BASIC_LEXER');
    ctx_ddl.set_attribute('lex_z_m',
    'printjoins', '_-');
    ctx_ddl.set_attribute ('lex_z_m',
    'index_text', 'YES');
end;
CREATE INDEX QUOTES_IDX ON
QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS('LEXER lex_z_m');

-- 18 (nie zwraca non-humans)
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'humans') > 0;

-- 19
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'non\-humans') > 0;

-- 20
DROP INDEX QUOTES_IDX;
DROP TABLE QUOTES;
begin
    ctx_ddl.drop_preference('lex_z_m');
end;
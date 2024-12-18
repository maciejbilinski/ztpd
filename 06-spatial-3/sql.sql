-- 1A
select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||
', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name
and prior t.owner = t.owner;

-- 1B
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
and m.owner = 'MDSYS'
order by 1;

-- 1C
CREATE TABLE MYST_MAJOR_CITIES (
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME VARCHAR2(40),
    STGEOM ST_POINT
);

-- 1D
INSERT INTO MYST_MAJOR_CITIES (FIPS_CNTRY, CITY_NAME, STGEOM) SELECT FIPS_CNTRY, CITY_NAME, ST_POINT(GEOM) FROM MAJOR_CITIES;

-- 2A
INSERT INTO MYST_MAJOR_CITIES VALUES ('PL', 'SZCZYRK', NEW ST_POINT(19.036107, 49.718655, 8307));

-- 3A
CREATE TABLE MYST_COUNTRY_BOUNDARIES (
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM ST_MULTIPOLYGON
);

-- 3B
INSERT INTO MYST_COUNTRY_BOUNDARIES (FIPS_CNTRY, CNTRY_NAME, STGEOM) SELECT FIPS_CNTRY, CNTRY_NAME, ST_MULTIPOLYGON(GEOM) FROM COUNTRY_BOUNDARIES;

-- 3C
SELECT 
    B.STGEOM.ST_GEOMETRYTYPE() TYP_OBIEKTU, 
    COUNT(*) ILE
FROM MYST_COUNTRY_BOUNDARIES B 
GROUP BY B.STGEOM.ST_GEOMETRYTYPE();

-- 3D (każdy element = 1)
SELECT B.STGEOM.ST_ISSIMPLE() FROM MYST_COUNTRY_BOUNDARIES B;

-- 4A
SELECT 
    B.CNTRY_NAME,
    COUNT(*)
FROM 
    MYST_COUNTRY_BOUNDARIES B,
    MYST_MAJOR_CITIES C
WHERE
    B.STGEOM.ST_CONTAINS(C.STGEOM) = 1
GROUP BY 
    B.CNTRY_NAME
ORDER BY
    B.CNTRY_NAME;

-- 4B
SELECT 
    A.CNTRY_NAME A_NAME,
    B.CNTRY_NAME B_NAME
FROM 
    MYST_COUNTRY_BOUNDARIES A,
    MYST_COUNTRY_BOUNDARIES B
WHERE 
    B.CNTRY_NAME = 'Czech Republic' 
AND 
    A.STGEOM.ST_TOUCHES(B.STGEOM) = 1
ORDER BY
    A.CNTRY_NAME;

-- 4C
SELECT DISTINCT
    B.CNTRY_NAME, 
    R.NAME 
FROM 
    MYST_COUNTRY_BOUNDARIES B, 
    RIVERS R 
WHERE 
    B.CNTRY_NAME = 'Czech Republic' 
AND 
    B.STGEOM.ST_CROSSES(ST_LINESTRING(R.GEOM)) = 1
ORDER BY
    R.NAME;

-- 4D
SELECT 
    (EZ.STGEOM.ST_AREA() + LO.STGEOM.ST_AREA()) POWIERZCHNIA 
FROM 
    MYST_COUNTRY_BOUNDARIES EZ, 
    MYST_COUNTRY_BOUNDARIES LO
WHERE 
    EZ.FIPS_CNTRY ='EZ'
AND
    LO.FIPS_CNTRY = 'LO';

-- 4E
SELECT 
    B.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(W.GEOM)) OBIEKT,
    B.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(W.GEOM)).ST_GEOMETRYTYPE() WEGRY_BEZ
FROM 
    MYST_COUNTRY_BOUNDARIES B, 
    WATER_BODIES W 
WHERE
    B.CNTRY_NAME = 'Hungary' 
AND 
    W.name = 'Balaton';

-- 5A
SELECT 
    COUNT(*)
FROM 
    MYST_COUNTRY_BOUNDARIES B, 
    MYST_MAJOR_CITIES C
WHERE 
    SDO_WITHIN_DISTANCE(C.STGEOM, B.STGEOM, 'distance=100 unit=km') = 'TRUE' 
AND 
    B.CNTRY_NAME = 'Poland'
AND
    C.FIPS_CNTRY <> B.FIPS_CNTRY
GROUP BY B.CNTRY_NAME;

-- 5B
INSERT INTO USER_SDO_GEOM_METADATA VALUES (
    'MYST_MAJOR_CITIES', 
    'STGEOM',
    SDO_DIM_ARRAY(
        SDO_DIM_ELEMENT('X', -180, 180, 0.005),
        SDO_DIM_ELEMENT('Y', -90, 90, 0.005)
    ),
    8307
);
INSERT INTO USER_SDO_GEOM_METADATA VALUES (
    'MYST_COUNTRY_BOUNDARIES', 
    'STGEOM',
    SDO_DIM_ARRAY(
        SDO_DIM_ELEMENT('X', -180, 180, 0.005),
        SDO_DIM_ELEMENT('Y', -90, 90, 0.005)
    ),
    8307
);

-- 5C
CREATE INDEX MYST_MAJOR_CITIES_IDX ON
MYST_MAJOR_CITIES(STGEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

CREATE INDEX MYST_COUNTRY_BOUNDARIES_IDX ON
MYST_COUNTRY_BOUNDARIES(STGEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-- 5D (jest wykorzystywany indeks MYST_MAJOR_CITIES_IDX)
EXPLAIN PLAN FOR SELECT 
    COUNT(*)
FROM 
    MYST_COUNTRY_BOUNDARIES B, 
    MYST_MAJOR_CITIES C
WHERE 
    SDO_WITHIN_DISTANCE(C.STGEOM, B.STGEOM, 'distance=100 unit=km') = 'TRUE' 
AND 
    B.CNTRY_NAME = 'Poland'
AND
    C.FIPS_CNTRY <> B.FIPS_CNTRY
GROUP BY B.CNTRY_NAME;
SELECT plan_table_output FROM table(dbms_xplan.display('plan_table', null, 'basic'));
-- 1A
insert into user_sdo_geom_metadata values ( 'FIGURY',
                                            'KSZTALT',
                                            sdo_dim_array(
                                               sdo_dim_element(
                                                  'X',
                                                  0,
                                                  10,
                                                  0.01
                                               ),
                                               sdo_dim_element(
                                                  'Y',
                                                  0,
                                                  10,
                                                  0.01
                                               )
                                            ),
                                            null );

-- 1B
select sdo_tune.estimate_rtree_index_size(
   3000000,
   8192,
   10,
   2,
   0
)
  from dual;

-- 1C
create index figury_idx on
   figury (
      ksztalt
   )
      indextype is mdsys.spatial_index_v2;

-- 1D (niepoprawny wynik, ponieważ Operator SDO_FILTER, który wykorzystuje jedynie pierwszą fazę zapytania)
select id
  from figury
 where sdo_filter(
   ksztalt,
   sdo_geometry(
      2001,
      null,
      sdo_point_type(
         3,
         3,
         null
      ),
      null,
      null
   )
) = 'TRUE';

-- 1E (poprawny wynik)
select id
  from figury
 where sdo_relate(
   ksztalt,
   sdo_geometry(
      2001,
      null,
      sdo_point_type(
         3,
         3,
         null
      ),
      null,
      null
   ),
   'mask=ANYINTERACT'
) = 'TRUE';

-- 2A
select city_name miasto,
       sdo_nn_distance(1) odl
  from major_cities
 where city_name <> 'Warsaw'
   and sdo_nn(
   geom,
   (
      select geom
        from major_cities
       where city_name = 'Warsaw'
   ),
   'sdo_num_res=10 unit=km',
   1
) = 'TRUE';

-- 2B
select city_name miasto
  from major_cities
 where city_name <> 'Warsaw'
   and sdo_within_distance(
   geom,
   (
      select geom
        from major_cities
       where city_name = 'Warsaw'
   ),
   'distance=100 unit=km'
) = 'TRUE';

-- 2C
select b.cntry_name kraj,
       c.city_name miasto
  from major_cities c,
       country_boundaries b
 where b.cntry_name = 'Slovakia'
   and sdo_relate(
   c.geom,
   b.geom,
   'mask=INSIDE'
) = 'TRUE';

-- 2D
select a.cntry_name panstwo,
       sdo_geom.sdo_distance(
          a.geom,
          b.geom,
          1,
          'unit=km'
       ) odl
  from country_boundaries a,
       country_boundaries b
 where sdo_relate(
      a.geom,
      b.geom,
      'mask=ANYINTERACT'
   ) != 'TRUE'
   and b.cntry_name = 'Poland';

-- 3A
select a.cntry_name,
SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(a.geom, b.geom, 1), 1, 'unit=km') granica
  from country_boundaries a,
       country_boundaries b
 where sdo_relate(
      b.geom,
      a.geom,
      'mask=TOUCH'
   ) = 'TRUE'
   and b.cntry_name = 'Poland';

-- 3B
SELECT cntry_name
FROM country_boundaries 
WHERE SDO_GEOM.SDO_AREA(GEOM) = (SELECT MAX(SDO_GEOM.SDO_AREA(GEOM)) FROM country_boundaries);

-- 3C
SELECT SDO_GEOM.SDO_AREA(SDO_GEOM.SDO_MBR(SDO_GEOM.SDO_UNION(
                    				B.GEOM,
                    				A.GEOM,
                    				1)), 1, 'unit=SQ_KM') SQ_KM
FROM major_cities A,
    major_cities B
WHERE A.city_name = 'Warsaw'
    AND B.city_name = 'Lodz';

-- 3D
SELECT 
    SDO_GEOM.SDO_UNION(
        (SELECT GEOM FROM country_boundaries WHERE CNTRY_NAME = 'Poland'),
        (SELECT GEOM FROM MAJOR_CITIES WHERE CITY_NAME = 'Prague'),
        0.005
    ).SDO_GTYPE AS GTYPE
FROM DUAL;

-- 3E
SELECT C.city_name, B.cntry_name 
FROM country_boundaries B JOIN major_cities C ON B.cntry_name = C.cntry_name
WHERE
 SDO_GEOM.SDO_DISTANCE(
     SDO_GEOM.SDO_CENTROID(B.GEOM, 1),
     C.GEOM, 1) = (SELECT MIN(SDO_GEOM.SDO_DISTANCE(SDO_GEOM.SDO_CENTROID(B.GEOM, 1), C.GEOM, 1))
			FROM country_boundaries B, major_cities C 
			WHERE B.cntry_name = C.cntry_name);

-- 3F
SELECT NAME, SUM(L) FROM (SELECT 
    R.NAME,
    SDO_GEOM.SDO_LENGTH(
        SDO_GEOM.SDO_INTERSECTION(
            R.GEOM,
            B.GEOM,
            1
        ),
        1,
        'unit=km'
    ) L
FROM Rivers R, country_boundaries B
WHERE B.CNTRY_NAME = 'Poland'
  AND SDO_RELATE(
      R.GEOM,
      B.GEOM,
      'mask=ANYINTERACT'
  ) = 'TRUE')
GROUP BY NAME;
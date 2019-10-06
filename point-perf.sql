-- Performance tests for point data and indexes

-- Test Results:
-- 10M points

-- ====  XY representation
-- Query - No index: 1165 ms
-- Query - Index (Btree): 23.9 ms
-- Index creation time: 19158 ms

-- ==== Postgres point representation
-- Query - No index: 1017 ms
-- Query - Index (GIST): 4.8 ms
-- Index creation time: 918975 ms
-- Query - Index (SPGIST): ~ 7 ms
-- Index creation time: 918975 ms

-- ==== Postgres point representation
-- Query - No index: 2555 ms
-- Query - Index (GIST): 5.5 ms
-- Index creation time: 1176434 ms

CREATE SCHEMA ptsperf;

-- ================================================
-- Representation: X,Y columns, with BTREE index
-- ================================================
CREATE TABLE ptsperf.pts_xy
(
  locx double precision,
  locy double precision
);

CREATE INDEX ON ptsperf.pts_xy ( locx, locy );

-- Insert records with location ordinates random in [0,100]
INSERT INTO ptsperf.pts_xy 
  SELECT 100*random() AS x, 100*random() AS y
    FROM generate_series(1, 10000000) AS t(x);

SELECT count(*) FROM ptsperf.pts_xy 
  WHERE locx BETWEEN 50 AND 51 AND locy BETWEEN 60 AND 61;

SELECT avg(locx), avg(locy) FROM ptsperf.pts_xy 
  WHERE locx BETWEEN 50 AND 51 AND locy BETWEEN 60 AND 61;
  
-- ================================================
-- Representation: Postgres point, with GIST index
-- ================================================
CREATE TABLE ptsperf.pts_point
(
  loc point
);

-- Insert records with locations as point datatype 
INSERT INTO ptsperf.pts_point 
  SELECT point('(' || locx || ',' || locy || ')') AS loc
    FROM ptsperf.pts_xy;
    
CREATE INDEX ON ptsperf.pts_point USING gist( loc );
DROP INDEX ptsperf.pts_point_loc_idx;

CREATE INDEX ON ptsperf.pts_point USING spgist( loc );

SELECT count(*) FROM ptsperf.pts_point 
  WHERE loc <@ box '((50,60),(51,61))';
  
SELECT avg(loc[0]), avg(loc[1]) FROM ptsperf.pts_point 
  WHERE loc <@ box '((50,60),(51,61))';

-- ================================================
-- Representation: PostGIS point geometry, with GIST index
-- ================================================
CREATE TABLE ptsperf.pts_geom
(
  loc geometry
);

CREATE INDEX ON ptsperf.pts_geom USING gist( loc );

-- Insert records with locations as point datatype 
INSERT INTO ptsperf.pts_geom 
  SELECT ST_MakePoint(locx, locy) AS loc
    FROM ptsperf.pts_xy;

SELECT count(*) FROM ptsperf.pts_geom  
  WHERE loc && ST_MakeBox2D( ST_Point(50,60),ST_Point(51,61) );


-- ===================================
-- Cleanup
-- ===================================

DROP SCHEMA ptsperf CASCADE;

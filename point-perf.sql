-- Performance tests for point data and indexes

-- Test Results:

-- ====  XY representation
-- No index: 184 ms
-- Index: 4.65 ms

-- ==== Postgres point representation
-- No index: 110 ms
-- Index: 1.2 - 2.4 ms

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

-- ================================================
-- Representation: Postgres point, with GIST index
-- ================================================
CREATE TABLE ptsperf.pts_point
(
  loc point
);

CREATE INDEX ON ptsperf.pts_point USING gist( loc );

DELETE FROM pts.pts_point;

-- Insert records with locations as point datatype 
INSERT INTO ptsperf.pts_point 
  SELECT point('(' || locx || ',' || locy || ')') AS loc
    FROM ptsperf.pts_xy;

SELECT count(*) FROM pts.pts_point 
  WHERE loc <@ box '((50,60),(51,61))';


-- ===================================
-- Cleanup
-- ===================================

DROP SCHEMA ptsperf CASCADE;

-- Performance tests for point data and indexes

CREATE SCHEMA pts;

CREATE TABLE pts.pts_xy
(
  locx double precision,
  locy double precision
);

DELETE FROM pts.pts_xy;

INSERT INTO pts.pts_xy 
  SELECT 100*random() AS x, 100*random() AS y
    FROM generate_series(1, 1000000) AS t(x);

SELECT count(*) FROM pts.pts_xy 
  WHERE locx BETWEEN 50 AND 51 AND locy BETWEEN 60 AND 61;
  
  -- Clean up
  

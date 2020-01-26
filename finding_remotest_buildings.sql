-- Bin building centroids to grid:

WITH building_count AS
  (SELECT t.id AS id,
          count(*) AS total
   FROM os_buildings_centroid os,
        trimmed_grid t
   WHERE ST_Intersects(t.geom, os.geom)
   GROUP BY t.id)
UPDATE trimmed_grid
SET os_building_count = building_count.total
FROM building_count
WHERE trimmed_grid.id = building_count.id;

-- Cluster grid cells with building count <=1:

CREATE TABLE grid_clusters AS
SELECT ST_Union(geom) AS geom
FROM trimmed_grid
WHERE building_count <=1;

-- Calculate cluster area:

ALTER TABLE grid_clusters ADD COLUMN area double precision;
UPDATE grid_clusters
SET area = ST_Area(geom);

-- Create Voronoi Polygons using building centroids as seeds, limiting by the entent of the cell clusters:

CREATE TABLE voronoi AS
  (WITH centroids AS
     (SELECT ST_Collect(geom) AS geom
      FROM building_centroids ),
voronoi AS
(SELECT (ST_Dump(ST_VoronoiPolygons(centroids.geom,0))).geom AS geom
      FROM centroids) 
SELECT ST_intersection(voronoi.geom, bc.geom)
   FROM voronoi
   INNER JOIN buffered_clusters bc ON ST_intersects(voronoi.geom, bc.geom));
   
-- Perform Nearest Neighbour search:

SELECT a.id, a.geom, st_distance(a.geom, b.geom) AS dist
FROM building_centroids a
CROSS JOIN LATERAL(SELECT * FROM building_centroids b 
WHERE a.id != b.id
ORDER BY a.geom <-> b.geom 
LIMIT 1) AS b
ORDER BY dist desc
LIMIT 3;

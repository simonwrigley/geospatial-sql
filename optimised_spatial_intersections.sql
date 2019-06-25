/*
To find which buildings are within particular landuse polygons, you could write
an intersection query in the following way:
*/

SELECT * FROM research_area.buildings build
WHERE ST_intersects(a.geom, (SELECT geom FROM research_area.landuse));

/*
On a test dataset with 21,000 building footprint polygons, this took 34 seconds.
Writing the same query as follows by removing the polyon selection from the intersection
query to the top level of the select statement, we can achieve a 98.7% reduction
in execution time
*/

SELECT * FROM research_area.buildings AS build,
(SELECT geom FROM research_area.landuse) AS poly
WHERE st_intersects(build.geom, poly.geom);

/*
The same query can be written in an even more elegant way using a CTE or Common
Table Expression:
*/

WITH poly AS (SELECT geom FROM research_area.landuse)
SELECT build.*
FROM research_area.buildings build, poly
WHERE ST_Intersects(build.geom, poly.geom);

/*
This however is only 19ms faster than the previous iteration of the query
*/

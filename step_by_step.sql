SELECT * FROM covid19_basic_differences AS cd WHERE cd.country = 'Russia' AND MONTH(cd.date) = 10;
DESCRIBE covid19_basic_differences;

SELECT * FROM lookup_table AS lt WHERE lt.country = 'Russia'
GROUP BY country;

SELECT * FROM life_expectancy AS le WHERE le.country like 'Cz%';

SELECT * FROM economies AS e WHERE e.country like 'Rus%';

SELECT * FROM religions AS r LIMIT 5;

EXPLAIN
SELECT  * FROM covid19_tests AS ct WHERE ct.date = '2020-10-07' and ct.country = 'Russia';

SELECT * FROM weather AS wx LIMIT 5;

SELECT * FROM covid19_basic_differences AS cd WHERE cd.country = 'Taiwan*' LIMIT 5;

EXPLAIN
SELECT * FROM t_martin_danek_project_SQL_workingdays AS wd;

DESCRIBE countries;
SELECT * FROM countries AS c
WHERE country = 'Russian Federation';

SELECT DAYOFYEAR('2020-012-21');

SELECT * FROM covid19_basic AS cb WHERE cb.date = '2021-01-01' GROUP BY cb.country;

SELECT * FROM demographics AS d;




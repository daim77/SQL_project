SELECT * FROM covid19_basic_differences AS cd WHERE cd.country like '%Pri%';
DESCRIBE covid19_basic_differences;

SELECT * FROM lookup_table AS lt
GROUP BY country;

SELECT * FROM economies AS e LIMIT 5;

SELECT * FROM life_expectancy AS le LIMIT 5;

SELECT * FROM religions AS r LIMIT 5;

SELECT * FROM covid19_tests AS ct where country = 'Czech Republic';

SELECT * FROM weather AS wx LIMIT 5;

SELECT * FROM covid19_basic_differences AS cd WHERE cd.country = 'Taiwan*' LIMIT 5;

SELECT * FROM t_martin_danek_project_SQL_workingdays AS wd;

DESCRIBE countries;
SELECT * FROM countries AS c;
WHERE country = 'Kenya';

SELECT DAYOFYEAR('2020-012-21');

SELECT * FROM covid19_basic AS cb WHERE cb.date = '2021-01-01' GROUP BY cb.country;




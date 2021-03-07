# see FULL README.md about more info

SELECT cd.date,

       (# Czechia
           SELECT if(INSTR(wd.working_days, CAST(dayofweek(cd.date) AS char)) != 0, 1, 0)
           FROM t_martin_danek_project_SQL_workingdays AS wd
           WHERE wd.country = cd.country
       ) AS working_days,

       (
           SELECT CASE
                      WHEN lt.lat > 0 AND DAYOFYEAR(cd.date) BETWEEN 1 AND 80 THEN 0
                      WHEN lt.lat > 0 AND DAYOFYEAR(cd.date) BETWEEN 81 AND 172 THEN 1
                      WHEN lt.lat > 0 AND DAYOFYEAR(cd.date) BETWEEN 173 AND 266 THEN 2
                      WHEN lt.lat > 0 AND DAYOFYEAR(cd.date) BETWEEN 267 AND 355 THEN 3
                      WHEN lt.lat > 0 AND DAYOFYEAR(cd.date) BETWEEN 356 AND 366 THEN 0
                      WHEN lt.lat <= 0 AND DAYOFYEAR(cd.date) BETWEEN 1 AND 80 THEN 2
                      WHEN lt.lat <= 0 AND DAYOFYEAR(cd.date) BETWEEN 81 AND 172 THEN 3
                      WHEN lt.lat <= 0 AND DAYOFYEAR(cd.date) BETWEEN 173 AND 266 THEN 0
                      WHEN lt.lat <= 0 AND DAYOFYEAR(cd.date) BETWEEN 267 AND 355 THEN 1
                      WHEN lt.lat <= 0 AND DAYOFYEAR(cd.date) BETWEEN 356 AND 366 THEN 2
                      END
           FROM lookup_table AS lt
           WHERE cd.country = lt.country
           GROUP BY lt.country
       ) AS year_season,

       cd.country,
       cd.confirmed,

       (# Czechia
           SELECT ct.tests_performed
           FROM covid19_tests AS ct
           WHERE ct.country = cd.country
           GROUP BY ct.country
       ) AS tests_per_day,

       (# Czechia
           SELECT c.population_density
           FROM countries AS c
           WHERE c.country = cd.country
           ) AS population_density

FROM covid19_basic_differences AS cd
WHERE cd.date BETWEEN CAST('2020-10-01' AS datetime) AND CAST('2020-11-01' AS datetime)
;


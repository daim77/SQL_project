# translate wrong name of countries
SELECT cd.date,
       cd.country,
       ltlt.iso3,
       if(INSTR(wdwd.working_days, CAST(dayofweek(cd.date) AS char)) != 0, 1, 0) as working_days,

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

       cd.confirmed,
       ctct.tests_performed,
       round(cc.population_density, 2) as population_density,

       round(ee.GDP / ee.population, 0) as GDP_per_capita_2015,
       ee.gini as GINI_index_2015,
       ee.mortaliy_under5 as child_mortality_2015


FROM covid19_basic_differences as cd

LEFT OUTER JOIN (SELECT lt.iso3, lt.country FROM lookup_table as lt) as ltlt on ltlt.country = cd.country
#Czechia
LEFT OUTER JOIN (SELECT * FROM t_martin_danek_project_SQL_workingdays as wd) as wdwd on cd.country = wdwd.country
# pokud test neexistuje tam odebira zeme...
LEFT OUTER JOIN (SELECT ct.tests_performed, ct.ISO, ct.date FROM covid19_tests as ct) as ctct on ctct.ISO = ltlt.iso3 and ctct.date = cd.date
LEFT OUTER JOIN (SELECT c.population_density, c.iso3 FROM countries as c) as cc on cc.iso3 = ltlt.iso3

# Czechia
LEFT OUTER JOIN (SELECT * FROM economies as e WHERE e.year = 2015) as ee on ee.country = cd.country



WHERE cd.date BETWEEN CAST('2020-10-01' as datetime) and CAST('2020-10-30' as datetime)
;
#=====
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
           SELECT round(c.population_density, 0)
           FROM countries AS c
           WHERE c.country = cd.country
           ) AS population_density,

       (# Czechia
           SELECT round(e.GDP / e.population, 0)
           FROM economies AS e
           WHERE e.year = 2015
           AND e.country = cd.country
           ) AS GDP_per_capita,

       (# Czechia
           SELECT e.gini
           FROM economies AS e
           WHERE e.year = 2015
           AND e.country = cd.country
           ) AS GINI,

       (# Czechia
           SELECT e.mortaliy_under5
           FROM economies AS e
           WHERE e.year = 2015
           AND e.country = cd.country
           ) AS child_mortality,

       (# Czechia
           SELECT
                round(
                    (
                        SELECT life_expectancy
                        FROM life_expectancy
                        WHERE life_expectancy.year = 2015
                        AND cd.country = life_expectancy.country
                        GROUP BY life_expectancy.country
                        )
                        -
                    (
                        SELECT life_expectancy
                        FROM life_expectancy
                        WHERE life_expectancy.year = 1965
                        AND cd.country = life_expectancy.country
                        GROUP BY life_expectancy.country
                        ),
                    2)
           FROM life_expectancy AS le
           WHERE le.country = cd.country
           LIMIT 1
           ) AS life_exp_diff

FROM covid19_basic_differences AS cd

WHERE cd.date BETWEEN CAST('2020-10-01' AS datetime) AND CAST('2020-11-01' AS datetime)
;
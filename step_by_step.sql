SELECT cd.date,
       cd.country,
       (
       SELECT lt1.iso3
       FROM lookup_table as lt1
       WHERE lt1.country = cd.country
       GROUP BY lt1.country
           ) as ISO3,


#        if(INSTR(wdwd.working_days, CAST(dayofweek(cd.date) AS char)) != 0, 1, 0) as working_days,

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
#        ctct.tests_performed,
       round(cc.population_density, 2) as population_density,

       round(ee.GDP / ee.population, 0) as GDP_per_capita_2015,
       ee.gini as GINI_index_2015,
       ee.mortaliy_under5 as child_mortality_2015


FROM covid19_basic_differences as cd

#Czechia
# LEFT OUTER JOIN (SELECT wd.country, wd.working_days FROM t_martin_danek_project_SQL_workingdays as wd) as wdwd on cd.country = wdwd.country

# # join table for tests
# LEFT OUTER JOIN (
#                 SELECT ct.tests_performed,
#                        ct.ISO,
#                        ct.date
#                 FROM covid19_tests as ct) as ctct
# on ctct.ISO = (
#                 SELECT lt3.iso3
#                 FROM lookup_table as lt3
#                 WHERE cd.country = lt3.country
#                 GROUP BY lt3.country
#                 )
# and ctct.date = cd.date

# table for population
LEFT OUTER JOIN (
                SELECT c.population_density,
                       c.iso3
                FROM countries as c) as cc
on cc.iso3 = (
                SELECT lt2.iso3
                FROM lookup_table as lt2
                WHERE cd.country = lt2.country
                GROUP BY lt2.country
        )

# fetching data from econimies, indexes level 2015
LEFT OUTER JOIN (
                SELECT e.gini,
                       e.GDP,
                       e.population,
                       e.mortaliy_under5,
                       cc.iso3,
                       e.country
                FROM economies as e

                LEFT OUTER JOIN (
                                    SELECT c.country,
                                           c.iso3
                                    FROM countries as c
                                    ) as cc

                on e.country = cc.country
                WHERE e.year = 2015
                ) as ee
on ee.iso3 = (

                SELECT lt.iso3
                FROM lookup_table as lt
                WHERE cd.country = lt.country
                GROUP BY lt.country
    )

WHERE cd.date BETWEEN CAST('2020-10-01' as datetime) and CAST('2020-10-30' as datetime)
AND cd.country = 'Czechia'
;
SELECT cd.date,
       cd.country,
       (
       SELECT lt1.iso3
       FROM lookup_table as lt1
       WHERE lt1.country = cd.country
       GROUP BY lt1.country
           ) as ISO3,


#        if(INSTR(wdwd.working_days, CAST(dayofweek(cd.date) AS char)) != 0, 1, 0) as working_days,

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

#Czechia
# LEFT OUTER JOIN (SELECT wd.country, wd.working_days FROM t_martin_danek_project_SQL_workingdays as wd) as wdwd on cd.country = wdwd.country

# join table for tests
LEFT OUTER JOIN (
                SELECT ct.tests_performed,
                       ct.ISO,
                       ct.date
                FROM covid19_tests as ct) as ctct
on ctct.ISO = (
                SELECT lt3.iso3
                FROM lookup_table as lt3
                WHERE cd.country = lt3.country
                GROUP BY lt3.country
                )
and ctct.date = cd.date

# table for population
LEFT OUTER JOIN (
                SELECT c.population_density,
                       c.iso3
                FROM countries as c) as cc
on cc.iso3 = (
                SELECT lt2.iso3
                FROM lookup_table as lt2
                WHERE cd.country = lt2.country
                GROUP BY lt2.country
        )

# fetching data from econimies, indexes level 2015
LEFT OUTER JOIN (
                SELECT e.gini,
                       e.GDP,
                       e.population,
                       e.mortaliy_under5,
                       cc.iso3,
                       e.country
                FROM economies as e

                LEFT OUTER JOIN (
                                    SELECT c.country,
                                           c.iso3
                                    FROM countries as c
                                    ) as cc

                on e.country = cc.country
                WHERE e.year = 2015
                ) as ee
on ee.iso3 = (

                SELECT lt.iso3
                FROM lookup_table as lt
                WHERE cd.country = lt.country
                GROUP BY lt.country
    )

WHERE cd.date BETWEEN CAST('2020-10-01' as datetime) and CAST('2020-10-30' as datetime)
AND cd.country = 'Czechia'
;

SELECT cd.date,
       cd.country,

       (
           SELECT lt1.iso3
           FROM lookup_table as lt1
           WHERE lt1.country = cd.country AND lt1.province IS NULL
           GROUP BY lt1.country
           )
           as ISO3,

       (
           SELECT
                  CASE
                      WHEN wdwd.working_days IS NOT NULL
                          THEN
                          if(INSTR(wdwd.working_days, CAST(dayofweek(cd.date) AS char)) != 0, 1, 0)
                      ELSE
                          if(INSTR('2, 3, 4, 5, 6', CAST(dayofweek(cd.date) AS char)) != 0, 1, 0)
                      END
           )
           as working_days,

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
           WHERE cd.country = lt.country AND lt.province IS NULL
           GROUP BY lt.country
           )
           as year_season,

       cd.confirmed,
       ctct.tests_performed,
       round(cc.population_density, 2) as population_density,
       cc.median_age_2018,

       round(ee.GDP / ee.population, 0) as GDP_per_capita_2015,
       ee.gini as GINI_index_2015,
       ee.mortaliy_under5 as child_mortality_2015,

        ROUND((
            SELECT le1.life_expectancy
            FROM life_expectancy as le1
            WHERE le1.year = 2015
            AND le1.iso3 = (
                            SELECT lt.iso3
                            FROM lookup_table as lt
                            WHERE cd.country = lt.country AND lt.province IS NULL
                            GROUP BY lt.country
                            ))
                    - (
                        SELECT le2.life_expectancy
                        FROM life_expectancy as le2
                        WHERE le2.year = 1965
                        AND le2.iso3 = (
                                        SELECT lt1.iso3
                                        FROM lookup_table as lt1
                                        WHERE cd.country = lt1.country AND lt1.province IS NULL
                                        GROUP BY lt1.country
                            )
                        ), 2)
            as life_exp_diff


FROM covid19_basic_differences as cd

# table for workingdays
LEFT OUTER JOIN (
                SELECT wd.country,
                       wd.working_days,
                       cc1.iso3
                FROM t_martin_danek_project_SQL_workingdays as wd

                LEFT OUTER JOIN (
                                SELECT c1.country,
                                       c1.iso3
                                FROM countries as c1) as cc1
                on cc1.country = wd.country

                ) as wdwd
on wdwd.iso3 = (

                SELECT lt5.iso3
                FROM lookup_table as lt5
                WHERE cd.country = lt5.country AND lt5.province IS NULL
                GROUP BY lt5.country
                )

# join table for tests problem with US and Poland only first row from tests is needed
LEFT OUTER JOIN (
                SELECT ct.tests_performed,
                       ct.ISO,
                       ct.date
                FROM covid19_tests as ct) as ctct
on ctct.ISO = (
                SELECT lt3.iso3
                FROM lookup_table as lt3
                WHERE cd.country = lt3.country AND lt3.province IS NULL
                GROUP BY lt3.country
                )
and ctct.date = cd.date

# table for population
LEFT OUTER JOIN (
                SELECT c.population_density,
                       c.median_age_2018,
                       c.iso3
                FROM countries as c) as cc
on cc.iso3 = (
                SELECT lt2.iso3
                FROM lookup_table as lt2
                WHERE cd.country = lt2.country AND lt2.province IS NULL
                GROUP BY lt2.country
        )

# fetching data from econimies, indexes level 2018
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
                WHERE e.year = 2018
                ) as ee
on ee.iso3 = (

                SELECT lt4.iso3
                FROM lookup_table as lt4
                WHERE cd.country = lt4.country AND lt4.province IS NULL
                GROUP BY lt4.country
    )

WHERE cd.date BETWEEN CAST('2020-10-01' as datetime) and CAST('2020-10-07' as datetime)
AND cd.country = 'Andorra'
;

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

       round(ee.GDP / ee.population, 0) as GDP_per_capita_2018,
       ee.gini as GINI_index_2018,
       ee.mortaliy_under5 as child_mortality_2018,

       rr.Christianity, rr.Islam, rr.Unaffiliated, rr.Hinduism, rr.Buddhism, rr.Folk, rr.Other, rr.Judaism,

        ROUND((
            SELECT le1.life_expectancy
            FROM life_expectancy as le1
            WHERE le1.year = 2015
            AND le1.iso3 = (
                            SELECT lt1.iso3
                            FROM lookup_table as lt1
                            WHERE cd.country = lt1.country AND lt1.province IS NULL
                            GROUP BY lt1.country
                            ))
                    - (
                        SELECT le2.life_expectancy
                        FROM life_expectancy as le2
                        WHERE le2.year = 1965
                        AND le2.iso3 = (
                                        SELECT lt2.iso3
                                        FROM lookup_table as lt2
                                        WHERE cd.country = lt2.country AND lt2.province IS NULL
                                        GROUP BY lt2.country
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

                SELECT lt3.iso3
                FROM lookup_table as lt3
                WHERE cd.country = lt3.country AND lt3.province IS NULL
                GROUP BY lt3.country
                )

# table tests problem with US and Poland only first row from tests is needed and France
LEFT OUTER JOIN (
                    SELECT MIN(ct.tests_performed) as tests_performed,
                           ct.ISO,
                           ct.date
                    FROM covid19_tests as ct
                    GROUP BY ct.date
                ) as ctct
on ctct.ISO = (
                    SELECT lt4.iso3
                    FROM lookup_table as lt4
                    WHERE cd.country = lt4.country AND lt4.province IS NULL
                    GROUP BY lt4.country
                )
and ctct.date = cd.date

# table population
LEFT OUTER JOIN (
                SELECT c.population_density,
                       c.median_age_2018,
                       c.iso3
                FROM countries as c) as cc
on cc.iso3 = (
                SELECT lt5.iso3
                FROM lookup_table as lt5
                WHERE cd.country = lt5.country AND lt5.province IS NULL
                GROUP BY lt5.country
        )

# fetching data from economies, indexes level 2018
LEFT OUTER JOIN (
                    SELECT e.gini,
                           e.GDP,
                           e.population,
                           e.mortaliy_under5,
                           cc2.iso3,
                           e.country
                    FROM economies as e
                    LEFT OUTER JOIN (
                                        SELECT c2.country,
                                               c2.iso3
                                        FROM countries as c2
                                    ) as cc2

                    on e.country = cc2.country
                    WHERE e.year = 2018
                ) as ee
on ee.iso3 = (

                SELECT lt6.iso3
                FROM lookup_table as lt6
                WHERE cd.country = lt6.country AND lt6.province IS NULL
                GROUP BY lt6.country
            )
LEFT OUTER JOIN (
                    SELECT
                           MAX(CASE WHEN r.religion = 'Christianity' THEN ROUND(100 * r.population / cc3.population, 2) END) as Christianity,
                           MAX(CASE WHEN r.religion = 'Islam' THEN ROUND(100 * r.population / cc3.population, 2) END) as Islam,
                           MAX(CASE WHEN r.religion = 'Unaffiliated Religions' THEN ROUND(100 * r.population / cc3.population, 2) END) as Unaffiliated,
                           MAX(CASE WHEN r.religion = 'Hinduism' THEN ROUND(100 * r.population / cc3.population, 2) END) as Hinduism,
                           MAX(CASE WHEN r.religion = 'Buddhism' THEN ROUND(100 * r.population / cc3.population, 2) END) as Buddhism,
                           MAX(CASE WHEN r.religion = 'Folk Religions' THEN ROUND(100 * r.population / cc3.population, 2) END) as Folk,
                           MAX(CASE WHEN r.religion = 'Other Religions' THEN ROUND(100 * r.population / cc3.population, 2) END) as Other,
                           MAX(CASE WHEN r.religion = 'Judaism' THEN ROUND(100 * r.population / cc3.population, 2) END) as Judaism,
                           cc3.iso3,
                           r.year,
                           r.country
                    FROM religions as r

                    LEFT OUTER JOIN (
                                        SELECT c3.country,
                                               c3.iso3,
                                               c3.population
                                        FROM countries as c3
                                    ) as cc3
                    on cc3.country = r.country
                    WHERE r.year = 2020

                ) as rr

on rr.iso3 = (
                SELECT lt7.iso3
                FROM lookup_table as lt7
                WHERE cd.country = lt7.country AND lt7.province IS NULL
                GROUP BY lt7.country
                )

WHERE cd.date BETWEEN CAST('2020-10-01' as datetime) and CAST('2020-10-20' as datetime)
AND cd.country = 'Czechia'
;

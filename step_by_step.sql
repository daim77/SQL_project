CREATE TABLE t_martin_danek_project_SQL_final as

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

       round(ee.GDP / ee.population, 2) as GDP_per_capita_2018,
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
            as life_exp_diff,

        ROUND((ww.temp_6 + ww.temp_15 + 2*ww.temp_21)/4, 2) as temp_avrg_day,
        ((rain_0 + rain_3 + rain_6 + rain_9 + rain_12 + rain_15 + rain_18 + rain_21) * 3) as rain_hrs,
        ROUND((ww.gust_6 + ww.gust_9 + ww.gust_12 + ww.gust_15 + ww.gust_18 + ww.gust_21)/6, 2) as wind_gust

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

# table tests problem with US and Poland only first row from tests is needed and France, NULL values!!
LEFT OUTER JOIN (
                    SELECT MIN(ct.tests_performed) as tests_performed,
                           ct.ISO,
                           ct.date
                    FROM covid19_tests as ct
                    GROUP BY ct.country, ct.date
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

# religion table population - NULL values
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
                           cc3.iso3
                    FROM religions as r

                    LEFT OUTER JOIN (
                                        SELECT c3.country,
                                               c3.iso3,
                                               c3.population
                                        FROM countries as c3
                                    ) as cc3
                    on cc3.country = r.country
                    WHERE r.year = 2020
                    GROUP BY r.country

                ) as rr

on rr.iso3 = (
                SELECT lt7.iso3
                FROM lookup_table as lt7
                WHERE cd.country = lt7.country AND lt7.province IS NULL
                GROUP BY lt7.country
                )

# table weather
LEFT OUTER JOIN (
                    SELECT  wx.date,

                            MAX(CASE WHEN wx.hour = 6 THEN wx.temp END) as temp_6,
                            MAX(CASE WHEN wx.hour = 15 THEN wx.temp END) as temp_15,
                            MAX(CASE WHEN wx.hour = 21 THEN wx.temp END) as temp_21,

                            MAX(CASE WHEN wx.hour = 0 THEN IF(wx.rain != 0, 1, 0) END) as rain_0,
                            MAX(CASE WHEN wx.hour = 3 THEN IF(wx.rain != 0, 1, 0) END) as rain_3,
                            MAX(CASE WHEN wx.hour = 6 THEN IF(wx.rain != 0, 1, 0) END) as rain_6,
                            MAX(CASE WHEN wx.hour = 9 THEN IF(wx.rain != 0, 1, 0) END) as rain_9,
                            MAX(CASE WHEN wx.hour = 12 THEN IF(wx.rain != 0, 1, 0) END) as rain_12,
                            MAX(CASE WHEN wx.hour = 15 THEN IF(wx.rain != 0, 1, 0) END) as rain_15,
                            MAX(CASE WHEN wx.hour = 18 THEN IF(wx.rain != 0, 1, 0) END) as rain_18,
                            MAX(CASE WHEN wx.hour = 21 THEN IF(wx.rain != 0, 1, 0) END) as rain_21,

                            MAX(CASE WHEN wx.hour = 6 THEN wx.gust END) as gust_6,
                            MAX(CASE WHEN wx.hour = 9 THEN wx.gust END) as gust_9,
                            MAX(CASE WHEN wx.hour = 12 THEN wx.gust END) as gust_12,
                            MAX(CASE WHEN wx.hour = 15 THEN wx.gust END) as gust_15,
                            MAX(CASE WHEN wx.hour = 18 THEN wx.gust END) as gust_18,
                            MAX(CASE WHEN wx.hour = 21 THEN wx.gust END) as gust_21,

                            cc4.iso3
                    FROM weather as wx

                    LEFT OUTER JOIN (
                                        SELECT c4.iso3,
                                                c4.capital_city
                                        FROM countries as c4
                                        ) as cc4
                    on wx.city = cc4.capital_city
                    GROUP BY wx.city, wx.date
                ) as ww

on ww.iso3 = (
                SELECT lt8.iso3
                FROM lookup_table as lt8
                WHERE cd.country = lt8.country AND lt8.province IS NULL
                GROUP BY lt8.country
                )
AND ww.date = cd.date

WHERE cd.date BETWEEN '2020-01-01' and '2020-06-30'
AND cd.country like 'B%'
;

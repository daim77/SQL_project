# duration 8 min

DROP TABLE IF EXISTS t_martin_danek_project_SQL_final;

CREATE TABLE
    t_martin_danek_project_SQL_final (
        date date,
        country varchar(255),
        iso3 varchar(3),
        confirmed int,
        working_days tinyint UNSIGNED,
        year_season tinyint UNSIGNED,
        tests_performed int,
        index country_index(country),
        index date_index(date)

) AS

WITH country_key as (
    SELECT c.country,
           c.iso3,
           ROUND(c.population_density, 2) as population_density,
           c.median_age_2018,
           c.population,

           ROUND(ee.GDP / ee.population, 2) as GDP_per_capita_2018,
           ee.gini,
           ee.mortaliy_under5,

           wd.working_days,

           lele.life_expectancy_2015,
           lele.life_expectancy_1965
    FROM countries as c

    LEFT OUTER JOIN
         (
             SELECT e.year,
                    e.country,
                    e.GDP,
                    e.population,
                    e.gini,
                    e.mortaliy_under5
             FROM economies as e
             WHERE e.year = 2018
         ) as ee
        on c.country = ee.country

    LEFT OUTER JOIN
         t_martin_danek_project_SQL_workingdays as wd
        on c.country = wd.country

    LEFT OUTER JOIN
         (
             SELECT MAX(CASE WHEN le.year = 2015 THEN life_expectancy END) as life_expectancy_2015,
                    MAX(CASE WHEN le.year = 1965 THEN life_expectancy END) as life_expectancy_1965,
                    le.country
             FROM life_expectancy as le
             GROUP BY le.country
         ) as lele
        on c.country = lele.country

),
     religion_iso as (
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
                r.country
        FROM religions as r
        LEFT OUTER JOIN (
                        SELECT
                            c3.country,
                            c3.iso3,
                            c3.population
                        FROM countries as c3
                ) as cc3
        on cc3.country = r.country
        WHERE r.year = 2020
        GROUP BY r.country
),
     weather_iso AS (
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
                        SELECT
                               c4.iso3,
                               c4.capital_city
                        FROM countries as c4
                        ) as cc4
        on wx.city = cc4.capital_city
        GROUP BY wx.city, wx.date
),
     c19_diff as (
         SELECT c19bd.date,
                c19bd.country,
                c19bd.confirmed,
                ll19bd.iso3
         FROM covid19_basic_differences as c19bd
         LEFT OUTER JOIN
             (
                 SELECT l19bd.country,
                        l19bd.iso3
                 FROM lookup_table as l19bd
                 WHERE l19bd.province IS NULL
                GROUP BY l19bd.country
                 ) as ll19bd
         on ll19bd.country = c19bd.country
)

    SELECT
        cd.date,
        cd.country,
        cd.iso3,
        cd.confirmed,

    (
        SELECT
            CASE
                WHEN ck.working_days IS NOT NULL
                THEN
                if (INSTR(ck.working_days, CAST(dayofweek(cd.date) AS char)) != 0, 1, 0)
                ELSE
                if (INSTR('2, 3, 4, 5, 6', CAST(dayofweek(cd.date) AS char)) != 0, 1, 0)
            END
    ) as working_days,

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
    ) as year_season,

    ctct.tests_performed,

    ck.population_density,
    ck.median_age_2018,
    ck.GDP_per_capita_2018,
    ck.gini,
    ck.mortaliy_under5,

    ris.Christianity, ris.Islam, ris.Judaism, ris.Hinduism, ris.Buddhism, ris.Folk, ris.Unaffiliated, ris.Other,

    ROUND(ck.life_expectancy_2015 - ck.life_expectancy_1965, 2) as life_exp_improvement,

    ROUND((wis.temp_6 + wis.temp_15 + 2*wis.temp_21)/4, 2) as temp_avrg_day,
    ((rain_0 + rain_3 + rain_6 + rain_9 + rain_12 + rain_15 + rain_18 + rain_21) * 3) as rain_hrs,
    ROUND((wis.gust_6 + wis.gust_9 + wis.gust_12 + wis.gust_15 + wis.gust_18 + wis.gust_21)/6, 2) as wind_gust


    FROM c19_diff as cd

    LEFT OUTER JOIN country_key as ck
    on ck.iso3 = cd.iso3

    LEFT OUTER JOIN (
        SELECT
               ct.tests_performed,
               ct.ISO,
               ct.date
        FROM covid19_tests as ct
        WHERE entity = 'tests performed'
    ) as ctct
    on ctct.ISO = ck.iso3 and ctct.date = cd.date

    LEFT OUTER JOIN religion_iso as ris
    on ris.iso3 = ck.iso3

    LEFT OUTER JOIN weather_iso as wis
    on wis.iso3 = ck.iso3 and wis.date = cd.date

;

# SQL_project  
**ASSIGNMENT SECTION**  

**COVID ANALYSIS with panel data**  
keys: country, date and _iso3_ added  

**COLUMNS:**  

_covid data_  
- country [name sometimes non standard]
- diff confirmed cases [amount, -]
- tests performed  [amount, -]

_time related_
- date [yyyy-mm-dd]
- binary variable for  weekend / working days [1 = working days, 0 = weekend]
- the four seasons codes (from 0 till 3) [0 - winter, 1 - spring, 2 - summer, 3 - fall]

_demografic related_
- density population [habitant / km2]
- GDP per habitant [year 2018, USD/person]
- GINI coeficient  [y 2018]
- child mortality [per 1000 live birth in 2018]
- population age median in 2018 [years]
- population religion ratio -> related to total country population for every religion in the single country [%]
- difference life expectancy 1965 compered to 2015  [years]

_weather related_  
- average daylight temperature  ! SR to SS
- amount of hours with any precipitations
- max gust wind effort during day [km per hour]

**data source**  
countries  
economies  
life_expectancy  
religions  
covid19_basic_differences  
covid19_testing  
weather  
lookup_table  

_t_martin_danek_project_SQL_working_days /from WIKI_  

**required output**  
t_{jméno}_{příjmení}_project_SQL_final  
prepared for one SQL SELECT operation

## SOLUTION  
UNITS are in the square brackets in an assignment section  
ISO3 country code added as possible future key 

**COVID**  
in the covid19_basic_differences table source - Taiwan is coded as Taiwan*, so same coding in final OUTPUT  


**wiki_working_days.py**  
This script scrap a table from wiki and saves data to MariaDB database on ENGETO server  
Different country == different working days  
coding is as SQL DAYOFWEEK() 1: sunday, 7: saturday  
IF country NOT in this table THEN saturday and sunday is weekend.  


**ECONOMY**
Majority of values are available in year 2015 in table economies. GINI index is available for MAX countries for example but still only for 80..  
But y2018 chosen due to client requirements  


**RELIGION**  
Wrong data in religion table (Islam population in Afghanistan > total population)  


**WEATHER**  
City is used as key bridge to countries table. There is inconsistency between several capitals like Prague vs Praha, Wien vs Vienna atc...
This problem leads to NULL values for all weather characteristics!  
average daytime temperature calculated according standard meteorological formula.  
Average gust calculated as average gust between 6 a.m. and 9 p.m.  For more precise calculation WGF is needed.  
Due to 3hrs interval measurement - rain is expected also 1.5 hr before raining time and same after.  





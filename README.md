# SQL_project
**COVID ANALYSIS with panel data**  
keys: country, date  

**COLUMNS:**  

_covid data_  
- country
- diff confirmed cases [amount, -]
- tests performed  [amount, -]

_time related_
- date [yyyy-mm-dd]
- binary variable for  weekend / working days [1 = working days, 0 = weekend]
- the four seasons codes (from 0 till 3) [0 - winter, 1 - spring, 2 - summer, 3 - fall]

_demografic related_
- density population [habitant / km2]
- GDP per habitant
- GINI coeficient  
- child mortality
- population age median in 2018
- population religion ratio -> related to total country population
- difference life expectancy 1965 compered to 2015  

_weather related_  
- average daylight temperature  ! SR to SS
- amount of hours with any precipitations
- max gust wind effort during day

**data source**  
countries  
economies  
life_expectancy  
religions  
covid19_basic_differences  
covid19_testing  
weather  
lookup_table  
t_martin_danek_project_SQL_working_days /from WIKI  

**required output**  
t_{jméno}_{příjmení}_project_SQL_final  
prepared for one select operation

## SOLUTION  
**wiki_working_days.py**  
This script scrap table from wiki and saves data to MariaDB database on server  
Different country == different working days  
coding is as SQL DAYOFWEEK() 1: sunday, 7: saturday   


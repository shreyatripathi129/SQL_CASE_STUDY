--Flight Dataset Case Study

create database Flight_dataset

1.Retrieve the flight dataset

Solution: 
select * from flight

2.Count the number of records present in flight dataset

Solutionn:
select count(*) from flight

3. Find the month with most number of flights

Solution:  
select Monthname(date_of_journey) as Month_name, count(*) as total_count_of_flights
from flight
group by Monthname(date_of_journey) 
order by count(*) desc
limit 1


4. Which week day has most costly flights

Solution:
select dayname(date_of_journey) as week_day, avg(price) as avg_price
from flight
group by dayname(date_of_journey) 
order by avg_price desc
limit 1

5. Find number of indigo flights every month

Solution:
select monthname(date_of_journey) as Month , count(*) as Total_number_of_flights
from flight
where Airline='IndiGo'
group by monthname(date_of_journey) 
order by monthname(date_of_journey)  asc


6.Find list of all flights that depart between 10AM and 2PM from  Banglore to Delhi.

Solution:
SELECT * FROM flight
WHERE source = 'Banglore' AND 
destination = 'Delhi' AND
dep_time > '10:00:00' AND dep_time < '14:00:00';


7. Find the number of flights departing on weekends from Bangalore.

Solution:
select * from flight 
where source='Banglore' 
and Dayname(date_of_journey) in ('Sunday','Saturday')


8. Calculate the arrival date for all the flights by adding the duration of the departure time.

solution:
--First creating a new column name as Departure as we dont have any column which shows the departure of any flight in datetime format(It will be helpful in writing other queries as well).
Alter table flight add column Departure DATETIME

--Updating the records in Departure Table
update flight
SET Departure =str_to_date(concat(date_of_journey,' ',dep_time),'%Y-%m-%d %H:%i') 

--Create Two more Column name - Duration_min and Arrival 
Alter table flight add column Duration_min Integer
Alter table flight add column Arrival DATETIME

--Updating record in column - Duration_min and Arrival
update flight
set duration_min = 
CASE
    WHEN  duration like '%h%m' then SUBSTRING_INDEX(duration,'h',1)*60 + SUBSTRING_INDEX(SUBSTRING_INDEX(duration, 'm', 1), ' ', -1)
	WHEN duration like '%h' then SUBSTRING_INDEX(duration,'h',1)*60
    When duration like '%m' then SUBSTRING_INDEX(duration,'m',1)
    ELSE 0
END 

Update flight
set Arrival = DATE_ADD(departure, INTERVAL duration_min MINUTE) 

--Final output will include the Arrival date and time of the flight in a new column Arrival.
select * from flight

--Final solution Need to retrive the Time of arrival of each flights
select time(arrival) from flight


9. Calculate the arrival date of each flights

Solution:
select date(arrival) from flight

10. Find the number of flights which travels on multiple dates

Solution:
select count(*)
from flight
where date(date_of_journey)!=date(Arrival)

11. Calculate the average duration of flights between all city pairs. The answer should In xh ym format

Solution:
select source,destination,sec_to_time(avg(duration_min)*60) from flight
group by source,destination


12.Find all flights which departed before midnight but arrived at their destination after midnight having only 0 stops.

Solution:
select * from flight
where total_stops='non-stop' and date(departure)<date(arrival)


13. Find quarter wise number of flights for each airline.

Solution:
select Airline,quarter(date_of_journey), count(*)
from flight
group by Airline, quarter(date_of_journey)
order by Airline, quarter(date_of_journey)

14. Find the longest flight distance(between cities in terms of time) in India

Solution:
select source,destination,
time_format(sec_to_time(MAX(duration_min)*60), '%kh %im')  as Max_distance
from flight
group by source,destination
order by max_distance desc
limit 1


15. Average time duration for flights that have 1 stop vs more than 1 stops

Solution:
with cte as (
             select 'More_than_1_stop' as 'Stops' ,time_format(sec_to_time(avg(duration_min)*60), '%kh %im') as average_duration
             from flight
             where total_stops not in ('Non stop', '1 stop')
)
select '1_stop' as 'Stops', time_format(sec_to_time(avg(duration_min)*60), '%kh %im') as average_duration
from flight
where total_stops in ('1 stop')
union
select * from cte


16. Find all Air India flights in a given date range originating from Delhi
Date range between '1 March 2019' and '10 March 2019'

Solution:
select * 
from flight
where Airline='Air India' and source='Delhi'
and (date(departure) between '2019-03-01'  and  '2019-03-10')

17. Find the longest flight of each airline

Solution:
select Airline, 
time_format(sec_to_time(MAX(duration_min)*60), '%kh %im') as Longest_Flight
from flight
group by Airline 
order by MAX(duration_min) desc

18. Find all the pair of cities having average time duration > 3 hours

Solution:
select source,destination,
time_format(sec_to_time(avg(duration_min)*60), '%kh %im') as average_duration
from flight
group by source,destination
having avg(duration_min)>180


19.Make a weekday vs time grid showing frequency of flights from Banglore and Delhi

Solution:
Select dayname(departure) ,
sum(case when time(dep_time) between '00:00' and '06:00' then 1 else 0 end ) as Early_morning_slot_between_12am_to_6am,
sum(case when time(dep_time) between '06:00' and '12:00' then 1 else 0 end ) as Morning_slot_between_6am_to_12pm,
sum(case when time(dep_time) between '12:00' and '18:00' then 1 else 0 end ) as Afternoon_slot_between_12pm_to_6pm,
sum(case when time(dep_time) between '18:00' and '23:59' then 1 else 0 end ) as Evening_slot_between_6pm_to_12am
from flight
where source='Banglore' and destination='Delhi'
group by dayname(departure)


20. Make a weekday vs time grid showing avg flight price from Banglore and Delhi

Solution:
Select dayname(departure) ,
avg(case when time(dep_time) between '00:00' and '06:00' then price else 0 end ) as Early_morning_slot_between_12am_to_6am,
avg(case when time(dep_time) between '06:00' and '12:00' then price else 0 end ) as Morning_slot_between_6am_to_12pm,
avg(case when time(dep_time) between '12:00' and '18:00' then price else 0 end ) as Afternoon_slot_between_12pm_to_6pm,
avg(case when time(dep_time) between '18:00' and '23:59' then price else 0 end ) as Evening_slot_between_6pm_to_12am
from flight
where source='Banglore' and destination='Delhi'
group by dayname(departure)

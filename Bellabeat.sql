/* 
In this project, for the cleaning process, I used Microsoft Excel and SQL to streamline the process.
I identify and rectify irregularities such as empty spaces, duplicates, and inconsistent column lengths.
I refine column names, eliminate redundant fields, and add supplementary columns for clarity.
This ensures accurate and efficient data analysis.
*/

--1. How many unique user Ids are in each table?
-- Counting number of uniqe Ids in each table
SELECT COUNT (DISTINCT Activity_tbl.Id) AS act_Id, COUNT(DISTINCT Sleep_tbl.Id) AS slp_Id, COUNT(DISTINCT Weight_tbl.Id) AS wght_Id, COUNT(DISTINCT Steps_tbl.Id) AS step_Id
FROM Bella_Project.dbo.dailyActivity_merged AS Activity_tbl
-- Full join gives results from all tables listed independent of other table's content
FULL JOIN Bella_Project.dbo.sleepDay_merged     AS Sleep_tbl    ON Activity_tbl.Id = Sleep_tbl.Id
FULL JOIN Bella_Project.dbo.weight_merged       AS Weight_tbl   ON Activity_tbl.Id = Weight_tbl.Id
FULL JOIN Bella_Project.dbo.hourlySteps_merged  AS Steps_tbl    ON Activity_tbl.Id = Steps_tbl.Id


-- 2. How many of users overlap in each table?
-- Counting number of distinct IDs shared by all tables
SELECT COUNT (DISTINCT Activity_tbl.Id) AS act_Id, COUNT(DISTINCT Sleep_tbl.Id) AS slp_Id, COUNT(DISTINCT Weight_tbl.Id) AS wght_Id, COUNT(DISTINCT Steps_tbl.Id) AS step_Id
FROM Bella_Project.dbo.dailyActivity_merged AS Activity_tbl
-- Inner Join results in only matching Ids found in all tables listed
JOIN Bella_Project.dbo.sleepDay_merged     AS Sleep_tbl    ON Activity_tbl.Id = Sleep_tbl.Id
JOIN Bella_Project.dbo.weight_merged       AS Weight_tbl   ON Activity_tbl.Id = Weight_tbl.Id
JOIN Bella_Project.dbo.hourlySteps_merged  AS Steps_tbl    ON Activity_tbl.Id = Steps_tbl.Id


-- 3. What specific user Ids are in or lacking from each table?
-- Verifying IDs are consistent across tables and shows which Ids are shared or absent from tables
SELECT DISTINCT Activity_tbl.Id AS act_Id, Sleep_tbl.Id AS slp_Id, Weight_tbl.Id AS wght_Id, Steps_tbl.Id AS step_Id
FROM Bella_Project.dbo.dailyActivity_merged AS Activity_tbl 
-- Full Join allows results including null values from all tables joined
FULL JOIN Bella_Project.dbo.sleepDay_merged      AS Sleep_tbl    ON Activity_tbl.Id = Sleep_tbl.Id
FULL JOIN  Bella_Project.dbo.weight_merged       AS Weight_tbl   ON Activity_tbl.Id = Weight_tbl.Id
FULL JOIN Bella_Project.dbo.hourlySteps_merged   AS Steps_tbl    ON Activity_tbl.Id = Steps_tbl.Id


-- 4. What user ids overlap sets?
-- Change Join method to Inner Join which results in only user Ids that are found in all listed tables, exclude null values. Results in user Ids that overlap all tables
SELECT  DISTINCT Weight_tbl.Id 
FROM Bella_Project.dbo.weight_merged       AS  Weight_tbl
-- Inner Join results in only matching Ids found in all tables listed
JOIN Bella_Project.dbo.sleepDay_merged        AS  Sleep_tbl    ON  Weight_tbl.Id = Sleep_tbl.Id
JOIN Bella_Project.dbo.hourlySteps_merged     AS  Steps_tbl    ON  Weight_tbl.Id = Steps_tbl.Id
JOIN Bella_Project.dbo.dailyActivity_merged   AS  Activity_tbl ON  Weight_tbl.Id = Activity_tbl.Id
-- These users will be used later as the "overlap" group to see if any trends are present for users that use all sets vs those that do not.
-- Analysis: Only 6 users overlap in all of the datasets used


-- 5. How much activity are users performing on average? 
-- Average Activity data and grouping by User Id. 
SELECT DISTINCT Id,
 COUNT(Id) AS logs,
 AVG(Steps) AS avg_steps,
 round(AVG(Distance),2) AS avg_distance, 
 AVG(Very_Active_Minutes) AS avg_very_min,
 AVG(Fairly_Active_Minutes) AS avg_fair_min,
 AVG(Lightly_Active_Minutes) AS avg_light_min,
 AVG(Sedentary_Minutes) AS avg_sedentary_min,
 AVG(Calories) AS avg_calories_burned
FROM Bella_Project.dbo.dailyActivity_merged AS Activity_tbl
GROUP BY Id
ORDER BY Id
-- Saved table as dataset: “activity_avgs_by_id”
/* Analysis: 
-21 of the 33 users tracked data for the full month.
-20 got at least 7,000 steps, 7 over 10,000 steps, and 14 had below 7,000 steps. 
-20 users are getting at least 20 min of a combination of vigorous(very) and moderate(fairly) level of activity. Many exceed 20 minutes with 6 users getting over an hour of this level of activity on average.
*/ 


-- 6. How much sleep do users get on average?
-- Compile sleep data into averages by user Id
SELECT *, avg_min_asleep/60 AS avg_hour_asleep     
FROM (      
   SELECT DISTINCT Id,      
    COUNT(Id) AS total_logs,      
    SUM(Time_Awake) AS total_min_awake_in_bed,     
    AVG(Time_Awake) AS avg_min_awake_in_bed,     
    SUM(Time_Asleep) AS total_min_asleep,      
    AVG(Time_Asleep) AS avg_min_asleep     
 FROM Bella_Project.dbo.sleepDay_merged     
 GROUP BY Id  ) AS S
-- Saved table as dataset: "sleep_totals_by_id"
/* Analysis:
-Only 3 users tracked their sleep for the full month. 
-15 of the 24 did complete at least half of the month at 15 daily logs or more 
-12 got at least 7 hours of sleep. the other 12 got less than 7 hours. 
-Most users have time disrupted from sleep, 19 of the 24 had more than 15 minutes of being awake during their sleep cycle.
*/


-- 7. Combine activity and sleep averages
-- Combine the sleep and activity data grouped by Id into one table
SELECT *
FROM Bella_Project.dbo.activity_avgs_by_id
JOIN Bella_Project.dbo.sleep_totals_by_id ON activity_avgs_by_id.Id = sleep_totals_by_id.Id
ORDER BY sleep_totals_by_id.Id
-- Saved table as avg_act_sleep_by_id


-- 8. What days do the most and least activity take place on?
-- Average user activity and sleep data. Group by day to see day to day and weekly trends.
SELECT Day, COUNT(Day) AS logs,
 AVG(Steps) AS avg_steps,
 AVG(Very_Active_Minutes) AS avg_very_act_min,
 AVG(Fairly_Active_Minutes) AS avg_fairly_act_min,
 AVG(Lightly_Active_Minutes) AS avg_lightly_act_min,
 AVG(Sedentary_Minutes) AS avg_sedentary_min,
 round(AVG(Distance),2) AS avg_dist,
 AVG(Calories) AS avg_calories_burned
FROM Bella_Project.dbo.dailyActivity_merged
GROUP BY day
ORDER BY 
-- Assign a numerical value to the days so they can be ordered correctly (Otherwise SQL orders alphabetically)                  
     CASE
WHEN Day = 'Sunday' THEN 1
WHEN Day = 'Monday' THEN 2  
WHEN Day = 'Tuesday' THEN 3  
WHEN Day = 'Wednesday' THEN 4
WHEN Day = 'Thursday' THEN 5
WHEN Day = 'Friday' THEN 6
WHEN Day = 'Saturday' THEN 7
     END ASC
-- Saved this table as dataset: “avg_activity_day”
/* Analysis:
-On average users are getting over 7,000 steps except on Sundays. Users are getting over 8,000 on Tuesdays and Saturdays 
-Users are meeting the weekly recommended 150-300 minutes of activity (combination of  vigorous and moderate) at 243.44 minutes on average. 
-Users are traveling over 5 Km on average each day 
-The amount of calories burned is consistently around 2300 kcal a day except for Sundays and Thursdays
-The most active day is Saturday with  244 minutes of combined activity (very, fairly, and light active levels), and the least is Sunday with 208 minutes 
-The most sedentary day is Monday with 1027.9 min and the least is Thursday with 961.9 min 
*/


-- 9. What days do users have the most and least sleep?
/*SELECT *,
-- Add a column for minutes asleep converted to hours
(avg_min_asleep/60) AS avg_hour_asleep 
FROM (
SELECT Day, COUNT(Day) AS number_of_days,
-- Counting how many of each day is included in its grouped row.
AVG(Time_Awake) AS avg_min_awake_in_bed,   
AVG(Time_Asleep) AS avg_min_asleep     
FROM Bella_Project.dbo.sleepDay_merged   
GROUP BY Day
/*ORDER BY
CASE      
WHEN Day = 'Sunday' THEN 1      
WHEN Day = 'Monday' THEN 2      
WHEN Day = 'Tuesday' THEN 3     
WHEN Day = 'Wednesday' THEN 4     
WHEN Day = 'Thursday' THEN 5      
WHEN Day = 'Friday' THEN 6      
WHEN Day = 'Saturday' THEN 7      
 END ASC*/
 ) as a*/
-- Saved this table as dataset: “avg_sleep_by_day”
/* Analysis: 
-Users get the most sleep and the recommended at least 7 hours on Sundays, Wednesdays, and Saturdays. The rest of the week users get 6.7-6.9 hours of sleep.  
-The more sleep users get the greater amount of time they spend in bed awake throughout the week with Sundays having an average 50 minutes of restless sleep. 
*/
-- sol_2, creating new temprory table(table is sorted!)
select Day, COUNT(Day) AS number_of_days, AVG(Time_Awake) AS avg_min_awake_in_bed, AVG(Time_Asleep) AS avg_min_asleep  
 INTO avg_sleep_by_day1
 From Bella_Project.dbo.sleepDay_merged  
 GROUP BY Day

SELECT * , (avg_min_asleep/60) AS avg_hour_asleep  
from avg_sleep_by_day1
 ORDER BY CASE      
WHEN Day = 'Sunday' THEN 1      
WHEN Day = 'Monday' THEN 2      
WHEN Day = 'Tuesday' THEN 3     
WHEN Day = 'Wednesday' THEN 4     
WHEN Day = 'Thursday' THEN 5      
WHEN Day = 'Friday' THEN 6      
WHEN Day = 'Saturday' THEN 7      
 END ASC


-- 10. Combine activity and sleep data
-- Selecting sleep and activity level columns from activity and sleep datasets
SELECT 
 avg_sleep.Day,
 avg_sleep.number_of_days AS sleep_logs,
 avg_act.logs AS activity_logs,
 avg_sleep.avg_min_awake_in_bed, avg_sleep.avg_min_asleep,
(avg_min_asleep/60)  as avg_hour_asleep, avg_very_act_min,
 avg_fairly_act_min, avg_lightly_act_min, avg_sedentary_min
FROM Bella_Project.dbo.avg_sleep_by_day as avg_sleep
-- Joining datasets to have both activity and sleep data in one set
JOIN Bella_Project.dbo.avg_activity_day as avg_act ON avg_act.Day = avg_sleep.Day
 /*ORDER BY   
      CASE              
          WHEN Day = 'Sunday' THEN 1
          WHEN Day = 'Monday' THEN 2
          WHEN Day = 'Tuesday' THEN 3
          WHEN Day = 'Wednesday' THEN 4
          WHEN Day = 'Thursday' THEN 5
          WHEN Day = 'Friday' THEN 6
          WHEN Day = 'Saturday' THEN 7
        END ASC; */
     

-- 11. Are there any activity trends over time?
-- Average all results by date and sort into one row for each specific date
SELECT DISTINCT Date,
 COUNT(Id) AS logs,
 AVG(Steps) AS avg_steps,
 round(AVG(Distance),2) AS avg_distance, 
 AVG(Very_Active_Minutes) AS avg_very_act_min,
 AVG(Fairly_Active_minutes) AS avg_fairly_act_min,
 AVG(Lightly_Active_Minutes) AS avg_light_min,
 AVG(Sedentary_Minutes) AS avg_sedentary_min,
 AVG(Calories) AS avg_calories_burned
FROM Bella_Project.dbo.dailyActivity_merged 
GROUP BY Date 
ORDER BY Date
-- Saved table as "avg_act_dates"
/* Analysis:
-Users gradually stopped logging activity data over the month with the largest decline occurring from may 8 - 12th 27 users to 21 users. 
-Users had at least 7,000 steps on 27 of the 31 days and less than 7,000 on only 4 days.
*/


-- 12. Are there any sleep trends over time?
SELECT Date,      
 COUNT(Date) AS logs,      
 SUM(Time_Awake) AS total_min_awake_in_bed,     
 AVG(Time_Awake) AS avg_min_awake_in_bed,     
 SUM(Time_Asleep) AS total_min_asleep,      
 AVG(Time_Asleep) AS avg_min_asleep
INTO avg_sleep_by_date  
 FROM Bella_Project.dbo.sleepDay_merged  
 GROUP BY Date

 select * from avg_sleep_by_date  
 order by Date
-- Results in user ids being grouped into single average entry for each date

/* Analysis:
-Users did not use the sleep tracker consistently as seen by the variance in logs from day to day.
-16 of the 31 days users met the recommended 7 hours of sleep 
-When averaged users do get 7 hours of sleep over the month long timeline 
*/


-- 13. Combine activity and sleep data
-- Combine average activity and sleep data into one table organized by date
SELECT sleep_date.Date, avg_steps, round(avg_distance,2) AS avg_distance, avg_very_act_min, avg_fairly_act_min, avg_light_min, avg_sedentary_min, avg_calories_burned, avg_min_awake_in_bed, avg_min_asleep
FROM Bella_Project.dbo.avg_act_dates as sleep_date
JOIN Bella_Project.dbo.avg_sleep_by_dates as act_date ON act_date.Date = sleep_date.Date
ORDER BY sleep_date.Date


-- 14. What are the average weights and how often are they logged?
-- Find number of times users logged weight data and average weight data entered
SELECT 
 DISTINCT Id,
 COUNT(Id) AS total_logs,
ROUND(AVG(Weight_Pounds),2) AS avg_weight_lbs,
 ROUND(AVG(BMI),2) AS avg_BMI
FROM Bella_Project.dbo.weight_merged
GROUP BY Id
ORDER BY Id
-- Saved table as dataset: "weight_avgs"
/* Analysis:
-The average weight is 171.54 pounds 
-Average BMI is 27.98
-Only 8 users tracked weight and of those only 2 checked weight a significant amount of time (24 and 30 logs)
*/

--extracing a table from weight_merged contains start_date and end_date 
SELECT Id, 
    COUNT(*) AS total_logs,
    MIN(Date) AS start_date,
    MAX(Date) AS end_date
FROM
   Bella_Project.dbo.weight_merged
GROUP BY
    Id
--save this table as start_end_weight


-- 15a. When are users tracking weight? (The following 2 queries are used to group the data before joining into one table)
-- Find first weight data logged
SELECT weight.Id, start_date, ROUND(weight_pounds,2) AS start_pounds
FROM Bella_Project.dbo.weight_merged AS weight
JOIN Bella_Project.dbo.start_end_weight AS start_end ON weight.Id = start_end.Id
WHERE Date = start_date
-- Saved table as: â€œweight_start_dateâ€


-- 15b.
-- Find the last weight data logged 
SELECT weight.Id, end_date, ROUND(weight_pounds,2) AS end_pounds
FROM Bella_Project.dbo.weight_merged AS weight
JOIN Bella_Project.dbo.start_end_weight AS start_end ON weight.Id = start_end.Id
WHERE Date = end_date
-- Saved table as: "weight_end_date"


-- 15c. What are the changes in weight over time?
-- Calculate percent change from start to end weight
SELECT *, ROUND((end_weight - start_weight)/start_weight *100 ,2)  AS percent_change
FROM (
-- Combine start and end date weight data into one table 
SELECT weight.Id, ROUND(BMI,2) AS BMI, Report_Type, start_date, ROUND(start_weight.start_pounds,2) AS start_weight,
 end_date, ROUND(end_weight.end_pounds,2) AS end_weight
FROM Bella_Project.dbo.weight_merged AS weight
JOIN Bella_Project.dbo.start_weight  AS start_weight ON weight.Id = start_weight.Id
JOIN Bella_Project.dbo.end_weight        AS end_weight   ON weight.Id = end_weight.Id
WHERE Date = start_date
) AS a
-- Saved table as: "Weight_percent_change"
/*Analysis:
-Three of the 8 users only checked their weight between 2-5 times however the logs were spaced out with the difference from their start and end date being on average 19 days. 
-There is not significant weight change for any users. 
-Of the weight users the 2 that had the most logs showed the most percent change in weight. Users with 2 logs showed little change between their 2 logs in comparison. 
*/



-- 16. How do number of steps vary by day?
-- Find average steps by day                        
SELECT Day, AVG(Steps) AS avg_steps                     
FROM Bella_Project.dbo.dailyActivity_merged
GROUP BY Day                        
-- Order results by day of week. Case assigns numeric value to Days so that the order is based on value not alphabetical.                        
ORDER BY                        
     CASE                       
          WHEN Day = 'Sunday' THEN 1   
          WHEN Day = 'Monday' THEN 2
          WHEN Day = 'Tuesday' THEN 3
          WHEN Day = 'Wednesday' THEN 4
          WHEN Day = 'Thursday' THEN 5
          WHEN Day = 'Friday' THEN 6
          WHEN Day = 'Saturday' THEN 7
     END ASC 

/* Analysis: 
-Saturday has the highest step count and the least is Sunday
*/


-- 17. How do steps vary by time?
-- Find number of steps per hour
SELECT DISTINCT Time, AVG(Step) AS avg_steps
FROM Bella_Project.dbo.hourlySteps_merged
GROUP BY Time
ORDER BY Time
/* Analysis: 
Users tend to gradually increase their number of steps as the morning progresses (3am to 10am).
Step count wavers up and down in the afternoon. There is a peak in the evening before a rapid decline into the night .
*/


-- 18a. are there differences in the activity performed by users that tracked activity, sleep, and weight compared to those who did not track weight?
--Compile user Ids that overlap across activity, sleep, and weight datasets
SELECT DISTINCT weight_avgs.Id          
FROM Bella_Project.dbo.sleep_totals_by_id          
JOIN Bella_Project.dbo.weight_avgs ON weight_avgs.Id = sleep_totals_by_id.Id           
WHERE sleep_totals_by_id.Id = weight_avgs.Id
-- Saved table as dataset: "overlap_ids"


-- 18b. 
-- Compile average activity data and number of activity logs for the six overlapped user Ids
SELECT DISTINCT sleep_totals_by_id.Id,          
 logs AS activity_logs,         
 sleep_totals_by_id.total_logs AS sleep_logs,           
 weight_avgs.total_logs AS weight_logs,         
 avg_steps, avg_total_distance, avg_very_min,
 avg_fair_min, avg_light_min, avg_sedentary_min,
 avg_calories_burned, avg_min_asleep,
 avg_min_awake_in_bed           
 FROM Bella_Project.dbo.activity_avgs_by_id         
 JOIN Bella_Project.dbo.sleep_totals_by_id   ON sleep_totals_by_id.Id = activity_avgs_by_id.Id            
 JOIN Bella_Project.dbo.weight_avgs ON weight_avgs.Id = sleep_totals_by_id.Id
-- This pulls data for only the six user ids that are found in both the sleep and weight datasets           
 WHERE sleep_totals_by_id.Id = weight_avgs.Id           
 ORDER BY Id 
-- Saved table as dataset: "overlap_ids_avgs_logs"


-- 19a. How do overlap users' activity and sleep data vary by day? (The following 2 queries are used to group the data before joining into one table)
-- Averaging activity types of the six user Ids that overlap across activity, sleep, and weight datasets
SELECT Day,
 AVG(Steps) AS avg_steps,   
 AVG(Distance) AS avg_distance,     
 AVG(Very_Active_Minutes) AS avg_very_min,  
 AVG(Fairly_Active_Minutes) AS avg_fair_min,    
 AVG(Lightly_Active_Minutes) AS avg_light_min,  
 AVG(Sedentary_Minutes) AS avg_sedentary_min,   
 AVG(Calories) AS avg_calories_burned
FROM Bella_Project.dbo.dailyActivity_merged
JOIN Bella_Project.dbo.overlap_ids ON overlap_ids.Id = dailyActivity_merged.Id
-- Designate to pull data from the six user ids in the overlap dataset
WHERE dailyActivity_merged.Id = overlap_ids.Id
GROUP BY Day
ORDER BY      
    CASE            
          WHEN Day = 'Sunday' THEN 1            
          WHEN Day = 'Monday' THEN 2            
          WHEN Day = 'Tuesday' THEN 3           
          WHEN Day = 'Wednesday' THEN 4         
          WHEN Day = 'Thursday' THEN 5          
          WHEN Day = 'Friday' THEN 6            
          WHEN Day = 'Saturday' THEN 7          
     END ASC 
	 -- Saved table as dataset: “overlap_act_avg_day”

-- 19b. 
-- Averaging sleep activity data for six users with data in activity, sleep, and weight
SELECT Day, COUNT(Day) AS number_of_days,
 AVG(Time_Asleep) AS avg_min_asleep,
 AVG(Time_Awake) AS avg_min_awake_in_bed
FROM Bella_Project.dbo.sleepDay_merged 
JOIN Bella_Project.dbo.overlap_ids ON overlap_ids.Id = sleepDay_merged.Id
-- Designate to pull data from the six user ids in the overlap dataset
WHERE sleepDay_merged.Id = overlap_ids.Id
GROUP BY Day
ORDER BY      
    CASE            
          WHEN Day = 'Sunday' THEN 1
          WHEN Day = 'Monday' THEN 2
          WHEN Day = 'Tuesday' THEN 3
          WHEN Day = 'Wednesday' THEN 4
          WHEN Day = 'Thursday' THEN 5
          WHEN Day = 'Friday' THEN 6
          WHEN Day = 'Saturday' THEN 7
     END ASC
     -- Saved table as dataset: “overlap_sleep_avg_day”


-- 19c.
-- Combine datasets into one with both sleep and activity data for six users that overlapped datasets
SELECT act.*, avg_min_asleep, avg_min_awake_in_bed               
FROM Bella_Project.dbo.overlap_act_avg_day    AS act         
JOIN Bella_Project.dbo.overlap_sleep_avg_day  AS sleep  ON act.Day = sleep.Day


-- 20. What percent does each activity make up of an average day for all users?
-- Calculating the percentage each activity type makes up of an average day
  SELECT *, (avg_very_act_min_wk *1.0 / weekly_avg_min_total)*100.0 as very_act_percent,        
 (avg_fairly_act_min_wk *1.0/ weekly_avg_min_total)*100 AS fairly_act_percent,       
 (avg_lightly_act_min_wk *1.0/ weekly_avg_min_total)*100 AS lightly_act_percent,       
 (avg_sedentary_min_wk *1.0/ weekly_avg_min_total)*100 AS sedentary_percent,       
 (avg_min_asleep_wk *1.0/ weekly_avg_min_total)*100 AS asleep_percent,       
 (avg_min_awake_in_bed_wk *1.0/ weekly_avg_min_total)*100 AS awake_in_bed_percent        
FROM (
SELECT *, 
-- Calculating total average minutes of combined activity types
(avg_min_awake_in_bed_wk + avg_min_asleep_wk + avg_very_act_min_wk + avg_fairly_act_min_wk + avg_lightly_act_min_wk + avg_sedentary_min_wk) AS weekly_avg_min_total
FROM (
 SELECT 
 -- Averaging activity minutes from dataset grouped by week days into one daily average
 AVG(avg_min_awake_in_bed) AS avg_min_awake_in_bed_wk,
 AVG(avg_min_asleep) AS avg_min_asleep_wk,
 AVG(avg_hour_asleep) AS avg_hour_asleep_wk,
 SUM(avg_sleep_day.number_of_days) AS sleep_logs,        
 SUM(avg_activity_day.logs) AS activity_logs,
 AVG(avg_very_act_min) AS avg_very_act_min_wk,
 AVG(avg_fairly_act_min) AS avg_fairly_act_min_wk,
 AVG(avg_lightly_act_min) AS avg_lightly_act_min_wk,
 AVG(avg_sedentary_min) AS avg_sedentary_min_wk      
FROM Bella_Project.dbo.avg_sleep_day
JOIN Bella_Project.dbo.avg_activity_day ON avg_sleep_day.Day = avg_activity_day.Day) AS a
) AS b
-- Dataset saved as “daily_avg_percents”. Placed into Excel: changed number format from decimals to percentages
/* Analysis:
-Most time was spent sedentary (59.1%) (16.5 hrs) and the least (.08%) performing fairly active level of activity.
-Activity light, fair, and very combined made up 12.8% (3.79 hours) of daily time.
-Sleep makes up 25 % (6.99 hours)
*/


-- 21. What percent does each activity make up of an average day overlap users?
-- Calculating percentage of each activity type out of the total daily activity minutes
SELECT *, (avg_very_min_wk *1.0/ weekly_total_min)*100 AS very_act_percent,
 (avg_fair_min_wk *1.0/ weekly_total_min)*100 AS fairly_act_percent,
 (avg_light_min_wk *1.0/ weekly_total_min)*100 AS lightly_act_percent,
 (avg_sedentary_min_wk *1.0/ weekly_total_min)*100 AS sedentary_percent,
 (avg_min_asleep_wk *1.0/ weekly_total_min)*100 AS asleep_percent,
 (avg_min_awake_bed_wk *1.0/ weekly_total_min)*100 AS awake_in_bed_percent
FROM (
SELECT *, 
-- Adding all activity minutes to find average daily total
(avg_very_min_wk + avg_fair_min_wk + avg_light_min_wk + avg_sedentary_min_wk + avg_min_asleep_wk + avg_min_awake_bed_wk) AS weekly_total_min
FROM (
SELECT AVG(avg_very_min) AS avg_very_min_wk,
 AVG(avg_fair_min) AS avg_fair_min_wk,
 AVG(avg_light_min) AS avg_light_min_wk,
 AVG(avg_sedentary_min) AS avg_sedentary_min_wk,
 AVG(avg_min_asleep) AS avg_min_asleep_wk,
 AVG(avg_min_awake_in_bed) AS avg_min_awake_bed_wk
 FROM Bella_Project.dbo.overlap_act_avg_day AS act
 -- Combining sleep data with activity level data
JOIN Bella_Project.dbo.overlap_sleep_avg_day AS sleep ON act.day = sleep.Day ) AS c
) AS d
-- Saved table as dataset as: “overlap_weekly_act_percents”

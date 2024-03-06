# Bellabeat
How Can a Wellness Technology Company Play It Smart?


## Introduction:
### Background
Bellabeat, a company specializing in high-tech health-focused smart devices for women, was founded in 2013 and expanded globally by 2016. Their mission revolves around empowering women by providing them with data and insights for self-discovery. Co-founded by Urška Sršen and Sandro Mur, Bellabeat quickly gained recognition. Despite its success, CEO Urška Sršen sees potential for further growth in the global smart device market. She believes analyzing fitness data from smart devices could unlock new opportunities. A case study will focus on one of Bellabeat's products, analyzing smart device data to understand consumer usage patterns and guide marketing strategies.

### Products: 
1. Bellabeat App: Provides users with health-related data such as activity, stress, sleep, menstrual cycle, and mindfulness habits. Helps users understand their habits and make healthy decisions. Connects to Bellabeat's smart wellness products.

2. Leaf: A classic wellness tracker worn as a bracelet, necklace, or clip. Connects to the Bellabeat App to track activity, sleep, and stress.

3. Time: A wellness watch that combines a classic timepiece with smart technology to track activity, sleep, and stress. Connects to the Bellabeat App for daily wellness insights.

4. Spring: A smart water bottle that tracks daily water intake using smart technology, ensuring users stay hydrated throughout the day. Connects to the Bellabeat App to track hydration levels.

5. Bellabeat Membership: A subscription-based program offering personalized guidance on sleep, nutrition, health, beauty, and mindfulness-based on users' goals and lifestyles.

### Business Task: 
in this case study, I will answer the following questions:

What are some trends in smart device usage?
How can these trends help influence Bellabeat's marketing strategy?

### Data Sources
The ['FitBit Fitness Tracker Data'](https://www.kaggle.com/datasets/arashnic/fitbit) on Kaggle originated from a survey conducted on Amazon Mechanical Turk workers, collecting data from 30 participants. However, data for 33 users is available. The dataset spans April 12, 2016, to May 12, 2016, covering physical activity, sleep, weight, and step count for 33 users across 4 datasets. 

### Data Limitations:

- The study involved only 33 participants who tracked information over two months, imposing significant constraints on determining trends for each tracked area of usage. To 
  mitigate these constraints, a larger dataset is necessary.
- The inclusion of demographic information such as sex, health/fitness goals, and height would be advantageous.
- Understanding the participants' sex would aid in aligning the dataset with Bellabeat's target demographic.
- Knowledge of participants' health and fitness goals would allow exploration of goal attainment or progress.
- Height data would offer deeper insights into analyzing steps and distance totals, as individuals with varying heights possess different stride lengths, potentially 
  influencing data interpretation.


### Methods Used: SQL, Excel, Tableau

### Data Processing, Cleaning, and Analysis 
All data processing, cleaning, and analysis were done using SQL and are available in the Bellabeat.sql script provided in this repository. Detailed comments are included throughout, documenting the thought processes and findings.

### Summary Of Analysis:
#### Activity Findings:
 1. Activity is primarily at the light level, but users still meet the recommended weekly minimum of 150 minutes. A trend emerges as activity decreases toward the end of the week across all activity levels.
 2. A positive correlation exists between higher activity levels and increased calorie burn.

#### Steps Findings:
1. Users are achieving nearly 7,000 steps on average. However, there's a noticeable decline in the number of users tracking their steps, with non-trackers recording 
significantly fewer steps.
2. Users tend to take more steps on Tuesdays and Saturdays, with a steady level in the middle of the week.
3. On average, the highest number of steps happens in the evening, then drops quickly afterward.
4. There's a positive correlation between taking more steps and burning more calories.

#### Sleep Findings: 
1. Longer sleep durations correlate with increased periods of wakefulness throughout sleep cycles.
2. Users generally receive similar amounts of sleep throughout the week, albeit varying from recommended levels to below. Sundays typically yield the most sleep, with a decline at the week's start and end.
3. Users experience more wakefulness in bed on weekends compared to weekdays.
4. Sleep duration varies over time but averages around 7 hours per night.
5. Not all users consistently track sleep data nightly, indicating inconsistent sleep-tracking habits.






### Tableau Dashboard/Visualization
   [Step](https://public.tableau.com/shared/Q99CTHTBB?:display_count=n&:origin=viz_share_link)  
   [Sleep](https://public.tableau.com/shared/N5YHNPS3X?:display_count=n&:origin=viz_share_link)  
   [Activity](https://public.tableau.com/shared/TBKWJCRSY?:display_count=n&:origin=viz_share_link)  
   [Calorie](https://public.tableau.com/shared/WS35K443Z?:display_count=n&:origin=viz_share_link)

### Recommendations: 






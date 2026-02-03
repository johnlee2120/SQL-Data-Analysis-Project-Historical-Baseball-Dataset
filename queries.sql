-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
SELECT 	* 
FROM 	schools;
SELECT 	*
FROM 	school_details;

SELECT 	 *
FROM 	 schools s
		 LEFT JOIN  school_details sd
		 ON 		s.schoolID = sd.schoolID
ORDER BY yearID;




-- 2. In each decade, how many schools were there that produced players?


SELECT 		FLOOR(s.yearID / 10) * 10 AS decade, 
			COUNT(DISTINCT sd.name_full) AS num_schools
FROM 		schools s
			LEFT JOIN 	school_details sd
			ON 			s.schoolID = sd.schoolID
GROUP BY 	decade
ORDER BY 	decade;

/* 	
Using FLOOR (which always rounds down) because ROUND will round some years to the wrong decade. 
	i.e. 1865 -> 1870 becoming the wrong decade. 
COUNT(DISTINCT) because a school hosted a player for multiple years a lot of times
	i.e. bellast01 is at fordham from 1864 till 1866 causing the fordham to show up 3 times 
GROUP BY decade shows the table to show up collapsed per decade 
After being collapsed, COUNT(DISTINCT name_full) causes the DISTINCT COUNT to be shown per decade
    
Note: FLOOR is not an aggregate */




-- 3. What are the names of the top 5 schools that produced the most players?

SELECT 		sd.name_full, 
			COUNT(DISTINCT s.playerID) AS num_players
FROM 		schools s
			LEFT JOIN 	school_details sd
			ON 			s.schoolID = sd.schoolID
GROUP BY 	sd.name_full
ORDER BY 	num_players DESC
LIMIT		5;

/*  
NOT COUNT(DISTINCT sd.name_full) 
	first of all the group by sd.name_full also takes care of the DISTINCT school name part
	second of all we need DISTINCT player ID because the school will show up multiple times because a player stays at a 
    school for multiple years a time
we are collapsing the table by school name 
	after being collapsed, COUNT(DISTINCT sd.name_full) causes the count of each unique player name to be shown per school 
    name
*/




-- 4. For each decade, what were the names of the top 3 schools that produced the most players?

WITH cte1 AS 	(SELECT 	FLOOR(s.yearID / 10) * 10 AS decade, 
							sd.name_full,
							COUNT(DISTINCT s.playerid) AS num_players
				FROM 		schools s
							LEFT JOIN 	school_details sd
							ON 			s.schoolID = sd.schoolID
				WHERE 		sd.name_full IS NOT NULL
				GROUP BY 	decade, sd.name_full
				ORDER BY 	decade),
                
	cte2 AS 	(SELECT decade, name_full, num_players,
							ROW_NUMBER() OVER(PARTITION BY decade ORDER BY num_players DESC) AS row_num
				FROM cte1)
                
SELECT 		decade, name_full, num_players
FROM 		cte2
WHERE 		row_num <= 3
ORDER BY 	decade DESC, 
			num_players DESC;

/* 	
cte1 is grouped by decade and then school name. the number of players of resulting grouping is shown
	this is effectively the number of players per school per decade
we needed to make cte1 to refer to decade and num_players in the ROW_NUMBER() function in a new query
now we rank the number of players per school per decade descending from highest to lowest with ROW_NUMBER()
we now need to make a new cte (cte2) because we need to refer to row_num in a new query
we make a WHERE condition to limit the number of results to 3 per decade
we order by decade and num_players to show the most recent decade first and then show the num_players from highest
	to lowest (the order is reset after a new cte is made)
*/






-- PART II: SALARY ANALYSIS
-- 1. View the salaries table

SELECT 	*
FROM 	salaries;




-- 2. Return the top 20% of teams in terms of average annual spending

WITH cte1 AS 	(SELECT 	yearID, teamID, 
							SUM(salary) AS annual_spending
				FROM 		salaries
				GROUP BY 	yearID, teamID
				ORDER BY 	yearID, teamID),

	cte2 AS 	(SELECT 	teamID, 
							AVG(annual_spending) AS avg_annual_spending,
							NTILE(5) OVER(ORDER BY AVG(annual_spending) DESC) AS percentile
				FROM 		cte1
				GROUP BY 	teamID
				ORDER BY 	avg_annual_spending DESC)

SELECT 	teamID, 
		ROUND(avg_annual_spending / 1000000, 1) AS avg_spend_millions
FROM 	cte2
WHERE 	percentile = 1;

/*  
we collapse the table by yearID and then teamID and then put in the term SUM(salary) 
	this will effectively return the total sum of spending per team per year
now we make it into a cte (cte1) to refer to annual_spending
we collapse into teamID only now and then average the annual spending per team.
	now the yearID doesn't matter because we have averaged all years of spending per team
we don't make a new cte yet because we can insert AVG(annual_spending) directly into the NTILE function without
	using it's alias
the NTILE function splits the avg_annual_spending into 5 sections which will be 20 percentile each section
	we cannot do 100 sections because there aren't 100 entries in avg_annual_spending
we make a new cte (cte2) because we have to refer to percentile
we now do percentile = 1 which will only show the top 20% as we sorted by avg_annual_spending descending
we do ROUND(/ 1000000, 1) because it is hard to see the total because there are no commas in the table
	this is millions so 143 is 143 million. we reveal 1 more decimal point for a little more information
*/




-- 3. For each team, show the cumulative sum of spending over the years

WITH cte1 AS 	(SELECT 	teamID, yearID,
							SUM(salary) AS annual_spending
				FROM 		salaries
				GROUP BY 	teamID, yearID
				ORDER BY 	teamID, yearID)

SELECT  teamID, yearID,
		ROUND(SUM(annual_spending) OVER(PARTITION BY teamID ORDER BY yearID) / 1000000, 1) AS cumulative_sum_millions
FROM 	cte1;



/*  
this time we group by teamID first and then yearID. we want to group by teamID first because we want to see how much
	each team spent in a running sum. the SUM(salary) shows us the total spending per team per year.
we make this into a cte (cte1) because we need to refer to annual_spending
we do a window function SUM() and partition by teamID (this doesn't actually collapse the function but keeps the rows)
	this makes the running sum
we divide by 1000000 for readability to make it into millions. we keep 1 decimal point for more information
*/




-- 4. Return the first year that each team's cumulative spending surpassed 1 billion

WITH cte1 AS 	(SELECT 	teamID, yearID,
							SUM(salary) AS annual_spending
				FROM 		salaries
				GROUP BY 	teamID, yearID
				ORDER BY 	teamID, yearID),

	 cte2 AS 	(SELECT  	teamID, yearID,
							SUM(annual_spending) OVER(PARTITION BY teamID ORDER BY yearID) AS cumulative_sum
				FROM 		cte1),

	 cte3 AS 	(SELECT *,
				ROW_NUMBER() OVER(PARTITION BY teamID ORDER BY cumulative_sum) as row_num
				FROM cte2
				WHERE cumulative_sum > 1000000000)

SELECT 	teamID, yearID, 
		ROUND(cumulative_sum / 1000000000, 2) AS cumulative_sum_billions
FROM 	cte3
WHERE 	row_num = 1;

/* 	
used the previous section's code because it shows cumulative spending over the years. got rid of the round() for the rest 
	of the problem
made cte2 because we need to refer to cumulative_sum
made a window function ROW_NUMBER() and partitioned by teamID and then order by yearID because we need that first year
we filter by cumulative_sum > 1 billion because we only care about that first year the cumulative sum hits a billion
we make cte3 because we need to refer to row_num
we filter by row_num = 1 which is the rank 1 spot of each window. this rank 1 spot will be when the billion was first
	hit in cumulative sum
we round() dividing by a billion for readability. we use 2 decimal points for more information
*/





-- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table

SELECT	*
FROM 	players;

SELECT 	COUNT(playerID)
FROM 	players;

SELECT 	COUNT(DISTINCT playerID)
FROM 	players;

/* 
COUNT(DISTINCT playerID) just to show that there are no duplicate players 
*/




-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). 
-- Sort from longest career to shortest career.

SELECT 		nameGiven,
			CAST(CONCAT(birthYear, "-", birthMonth, "-", birthDay) AS DATE) AS birthdate,
			TIMESTAMPDIFF(YEAR, CAST(CONCAT(birthYear, "-", birthMonth, "-", birthDay) AS DATE), debut) 
				AS age_at_debut,
			TIMESTAMPDIFF(YEAR, CAST(CONCAT(birthYear, "-", birthMonth, "-", birthDay) AS DATE), finalGame) 
				AS age_ate_last_game,
			TIMESTAMPDIFF(YEAR, debut, finalGame) 
				AS career_length
FROM 		players
ORDER BY 	career_length DESC;


/*  
have to CONCAT into a single full birthday before subtracting because birthday might have happened before debut date
must CAST into a date because the 0's in for example 1934-2-5 doesn't automatically appear and also mysql might not
	recognize this as a real date
do not have to create a new CTE because CAST and CONCAT are not aggregates or window functions!!  
	(must do for aggregates or window functions)
DATEDIFF give difference in days and we want years. so we use TIMESTAMPDIFF
*/



-- 3. What team did each player play on for their starting and ending years?

SELECT 	*
FROM 	players;
SELECT 	*
FROM 	salaries;

SELECT 	p.nameGiven, s.yearID AS starting_year, p.debut, s.teamID AS starting_team, 
		s2.yearID AS ending_year, p.finalGame, s2.teamID AS ending_team
FROM 	players p
		INNER JOIN salaries s
			ON p.playerID = s.playerID 
			AND s.yearID = YEAR(p.debut)
		INNER JOIN salaries s2
			ON p.playerID = s2.playerID 
			AND s2.yearID = YEAR(p.finalGame);



/*  
JOIN on playerID AND yearID = debut to get the team they were on on the exact year they debuted
there are a lot of nulls because we don't have information on some of these players on their debut date
	thus instead of a left join we do an inner join to only get back the rows where we do have that information on their 
	team on their debut year
we can make TWO JOIN commands in one query
	this is because we have p.playerID = s.playerID in both joins which will connect them to each other when displaying 
	results. these two joins are run independently of each other and come together in the end on the aforementioned 
	same variable when displayed in the table. we choose what we want to see from each table by specifying the variables s 
    and s2 and choosing what we want in the select statemtn
*/



-- 4. How many players started and ended on the same team and also played for over a decade?

SELECT 	p.nameGiven, s.yearID AS starting_year, p.debut, s.teamID AS starting_team, 
		s2.yearID AS ending_year, p.finalGame, s2.teamID AS ending_team
FROM 	players p
		INNER JOIN salaries s
			ON p.playerID = s.playerID 
			AND s.yearID = YEAR(p.debut)
		INNER JOIN salaries s2
			ON p.playerID = s2.playerID 
			AND s2.yearID = YEAR(p.finalGame)
		WHERE s.teamID = s2.teamID AND s2.yearId - s.yearID > 10;

/*  
copy paste previous query because the previous query has the players linked with their starting and ending team
	as well as the players linked with their starting year and ending year
don't need to get a COUNT() because it's a very short list
*/





-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table

SELECT 	*
FROM 	players;



-- 2. Which players have the same birthday?


WITH cte1 AS 	(SELECT 
					CAST(CONCAT(birthYear, "-", birthMonth, "-", birthDay)AS DATE) AS birthdate,
				nameGiven
				FROM players)

SELECT 		birthdate, 
			GROUP_CONCAT(nameGiven SEPARATOR ", ") AS people_with_same_birthdays
FROM 		cte1
WHERE 		birthdate IS NOT NULL 
GROUP BY 	birthdate
HAVING 		COUNT(nameGiven) >= 2
ORDER BY 	birthdate;

/*  
new cte (cte1) to refer to birthdate
grouping by birthdate to collapse all the rows by birthdate
there were some null values so make birthdate IS NOT NULL
now do a GROUP_CONCAT which will give us a list of nameGiven for each birthdate collapsed row
do COUNT(nameGiven) >= 2 because it is showing us rows where there is only one person for a birthdate
*/



-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both

SELECT 		s.teamID,
				ROUND(
					SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 2) AS bats_right,
				ROUND(
					SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 2) AS bats_left,
				ROUND(
					SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 2) AS bats_both
FROM 		salaries s
			LEFT JOIN players p
				ON 	p.playerID = s.playerID
GROUP BY 	s.teamID;

/*  
made pivot table. do the SUM for each CASE WHEN to get totals of each column
don't need to make a cte as we can do COUNT(s.playerID) for the denominator
teamID is in the salaries table. 
	some players in the players table do not have a playerID match in the salaries table so their teamID ends up showing NULL
	in a LEFT JOIN, so we need to make salaries the main table so that every player row in the result comes from salaries and 
	thus will have a teamID because teamID is in the salaries table (unless salaries.teamID itself is missing for a row)
*/



-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?

SELECT 	*
FROM 	players;

WITH cte1 AS	(SELECT 	(FLOOR(YEAR(debut) / 10)) * 10 AS decade, 
							AVG(height) AS avg_height, AVG(weight) AS avg_weight
				FROM 		players
				GROUP BY 	decade
				ORDER BY 	decade)

SELECT 	decade, avg_height, avg_weight,
		avg_height - LAG(avg_height) OVER(ORDER BY decade) AS diff_in_HEIGHT,
		avg_weight - LAG(avg_weight) OVER(ORDER BY decade) AS diff_in_WEIGHT
FROM 	cte1
WHERE 	decade IS NOT NULL;


/*  
collapsed the table by decade which was made using FLOOR()
now we can't just leave height and weight as is in SELECT. it will give a syntax error because they aren't in group by.
	we don't want to group by them anyways. we want their avg so we put them in AVG()
don't have to make cte but we make it for readability
we put WHERE decade IS NOT NULL because the lag function creates a 1st row of nulls
*/




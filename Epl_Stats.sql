-- Data Exploration
-- Chcek to ensure all the 20 teams are represented
SELECT COUNT(DISTINCT Team )FROM epl;

-- This shows all the 20 Teams in the  EPL 2023/2024 season
SELECT DISTINCT Team FROM epl;

-- This query gets all the columns in the table for all teams.
SELECT * FROM epl;

-- The average possesion each team has had in their matches.
SELECT avg(Poss) as AvgPoss, Team FROM epl
 group by Team;
-- The average shots each team  had in their matches.
 SELECT  Team, ROUND(AVG(Sh),0) as AVGShot
 FROM epl
 GROUP BY Team;
 
-- The average expected goal against  each team has had in their matches.
 select  avg(xGA) as AvgxGA, Team 
 from epl
 group by Team;
 
 SELECT * FROM epl
 WHERE Team = 'Arsenal';
 
 -- Team Performance, this query gets the number of matces won, lost and drawn by all the teams.
 SELECT Team, 
 COUNT( CASE WHEN Result = 'W' THEN 1 END) as Wins,
 COUNT( CASE WHEN Result = 'L' THEN 1 END) as Losses,
 COUNT( CASE WHEN Result = 'D' THEN 1 END) as Draws,
 SUM(CASE WHEN Result = 'W' THEN 3 ELSE 0 END) + SUM(CASE WHEN Result = 'D' THEN 1 ELSE 0 END) as Points
 FROM epl
 GROUP BY Team
 ORDER BY Points DESC;
 
 -- Goal statistics, this calculates the average goals scored and conceded by each team.

 SELECT Team, AVG(GF) as AvgGoalScored,AVG(GA) as AvgGoalConceded
 FROM epl
 GROUP BY Team
 ORDER BY AvgGoalConceded DESC;
 
 -- HEAD TO HEAD, this analyzes matches between speficic teams.
 SELECT * FROM epl
 WHERE Team = 'Arsenal' and Opponent = 'Chelsea';
 
 -- Referee Statistics
SELECT  Distinct Referee, COUNT( DISTINCT Round) as Match_officiated
from epl
group by Referee
ORDER BY Match_officiated Desc;

-- Specific Team Analysis

-- The avg Shot Man Utd faced against the top 5
WITH MAIN_CTE AS (
SELECT * 
FROM epl
WHERE Opponent = 'Manchester Utd' AND Team IN ('ManchesterCity', 'Arsenal', 'Liverpool','Tottenham', 'Aston Villa'))
SELECT AVG(Sh)
FROM MAIN_CTE
;

-- The avg Shot Man Utd faced against bottom 5
WITH MAIN_CTE AS (
SELECT * 
FROM epl
WHERE Opponent = 'Manchester Utd' AND Team IN ('Brentford', 'Burnley', 'Luton Town','Sheffield Utd', "Nott'ham Forest
"))
SELECT AVG(Sh)
FROM MAIN_CTE
;

-- Show match where Man Utd had more than 50% percent of the possession
SELECT *
 FROM epl
WHERE Team = 'ManchesterUnited' AND Poss > 50;

-- expected goal scored and expected goal conceded Versus Goal scored and Goal conceded
SELECT DISTINCT Team,
 SUM(ROUND(xG)) OVER (PARTITION BY Team)AS TotalxG , SUM(GF)OVER (PARTITION BY Team) AS TotalGF, SUM(ROUND(xGA)) OVER (PARTITION BY Team)AS TotalxGA, SUM(GA) OVER (PARTITION BY Team) AS TotalGA
FROM epl;

-- Shots Taken versus Shot on target
SELECT DISTINCT Team,
 SUM(Sh) OVER (PARTITION BY Team)AS TotalShots, SUM(SoT)OVER (PARTITION BY Team) AS TotalShotOnTarget
FROM epl;

-- Calculating the total cleansheet for all the teams.
WITH TEAM_CTE AS (
SELECT Team, GA, Gf, Opponent,
CASE WHEN GA = 0 THEN 'Yes'
 WHEN GA > 0 THEN 'No'
ELSE 'Other'
END AS Cleansheet
FROM epl)

SELECT  DISTINCT Team,
COUNT(GA) OVER (PARTITION BY Team)AS TotalCleansheet
FROM TEAM_CTE
WHERE GA = 0
ORDER BY TotalCleansheet DESC;

-- Venue statistics
WITH VENUE_CTE AS (
SELECT  DISTINCT Team, Venue, Result,
CASE WHEN  Venue = 'Home' and Result = 'W' THEN 'Yes'
WHEN Venue = 'Home' and Result <> 'W' THEN 'No'
ELSE 'Away'
END AS Home_advantage
FROM epl)
SELECT Team, Venue, Result, Home_advantage
FROM VENUE_CTE
WHERE Venue = 'Home' AND Result = 'W';


-- Home advantage
WITH HOME_CTE AS(
SELECT Team, Venue, Result
FROM epl
WHERE Venue = 'Home' AND Result = 'W')
SELECT Team, COUNT(RESULT) AS Home_Wins
FROM HOME_CTE
GROUP BY Team;

-- Away stat
WITH AWAY_CTE AS(
SELECT Team, Venue, Result
FROM epl
WHERE Venue = 'Away' AND Result = 'W')
SELECT Team, COUNT(RESULT) AS Away_Wins
FROM AWAY_CTE
GROUP BY Team;

-- Matchweek stat, the Matchweek with the most goals.
SELECT Round, SUM(GF) 
FROM epl
GROUP BY Round
ORDER BY Round Desc;

-- Penalty Stats
WITH PK_CTE AS (
SELECT Round, PK,
CASE WHEN PK = 0 THEN 'No'
WHEN PK > 0 THEN 'Yes'
ELSE 'Other'
END AS Penalty
FROM epl
WHERE PK <> 0)

SELECT Round, COUNT(PK) AS TotalPK
FROM PK_CTE
GROUP BY Round
ORDER BY TotalPK DESC;

-- Total Penalty given in the 2023/2024 season
WITH PK_CTE AS (
SELECT Round, PK,
CASE WHEN PK = 0 THEN 'No'
WHEN PK > 0 THEN 'Yes'
ELSE 'Other'
END AS Penalty
FROM epl
WHERE PK <> 0)
SELECT COUNT(PK) AS TotalPK
FROM PK_CTE
ORDER BY TotalPK DESC;

-- team with the highest Penalty
WITH PK_CTE AS (
SELECT Team, PK,
CASE WHEN PK = 0 THEN 'No'
WHEN PK > 0 THEN 'Yes'
ELSE 'Other'
END AS Penalty
FROM epl
WHERE PK <> 0)
SELECT Team, COUNT(PK) AS TotalPK
FROM PK_CTE
GROUP BY Team
ORDER BY TotalPK DESC;

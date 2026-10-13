-- ===================================================================
-- PROJECT: Digital Behavioral Attrition & Cognitive Fatigue
-- ENVIRONMENT: MySQL / MySQL Workbench
-- ===================================================================

-- 1. Create the Database
CREATE DATABASE IF NOT EXISTS BehavioralAnalytics;

-- 2. Select the Database to work inside it
USE BehavioralAnalytics;

-- 3. Increase recursive depth to allow generating 5,000 rows
SET SESSION cte_max_recursion_depth = 10000;

-- 4. Schema Setup & Clean Table Recreation
DROP TABLE IF EXISTS UserTelemetry;

CREATE TABLE UserTelemetry (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    SessionDate DATE NOT NULL,
    DwellTimeSeconds INT NOT NULL,
    RewardBadges INT NOT NULL
);

-- STEP 2: Deterministic Data Generation (5,000 Rows)
INSERT INTO UserTelemetry (UserID, SessionDate, DwellTimeSeconds, RewardBadges)
WITH RECURSIVE IDs AS (
    SELECT 1 AS ID
    UNION ALL
    SELECT ID + 1 FROM IDs WHERE ID < 5000
)
SELECT 
    (ID % 500) + 1 AS UserID,
    DATE_ADD(CAST('2026-08-01' AS DATE), INTERVAL (ID % 45) DAY) AS SessionDate,
    FLOOR(RAND() * 3600) + 60 AS DwellTimeSeconds,
    CASE WHEN RAND() * 100 > 80 THEN 1 ELSE 0 END AS RewardBadges
FROM IDs;

-- STEP 3: The Foundation - N-Day Cohort Retention
WITH FirstLogin AS (
    SELECT UserID, MIN(SessionDate) AS CohortDate
    FROM UserTelemetry
    GROUP BY UserID
),
UserActivity AS (
    SELECT 
        t.UserID, 
        f.CohortDate, 
        t.SessionDate,
        -- Note: MySQL DATEDIFF takes (EndDate, StartDate), opposite of SQL Server
        DATEDIFF(t.SessionDate, f.CohortDate) AS DaysSinceFirstLogin
    FROM UserTelemetry t
    INNER JOIN FirstLogin f ON t.UserID = f.UserID
)
SELECT 
    CohortDate,
    COUNT(DISTINCT CASE WHEN DaysSinceFirstLogin = 0 THEN UserID END) AS Day0_Users,
    COUNT(DISTINCT CASE WHEN DaysSinceFirstLogin = 1 THEN UserID END) AS Day1_Retained,
    COUNT(DISTINCT CASE WHEN DaysSinceFirstLogin = 7 THEN UserID END) AS Day7_Retained,
    COUNT(DISTINCT CASE WHEN DaysSinceFirstLogin = 30 THEN UserID END) AS Day30_Retained
FROM UserActivity
GROUP BY CohortDate
ORDER BY CohortDate;

-- STEP 4: The Complex Deep Dive - Identifying "Cognitive Fatigue"
WITH DailyAggregates AS (
    SELECT 
        UserID, 
        SessionDate, 
        SUM(DwellTimeSeconds) AS DailyDwellTime
    FROM UserTelemetry
    GROUP BY UserID, SessionDate
),
RollingMetrics AS (
    SELECT 
        UserID,
        SessionDate,
        DailyDwellTime,
        AVG(CAST(DailyDwellTime AS DECIMAL(10,2))) OVER (
            PARTITION BY UserID 
            ORDER BY SessionDate 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) AS Avg7DayBaseline,
        COUNT(*) OVER (
            PARTITION BY UserID 
            ORDER BY SessionDate 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) AS PriorHistoryDays
    FROM DailyAggregates
)
SELECT 
    UserID,
    SessionDate AS BurnoutDate,
    DailyDwellTime AS SpikeDwellTime,
    ROUND(Avg7DayBaseline, 2) AS BaselineAvgDwell,
    ROUND(CAST(DailyDwellTime AS DECIMAL(10,2)) / NULLIF(Avg7DayBaseline, 0), 2) AS FatigueSpikeRatio
FROM RollingMetrics
WHERE PriorHistoryDays >= 3 
  AND Avg7DayBaseline > 0 
  AND (CAST(DailyDwellTime AS DECIMAL(10,2)) / Avg7DayBaseline) > 2.5
ORDER BY FatigueSpikeRatio DESC;

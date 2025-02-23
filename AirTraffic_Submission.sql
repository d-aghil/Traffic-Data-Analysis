-- QUESTION ONE: 
USE AirTraffic;

-- 1.1. Get the number of flights for 2018 and 2019
SELECT 
    YEAR(FlightDate) AS Year, 
    COUNT(*) AS TotalFlights
FROM AirTraffic.flights  
GROUP BY Year;

-- 1.2. Count cancelled or delayed flights by year
SELECT 
    YEAR(FlightDate) AS Year,
    SUM(CASE WHEN Cancelled = 1 OR DepDelay > 0 THEN 1 ELSE 0 END) AS CancelledOrDelayedFlights
FROM AirTraffic.flights  
GROUP BY Year;

-- 1.3. Count cancelled flights by reason
SELECT 
    CancellationReason,
    COUNT(*) AS NumberOfCancellations
FROM AirTraffic.flights  
WHERE Cancelled = 1
GROUP BY CancellationReason;

-- 1.4. Monthly report of cancelled flights for 2019
SELECT 
    MONTH(FlightDate) AS Month,
    COUNT(*) AS CancelledFlights
FROM AirTraffic.flights  
WHERE Cancelled = 1 AND YEAR(FlightDate) = 2019
GROUP BY Month;

-- QUESTION TWO: 
USE AirTraffic;

-- 2.1. Create tables for 2018 and 2019 data (drop existing ones first)
DROP TABLE IF EXISTS flights_2018;  
CREATE TABLE flights_2018 AS
SELECT * FROM flights
WHERE YEAR(FlightDate) = 2018;

DROP TABLE IF EXISTS flights_2019;  
CREATE TABLE flights_2019 AS
SELECT * FROM flights
WHERE YEAR(FlightDate) = 2019;

-- 2.2. Compare total flights and miles traveled by year
SELECT 
    YEAR(FlightDate) AS Year,
    COUNT(*) AS TotalFlights,
    SUM(Distance) AS TotalMilesTraveled
FROM flights
GROUP BY Year;

-- QUESTION THREE:
-- 3.1. Get the top 10 most popular destination airports
SELECT 
    a.AirportName,
    COUNT(*) AS NumberOfFlights  
FROM flights f
JOIN airports a ON f.DestAirportID = a.AirportID
GROUP BY a.AirportName
ORDER BY NumberOfFlights DESC
LIMIT 10;

-- 3.2. Use a subquery for the top 10 airports
SELECT AirportName, NumberOfFlights FROM (
    SELECT 
        a.AirportName,
        COUNT(*) AS NumberOfFlights  
    FROM flights f
    JOIN airports a ON f.DestAirportID = a.AirportID
    GROUP BY a.AirportName
) AS subquery
ORDER BY NumberOfFlights DESC
LIMIT 10;

-- QUESTION FOUR:
-- 4.1. Find unique planes operated by each airline
SELECT 
    AirlineName,  
    COUNT(DISTINCT TailNumber) AS UniquePlanes  
FROM flights
GROUP BY AirlineName;  

-- 4.2. Calculate average miles traveled per plane by airline
SELECT 
    AirlineName,  
    SUM(Distance) / COUNT(DISTINCT TailNumber) AS AvgMilesPerPlane  
FROM flights
GROUP BY AirlineName;  

-- QUESTION FIVE:
-- 5.1. Calculate average departure delay by time of day
SELECT 
    CASE
        WHEN HOUR(CRSDepTime) BETWEEN 7 AND 12 THEN 'Morning'
        WHEN HOUR(CRSDepTime) BETWEEN 13 AND 18 THEN 'Afternoon'
        WHEN HOUR(CRSDepTime) BETWEEN 19 AND 21 THEN 'Evening'
        ELSE 'Late night'
    END AS TimeOfDay,
    AVG(DepDelay) AS AvgDepDelay
FROM flights
GROUP BY TimeOfDay;

-- 5.2. Get average departure delay by airport and time of day
SELECT 
    a.AirportName,
    CASE
        WHEN HOUR(CRSDepTime) BETWEEN 7 AND 12 THEN 'Morning'
        WHEN HOUR(CRSDepTime) BETWEEN 13 AND 18 THEN 'Afternoon'
        WHEN HOUR(CRSDepTime) BETWEEN 19 AND 21 THEN 'Evening'
        ELSE 'Late night'
    END AS TimeOfDay,
    AVG(DepDelay) AS AvgDepDelay
FROM flights f
JOIN airports a ON f.OriginAirportID = a.AirportID
GROUP BY a.AirportName, TimeOfDay;

-- 5.3. List top airports with at least 10,000 flights for morning delays
SELECT 
    a.AirportName,
    AVG(DepDelay) AS AvgMorningDelay
FROM flights f
JOIN airports a ON f.OriginAirportID = a.AirportID
WHERE HOUR(CRSDepTime) BETWEEN 7 AND 12
GROUP BY a.AirportName
HAVING COUNT(*) >= 10000
ORDER BY AvgMorningDelay DESC
LIMIT 10;

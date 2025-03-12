-- Get total flights per year
SELECT YEAR(FlightDate) AS Year, COUNT(*) AS TotalFlights
FROM AirTraffic.flights  
GROUP BY Year;

-- Count delayed or canceled flights
SELECT YEAR(FlightDate) AS Year,
    SUM(CASE WHEN Cancelled = 1 OR DepDelay > 0 THEN 1 ELSE 0 END) AS CancelledOrDelayedFlights
FROM AirTraffic.flights  
GROUP BY Year;

-- Count canceled flights by reason
SELECT CancellationReason, COUNT(*) AS NumberOfCancellations
FROM AirTraffic.flights  
WHERE Cancelled = 1
GROUP BY CancellationReason;

-- Monthly canceled flights in 2019
SELECT MONTH(FlightDate) AS Month, COUNT(*) AS CancelledFlights
FROM AirTraffic.flights  
WHERE Cancelled = 1 AND YEAR(FlightDate) = 2019
GROUP BY Month;

-- Remove old tables
DROP TABLE IF EXISTS flights_2018;  
DROP TABLE IF EXISTS flights_2019;  

-- Create new tables
CREATE TABLE flights_2018 (
    FlightDate DATE,
    Cancelled BOOLEAN,
    DepDelay INT,
    CancellationReason VARCHAR(255)
);

CREATE TABLE flights_2019 (
    FlightDate DATE,
    Cancelled BOOLEAN,
    DepDelay INT,
    CancellationReason VARCHAR(255)
);

-- Improve query speed
CREATE INDEX idx_flight_date ON AirTraffic.flights (FlightDate);
CREATE INDEX idx_cancelled ON AirTraffic.flights (Cancelled);
CREATE INDEX idx_dep_delay ON AirTraffic.flights (DepDelay);

-- Partition data by year
ALTER TABLE AirTraffic.flights PARTITION BY RANGE (YEAR(FlightDate)) (
    PARTITION p2018 VALUES LESS THAN (2019),
    PARTITION p2019 VALUES LESS THAN (2020)
);

-- Load data from S3
LOAD DATA INFILE 's3://your-bucket/airtraffic_2018.csv'
INTO TABLE AirTraffic.flights
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
IGNORE 1 ROWS (FlightDate, Cancelled, DepDelay, CancellationReason);

LOAD DATA INFILE 's3://your-bucket/airtraffic_2019.csv'
INTO TABLE AirTraffic.flights
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
IGNORE 1 ROWS (FlightDate, Cancelled, DepDelay, CancellationReason);

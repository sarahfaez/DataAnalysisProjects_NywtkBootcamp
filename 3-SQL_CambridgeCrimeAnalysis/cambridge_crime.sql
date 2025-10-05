use CambridgeCrimeData;
--------------------------------------------- Data Exploration --------------------------------------------------

-- Count the total number of crime records 
SELECT COUNT(*) AS total_records
FROM CambridgeCrimeData;

-- List of column name and data type
SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CambridgeCrimeData';

-- Display the first 5 rows
SELECT TOP 5 *
FROM CambridgeCrimeData;

--List of unique crime types
SELECT DISTINCT crime
FROM CambridgeCrimeData
ORDER BY crime ASC;

--List of unique neighborhood 
SELECT DISTINCT neighborhood
FROM CambridgeCrimeData
ORDER BY neighborhood ASC;

-- Count the number of crimes in each neighborhood
SELECT neighborhood, COUNT(*) AS total_crimes
FROM CambridgeCrimeData
GROUP BY neighborhood
ORDER BY total_crimes DESC;

-- Retrieve the top 5 most common crime types
SELECT TOP 5 crime, COUNT(*) AS crime_count
FROM CambridgeCrimeData
GROUP BY crime
ORDER BY crime_count DESC

--------------------------------------------- Data Analysis --------------------------------------------------
-- What is the initial crime pattern in the Cambridge Port neighborhood?
SELECT crime,               
    COUNT(*) AS Total_Crimes,   
    MAX(Date_of_Report) AS Last_Date 
FROM CambridgeCrimeData
WHERE Neighborhood = 'Cambridgeport'
GROUP BY crime
ORDER BY Last_Date DESC, Total_Crimes DESC;


--Link the crime to the location (INNER JOIN)

SELECT crime.file_number ,crime.crime ,crime.Crime_Date_Time,Location.Location , Location.Neighborhood
FROM crime
INNER JOIN Location
ON crime.file_number=Location.file_number
ORDER BY Location.Neighborhood,crime.Crime_Date_Time

--Detect incomplete reports (LEFT/RIGHT JOIN) PostgreSQL and Database name Crime
SELECT crimes.crime, Locations.Neighborhood  
FROM crime  
LEFT JOIN
    Locations ON Crimes."File Number" = Locations."File Number"
WHERE
    Locations."File Number" IS NULL;  

--When does the perpetrator appear? And when does he choose to take action? PostgreSQL and Database name Crime

SELECT
    EXTRACT(DAY FROM "Crime Date Time") AS Day_Of_Month,
    COUNT(*) AS Total_Crimes
FROM
    crime
GROUP BY
    Day_Of_Month 
ORDER BY
    Total_Crimes DESC; 

SELECT
    EXTRACT(HOUR FROM "Crime Date Time") AS Critical_Hour,
    COUNT(*) AS Total_Crimes
FROM CambridgeCrimeData
WHERE
    EXTRACT(HOUR FROM "Crime Date Time") IN (23, 0, 1)
GROUP BY Critical_Hour
ORDER BY Total_Crimes DESC;

--What are the characteristics of potential suspects? PostgreSQL and Database name Crime

SELECT crimes.crime, Locations.Neighborhood,Crimes."Crime Date Time"
FROM crime  
INNER JOIN
  Locations ON Crimes."File Number" = Locations."File Number" 
WHERE
    Locations.Neighborhood IN ('Cambridgeport', 'East Cambridge', 'North Cambridge', 'Area 4')
    AND
    (EXTRACT(DAY FROM Crimes."Crime Date Time") BETWEEN 13 AND 15 OR
        EXTRACT(HOUR FROM Crimes."Crime Date Time") IN (23, 0, 1))
ORDER BY
    Locations.Neighborhood, Crimes."Crime Date Time" DESC;

--What is the final crime ranking for Cambridge Port?
SELECT crime, COUNT(*) AS Total_Crimes,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS Crime_DenseRank
FROM CambridgeCrimeData
WHERE Neighborhood = 'Cambridgeport'
GROUP BY crime;

--What are the latest crimes?
SELECT crime, Neighborhood, Date_of_Report,
       ROW_NUMBER() OVER (PARTITION BY Neighborhood ORDER BY Date_of_Report DESC) AS Recent_Crime_Order
FROM CambridgeCrimeData
WHERE Neighborhood = 'Cambridgeport';

--What is the cumulative scale and impact of crimes in the region? PostgreSQL and Database name Crime
SELECT
    COUNT(*) AS Total_Crimes_Analyzed,
    SUM(CASE
        WHEN Crime IN ('Larceny from MV', 'Larceny of Bicycle', 'Hit and Run') THEN 1 ELSE 0
    END) AS Target_Crimes_Count,
    ROUND((CAST(SUM(CASE WHEN Crime IN ('Larceny from MV', 'Larceny of Bicycle', 'Hit and Run') THEN 1 ELSE 0
        END) AS REAL) * 100.0) / COUNT(*),2 )
 AS Target_Crimes_Percentage
FROM CambridgeCrimeData;

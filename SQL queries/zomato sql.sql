 SHOW VARIABLES LIKE 'secure_file_priv';
 
 LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/zom.csv'
INTO TABLE zom
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@RestaurantID,@RestaurantName,@CountryCode,@City,@Address,
@Locality,@LocalityVerbose,@Longitude,@Latitude,@Cuisines,
@Currency,@Has_Table_booking,@Has_Online_delivery,
@Is_delivering_now,@Switch_to_order_menu,@Price_range,
@Votes,@Average_Cost_for_two,@Rating,@Datekey_Opening)
SET
RestaurantID = @RestaurantID,
RestaurantName = @RestaurantName,
CountryCode = @CountryCode,
City = @City,
Address = @Address,
Locality = @Locality,
LocalityVerbose = @LocalityVerbose,
Longitude = @Longitude,
Latitude = @Latitude,
Cuisines = @Cuisines,
Currency = @Currency,
Has_Table_booking = @Has_Table_booking,
Has_Online_delivery = @Has_Online_delivery,
Is_delivering_now = @Is_delivering_now,
Switch_to_order_menu = @Switch_to_order_menu,
Price_range = @Price_range,
Votes = @Votes,
Average_Cost_for_two = @Average_Cost_for_two,
Rating = @Rating,
Datekey_Opening = STR_TO_DATE(@Datekey_Opening,'%m/%d/%Y');
 
 # --------------------------------------------------------------ZOMATO TABLE---------------------------------------------------------------

  CREATE TABLE zom (
RestaurantID BIGINT,
RestaurantName VARCHAR(255),
CountryCode INT,
City VARCHAR(100),
Address TEXT,
Locality VARCHAR(150),
LocalityVerbose TEXT,
Longitude DECIMAL(10,6),
Latitude DECIMAL(10,6),
Cuisines TEXT,
Currency VARCHAR(100),
Has_Table_booking VARCHAR(10),
Has_Online_delivery VARCHAR(10),
Is_delivering_now VARCHAR(10),
Switch_to_order_menu VARCHAR(10),
Price_range INT,
Votes INT,
Average_Cost_for_two INT,
Rating DECIMAL(3,1),
Datekey_Opening DATE
); 

# -------------------------------------------------------------CALENDAR TABLE----------------------------------------------------------------

CREATE TABLE calendar AS
SELECT
    Datekey_Opening AS FULL_DATE,
    YEAR(Datekey_Opening) AS YEAR,
    MONTH(Datekey_Opening) AS MONTHNO,
    MONTHNAME(Datekey_Opening) AS MONTHFULLNAME,
    CONCAT('Q', QUARTER(Datekey_Opening)) AS QUARTER,
    DATE_FORMAT(Datekey_Opening, '%Y-%b') AS YEARMONTH,
    DAYOFWEEK(Datekey_Opening) AS WEEKDAYNO,
    DAYNAME(Datekey_Opening) AS WEEKDAYNAME,

   # -- Financial Month (April start)
    CASE
        WHEN MONTH(Datekey_Opening) >= 4
            THEN MONTH(Datekey_Opening) - 3
        ELSE MONTH(Datekey_Opening) + 9
    END AS FINANCIAL_MONTH,

    #-- Financial Quarter
    CASE
        WHEN MONTH(Datekey_Opening) BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN MONTH(Datekey_Opening) BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN MONTH(Datekey_Opening) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END AS FINANCIAL_QUARTER

FROM zom;


SELECT * FROM CALENDAR;

# --------------------------------------------------------------COUNTRY TABLE----------------------------------------------------------------

CREATE TABLE country_map (
    CountryCode INT PRIMARY KEY,
    CountryName VARCHAR(100)
);

INSERT INTO country_map VALUES
(1,'India'),
(14,'Australia'),
(30,'Brazil'),
(37,'Canada'),
(94,'Indonesia'),
(148,'New Zealand'),
(162,'Philippines'),
(166,'Qatar'),
(184,'Singapore'),
(189,'South Africa'),
(191,'Sri Lanka'),
(208,'Turkey'),
(214,'UAE'),
(215,'UK'),
(216,'USA');

SELECT * FROM country_map;

SELECT *FROM ZOM;

# --------------------------------------------------------------TOTAL COUNTRY----------------------------------------------------------------

SELECT COUNT(DISTINCT COUNTRYCODE) AS TOTAL_COUNTRY FROM ZOM;

# --------------------------------------------------------------TOTAL CITY---------------------------------------------------------------------

SELECT COUNT(DISTINCT CITY) AS TOTAL_CITY FROM ZOM;

# --------------------------------------------------------------AVERAGE RATING----------------------------------------------------------------

SELECT ROUND(AVG(RATING),2) AS AVG_RATING FROM ZOM;

# --------------------------------------------------------------TOTAL RESTAURANT----------------------------------------------------------------

SELECT COUNT(DISTINCT RESTAURANTID) AS TOTAL_RESTAURANT FROM ZOM;

# --------------------------------------------------------------TABLE BOOKING----------------------------------------------------------------

SELECT HAS_TABLE_BOOKING, 
CONCAT(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2), " %" ) AS PERCENTAGE
FROM ZOM GROUP BY HAS_TABLE_BOOKING;

# --------------------------------------------------------------ONLINE DELIVERY----------------------------------------------------------------

SELECT HAS_ONLINE_DELIVERY, 
CONCAT(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2)," %") AS PERCENTAGE 
FROM ZOM GROUP BY HAS_ONLINE_DELIVERY;

# --------------------------------------------------------------RATING----------------------------------------------------------------

SELECT
  CASE
    WHEN RATING >= 4 THEN 'EXCELLENT(4-5)'
    WHEN RATING >= 3 THEN 'GREAT(3-4)'
    WHEN RATING >= 2 THEN 'Good(2-3)'
    WHEN RATING >= 1 THEN 'OKAY(1-2)'
    ELSE 'Average(0-1)'
  END AS RATING_CATEGORY,
  COUNT(*) AS TOTAL_RESTAURANT
FROM ZOM GROUP BY RATING_CATEGORY;


# --------------------------------------------------------------PRICE BUCKET----------------------------------------------------------------

SELECT
  CASE
    WHEN Average_Cost_for_two BETWEEN 0 AND 50000 THEN 'LOW (0-50K)'
    WHEN Average_Cost_for_two BETWEEN 50001 AND 150000 THEN 'MEDIUM (50K-1.5L)'
    WHEN Average_Cost_for_two BETWEEN 150001 AND 300000 THEN 'UPPER-MEDIUM (1.5L-3L)'
    WHEN Average_Cost_for_two BETWEEN 300001 AND 500000 THEN 'PREMIUM(3L-5L)'
    WHEN Average_Cost_for_two BETWEEN 500001 AND 800000 THEN 'LUXURY (5L-8L)'
  END AS PRICE_CATEGORY, COUNT(*) AS TOTAL
FROM ZOM GROUP BY PRICE_CATEGORY ORDER BY TOTAL DESC;

# --------------------------------------------------------------YEAR-MONTH-QUARTERWISE RESTAURANT----------------------------------------------------------------

SELECT YEAR(Datekey_Opening) AS YEAR, 
monthname(Datekey_Opening) AS MONTH, 
CONCAT('Q', QUARTER(Datekey_Opening)) AS QUARTER, 
COUNT(*) AS TOTAL_RESTAURANTS FROM ZOM
GROUP BY YEAR, MONTH, QUARTER 
ORDER BY YEAR,MONTH, QUARTER;


# --------------------------------------------------------------COUNTRY-CITYWISE RESTAURANT COUNT----------------------------------------------------------------

SELECT C.COUNTRYNAME, Z.CITY, COUNT(*) AS RESTAURANT_COUNT FROM ZOM Z
JOIN COUNTRY_MAP C ON Z.COUNTRYCODE = C.COUNTRYCODE
GROUP BY C.COUNTRYNAME, Z.CITY ORDER BY RESTAURANT_COUNT DESC;

# --------------------------------------------------------------TOP 10 CUISINES----------------------------------------------------------------

SELECT CUISINES, COUNT(*) AS RESTAURANT_COUNT FROM ZOM
GROUP BY CUISINES ORDER BY RESTAURANT_COUNT DESC LIMIT 10;
USE cafe_db;

-- Update date format and remove commas from price values
UPDATE daily_sales
SET date = DATE_FORMAT(STR_TO_DATE(date, '%m/%d/%y'), '%Y-%m-%d'),
	total_sales = REPLACE(total_sales, ',', ''),
	average_order_value = REPLACE(average_order_value, ',', '');

-- Modify columns in daily_sales table to appropriate data types and constraints
ALTER TABLE daily_sales
	MODIFY COLUMN date_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	MODIFY COLUMN date DATE,
	MODIFY COLUMN day_id INT,
	MODIFY COLUMN total_sales INT,
	MODIFY COLUMN order_count INT,
	MODIFY COLUMN average_order_value INT;

-- Add a new column for season
ALTER TABLE daily_sales
	ADD COLUMN season VARCHAR(10);

UPDATE daily_sales
SET season = 
    CASE 
        WHEN MONTH(date) BETWEEN 3 AND 5 THEN 'Spring'  -- March, April, May
        WHEN MONTH(date) BETWEEN 6 AND 8 THEN 'Summer'  -- June, July, August
        WHEN MONTH(date) BETWEEN 9 AND 11 THEN 'Fall'   -- September, October, November
        ELSE 'Winter'  -- January, February, December
    END;

-- Check for NULL values in daily_sales table
SELECT *
FROM daily_sales
WHERE date IS NULL
	OR day_id IS NULL
	OR total_sales IS NULL
	OR order_count IS NULL
	OR average_order_value IS NULL;

-- Update 'ICE' to 'COLD' and empty strings to 'N/A' in temperature column
UPDATE product
SET temperature = 'COLD'
WHERE temperature = 'ICE';

-- Update values where empty string is found
UPDATE product
SET temperature = 'N/A'  -- products in dessert category
WHERE temperature = '';

-- Remove products not exist in the time period for which data was collected
DELETE FROM product
WHERE launched_on = '';

-- Update date format and remove commas from price values
UPDATE product
SET launched_on = DATE_FORMAT(STR_TO_DATE(launched_on, '%m/%d/%y'), '%Y-%m-%d'),
	discontinued_on = DATE_FORMAT(STR_TO_DATE(discontinued_on, '%m/%d/%y'), '%Y-%m-%d'),
	price = REPLACE(price, ',', '');

-- Modify columns in product table to appropriate data types and constraints
ALTER TABLE product
	MODIFY COLUMN product_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	MODIFY COLUMN name VARCHAR(30),
	MODIFY COLUMN price INT,
	MODIFY COLUMN category VARCHAR(15),
	MODIFY COLUMN temperature ENUM('HOT', 'COLD', 'N/A'),
	MODIFY COLUMN launched_on DATE,
	MODIFY COLUMN discontinued_on DATE;

-- Check for NULL values in product table
SELECT *
FROM product
WHERE name IS NULL
	OR price IS NULL
	OR category IS NULL
    OR temperature IS NULL
    OR launched_on IS NULL
    OR discontinued_on IS NULL;

-- Modify columns in product_sales table to appropriate data types
ALTER TABLE product_sales
	MODIFY COLUMN date_id INT,
	MODIFY COLUMN product_id INT,
	MODIFY COLUMN quantity_sold INT;

-- Remove commas from price values
UPDATE sales_by_day_of_week
SET total_sales = REPLACE(total_sales, ',', ''),
	average_order_value = REPLACE(average_order_value, ',', '');

-- Modify columns in sales_by_day_of_week table to appropriate data types
ALTER TABLE sales_by_day_of_week
	MODIFY COLUMN day_id INT NOT NULL PRIMARY KEY,
	MODIFY COLUMN day_of_week VARCHAR(3),
	MODIFY COLUMN total_sales INT,
	MODIFY COLUMN order_count INT,
	MODIFY COLUMN average_order_value INT;

-- Check for NULL values in sales_by_day_of_week table
SELECT *
FROM sales_by_day_of_week
WHERE day_of_week IS NULL
	OR total_sales IS NULL
	OR order_count IS NULL
	OR average_order_value IS NULL;
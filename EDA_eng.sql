-- Normalize sales by sale period
SELECT p.product_id
	, SUM(ps.quantity_sold) AS total_sales
    , SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
FROM product_sales AS ps
LEFT JOIN product AS p ON ps.product_id = p.product_id
GROUP BY p.product_id;

-- Find the 10 most popular products across categories
WITH normalized_product_sales AS(
	SELECT p.product_id
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on = '2023-12-31'
	GROUP BY p.product_id
)

SELECT p.name
    , p.temperature 
	, nps.total_sales
FROM normalized_product_sales AS nps
INNER JOIN product AS p ON nps.product_id = p.product_id
ORDER BY normalized_sales DESC;

-- Find the 10 most popular, available products across categories (ONLY_FULL_GROUP_BY mode disabled)
WITH normalized_product_sales AS(
	SELECT p.name
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on = '2023-12-31'
	GROUP BY p.name
)

SELECT name
	, total_sales
FROM normalized_product_sales
ORDER BY normalized_sales DESC
LIMIT 10;

-- Find the 10 most popular discontinued products across categories (ONLY_FULL_GROUP_BY mode disabled)
WITH normalized_product_sales AS(
	SELECT p.name
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on != '2023-12-31'
	GROUP BY p.name
)

SELECT name
	, total_sales
FROM normalized_product_sales
ORDER BY normalized_sales DESC
LIMIT 10;

-- Find the 10 least popular products across categories
WITH normalized_product_sales AS(
	SELECT p.product_id
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on = '2023-12-31'
	GROUP BY p.product_id
)

SELECT p.name
    , p.temperature
	, nps.total_sales
FROM normalized_product_sales AS nps
INNER JOIN product AS p ON nps.product_id = p.product_id
ORDER BY normalized_sales
LIMIT 10;

-- Find the 10 least popular, available products across categories (ONLY_FULL_GROUP_BY mode disabled)
WITH normalized_product_sales AS(
	SELECT p.name
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on = '2023-12-31'
	GROUP BY p.name
)

SELECT name
	, total_sales
FROM normalized_product_sales
ORDER BY normalized_sales
LIMIT 10;

-- Find the 5 most popular products for each category
WITH normalized_product_sales AS(
	SELECT p.product_id
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY p.product_id
),
product_sales_info AS (
	SELECT p.category
		, p.name
		, p.temperature
		, nps.total_sales
        , nps.normalized_sales
	FROM normalized_product_sales AS nps
	INNER JOIN product AS p ON nps.product_id = p.product_id
)

SELECT category
	, name
    , temperature
	, total_sales
    , rk
FROM (
	SELECT *
		, RANK() OVER (PARTITION BY category ORDER BY normalized_sales DESC) AS rk
	FROM product_sales_info
) AS ranked_product
WHERE rk <= 5;

-- Find the 5 least popular products for each category
WITH normalized_product_sales AS(
	SELECT p.product_id
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY p.product_id
),
product_sales_info AS (
	SELECT p.category
		, p.name
		, p.temperature
		, nps.total_sales
        , nps.normalized_sales
	FROM normalized_product_sales AS nps
	INNER JOIN product AS p ON nps.product_id = p.product_id
)

SELECT category
	, name
    , temperature
	, total_sales
    , rk
FROM (
	SELECT *
		, RANK() OVER (PARTITION BY category ORDER BY normalized_sales) AS rk
	FROM product_sales_info
) AS ranked_product
WHERE rk <= 5;

-- Find the 5 least popular, available products for each category (ONLY_FULL_GROUP_BY mode disabled)
WITH normalized_product_sales AS(
	SELECT p.category
		, p.name
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE p.discontinued_on = '2023-12-31'
	GROUP BY p.name
)

SELECT category
	, name
	, total_sales
    , rk
FROM (
	SELECT *
		, RANK() OVER (PARTITION BY category ORDER BY normalized_sales) AS rk
	FROM normalized_product_sales
) AS ranked_product
WHERE rk <= 20;

-- Rank days of the week by three sales metrics
SELECT day_of_week
	, total_sales
    , ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS sales_rk
    , order_count
    , ROW_NUMBER() OVER (ORDER BY order_count DESC) AS count_rk
    , average_order_value
    , ROW_NUMBER() OVER (ORDER BY average_order_value DESC) AS AOV_rk
FROM sales_by_day_of_week
ORDER BY day_id;

-- Rank hours within business hours by sales ratio
SELECT start_hour
	, end_hour
    , sales_ratio
    , ROW_NUMBER() OVER (ORDER BY sales_ratio DESC) AS sales_rk
FROM sales_by_hour
WHERE start_hour >= '10:00:00'  -- opening time
	AND end_hour <= '18:00:00'  -- closing time
ORDER BY start_hour;

-- Find the most popular category for each season
WITH spring_category AS(
	SELECT ds.season
		, p.category
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = 'Spring'
	GROUP BY category
    ORDER BY total_sales DESC
    LIMIT 1
),
summer_category AS(
	SELECT ds.season
		, p.category
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = 'Summer'
	GROUP BY category
    ORDER BY total_sales DESC
    LIMIT 1
),
fall_category AS(
	SELECT ds.season
		, p.category
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = 'Fall'
	GROUP BY category
    ORDER BY total_sales DESC
    LIMIT 1
),
winter_category AS(
	SELECT ds.season
		, p.category
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = 'Winter'
	GROUP BY category
    ORDER BY total_sales DESC
    LIMIT 1
)

SELECT *
FROM spring_category
UNION
SELECT *
FROM summer_category
UNION
SELECT *
FROM fall_category
UNION
SELECT *
FROM winter_category;

-- Find the least popular category for each season
WITH spring_category AS(
	SELECT ds.season
		, p.category
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = 'Spring'
	GROUP BY category
    ORDER BY total_sales
    LIMIT 1
),
summer_category AS(
	SELECT ds.season
		, p.category
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = 'Summer'
	GROUP BY category
    ORDER BY total_sales
    LIMIT 1
),
fall_category AS(
	SELECT ds.season
		, p.category
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = 'Fall'
	GROUP BY category
    ORDER BY total_sales
    LIMIT 1
),
winter_category AS(
	SELECT ds.season
		, p.category
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = 'Winter'
	GROUP BY category
    ORDER BY total_sales
    LIMIT 1
)

SELECT *
FROM spring_category
UNION
SELECT *
FROM summer_category
UNION
SELECT *
FROM fall_category
UNION
SELECT *
FROM winter_category;

-- Calculate total sales for each temperature category within each season (pivot table)
WITH seasonal_data AS(
	SELECT ds.season
		, p.temperature
        , SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    GROUP BY p.product_id
		, ds.season
        , p.temperature
)

SELECT season
	, ROUND(SUM(CASE WHEN temperature = 'HOT' THEN normalized_sales ELSE 0 END), 2) AS HOT
    , ROUND(SUM(CASE WHEN temperature = 'COLD' THEN normalized_sales ELSE 0 END), 2) AS COLD
FROM seasonal_data
GROUP BY season
ORDER BY
    CASE season
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Fall' THEN 3
        WHEN 'Winter' THEN 4
    END;

-- Find the 5 most popular products for each season
WITH spring_product AS(
	SELECT ds.season
		, p.name
		, p.temperature
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= 'Spring'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) DESC
	LIMIT 5
),
summer_product AS(
	SELECT ds.season
		, p.name
		, p.temperature
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= 'Summer'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) DESC
	LIMIT 5
),
fall_product AS(
	SELECT ds.season
		, p.name
		, p.temperature
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= 'Fall'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) DESC
	LIMIT 5
),
winter_product AS(
	SELECT ds.season
		, p.name
		, p.temperature
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= 'Winter'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) DESC
	LIMIT 5
)

SELECT *
FROM spring_product
UNION
SELECT *
FROM summer_product
UNION
SELECT *
FROM fall_product
UNION
SELECT *
FROM winter_product;

-- Find the 5 most popular products in winter
SELECT ds.season
	, p.name
	, p.temperature
	, SUM(ps.quantity_sold) AS total_sales
FROM product_sales AS ps
LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
LEFT JOIN product AS p ON ps.product_id = p.product_id
GROUP BY ds.season
	, p.product_id
HAVING ds.season= 'Winter'
ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) DESC
LIMIT 10;

-- Find the 5 least popular products for each season
WITH spring_product AS(
	SELECT ds.season
		, p.name
		, p.temperature
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= 'Spring'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on)
	LIMIT 5
),
summer_product AS(
	SELECT ds.season
		, p.name
		, p.temperature
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= 'Summer'
		AND p.temperature != 'HOT'  -- exclude hot products
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on)
	LIMIT 5
),
fall_product AS(
	SELECT ds.season
		, p.name
		, p.temperature
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= 'Fall'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on)
	LIMIT 5
),
winter_product AS(
	SELECT ds.season
		, p.name
		, p.temperature
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= 'Winter'
		AND p.temperature != 'COLD'  -- exclude cold products
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on)
	LIMIT 5
)

SELECT *
FROM spring_product
UNION
SELECT *
FROM summer_product
UNION
SELECT *
FROM fall_product
UNION
SELECT *
FROM winter_product;

-- Identify the 10 most profitable products
WITH sales AS(
SELECT p.name
	, SUM(quantity_sold) AS quantity_sold
    , SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_quantity_sold
FROM product_sales AS ps
LEFT JOIN product AS p ON ps.product_id = p.product_id
GROUP BY p.product_id
)

SELECT name
    , quantity_sold
    , (normalized_quantity_sold / SUM(normalized_quantity_sold) OVER ()) AS contribution_ratio
FROM sales
ORDER BY contribution_ratio DESC
LIMIT 10;

-- Identify the 10 least profitable products
WITH sales AS(
SELECT p.name
	, SUM(quantity_sold) AS quantity_sold
    , SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_quantity_sold
FROM product_sales AS ps
LEFT JOIN product AS p ON ps.product_id = p.product_id
GROUP BY p.product_id
)

SELECT name
    , quantity_sold
    , (normalized_quantity_sold / SUM(normalized_quantity_sold) OVER ()) AS contribution_ratio
FROM sales
ORDER BY contribution_ratio
LIMIT 10;


-- Compare average normalized sales of black tea and non-black tea products by category
WITH black_tea_data AS(
	SELECT p.product_id
		, CASE WHEN p.category = 'Dessert' THEN 'Dessert' ELSE 'Drinks' END AS adjusted_category
        , SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    GROUP BY p.product_id
)

SELECT adjusted_category
	, ROUND(AVG(CASE WHEN product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 73, 74, 76) THEN normalized_sales ELSE 0 END), 2) AS black_tea_sales
    , ROUND(AVG(CASE WHEN product_id NOT IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 73, 74, 76) THEN normalized_sales ELSE 0 END), 2) AS non_black_tea_sales
FROM black_tea_data
GROUP BY adjusted_category;

-- Calculate average normalized_sales of target products positioned at the top-left/right corners by category
WITH position_data AS(
	SELECT p.product_id
		, p.category
        , SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    GROUP BY p.product_id
)

SELECT category
	, ROUND(AVG(CASE WHEN product_id IN (1, 2, 7, 8, 11, 12, 26, 27, 32, 33, 66, 82, 85, 25, 10, 18, 50, 83, 84, 73, 74, 75, 63) THEN normalized_sales ELSE NULL END), 2) AS target_product_sales
    , ROUND(AVG(CASE WHEN product_id NOT IN (1, 2, 7, 8, 11, 12, 26, 27, 32, 33, 66, 82, 85, 25, 10, 18, 50, 83, 84, 73, 74, 75, 63) THEN normalized_sales ELSE NULL END), 2) AS other_product_sales
FROM position_data
GROUP BY category;

-- Calculate average normalized_sales of products with keywords
WITH keyword_data AS(
	SELECT p.product_id
		, p.category
        , SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    GROUP BY p.product_id
)

SELECT ROUND(AVG(CASE WHEN product_id IN (1, 2, 25, 73, 74, 75) THEN normalized_sales ELSE NULL END), 2) AS keyword_product_sales
    , ROUND(AVG(CASE WHEN product_id NOT IN (1, 2, 25, 73, 74, 75) THEN normalized_sales ELSE NULL END), 2) AS other_product_sales
FROM keyword_data;

-- Calculate average normalized_sales of discontinued products and products available for sale
WITH discontinued_product_sales AS(
	SELECT p.product_id
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on != '2023-12-31'
	GROUP BY p.product_id
),
all_available_product_sales AS(
	SELECT p.product_id
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on = '2023-12-31'
	GROUP BY p.product_id
),
available_product_sales AS(
	SELECT product_id
		, normalized_sales
	FROM all_available_product_sales
	ORDER BY normalized_sales ASC
	LIMIT 26
),
combined_product_sales AS(
	SELECT 
		dps.product_id,
		dps.normalized_sales AS discontinued_normalized_sales,
		aps.normalized_sales AS available_normalized_sales
	FROM 
		discontinued_product_sales AS dps
	LEFT JOIN 
		available_product_sales AS aps 
	ON 
		dps.product_id = aps.product_id
	UNION
	SELECT 
		aps.product_id,
		dps.normalized_sales AS discontinued_normalized_sales,
		aps.normalized_sales AS available_normalized_sales
	FROM 
		discontinued_product_sales AS dps
	RIGHT JOIN 
		available_product_sales AS aps 
	ON 
		dps.product_id = aps.product_id
)

SELECT ROUND(AVG(discontinued_normalized_sales), 2) AS discontinued_product_sales
	, ROUND(AVG(available_normalized_sales), 2) AS available_product_sales
FROM combined_product_sales;

WITH winter_product AS(
	SELECT ds.season
		, p.name
		, p.temperature
		, SUM(ps.quantity_sold) AS total_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.category != 'Dessert'
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= 'Winter'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) DESC
	LIMIT 10
)

SELECT *
FROM winter_product;

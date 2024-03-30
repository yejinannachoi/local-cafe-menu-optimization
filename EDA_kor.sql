-- 판매량을 판매 기간으로 나누어 정규화
SELECT p.product_id AS '제품 아이디'
	, SUM(ps.quantity_sold) AS '총판매량'
    , SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS '정규화된 판매량'
FROM product_sales AS ps
LEFT JOIN product AS p ON ps.product_id = p.product_id
GROUP BY p.product_id;

-- 전체 제품 판매량 상위 TOP 10
WITH normalized_product_sales AS(
	SELECT p.product_id
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on = '2023-12-31'
	GROUP BY p.product_id
)

SELECT p.name AS '제품명'
    , p.temperature AS '제품 온도'
	, nps.total_sales AS '총판매량'
FROM normalized_product_sales AS nps
INNER JOIN product AS p ON nps.product_id = p.product_id
ORDER BY normalized_sales DESC;

-- 현재 판매되고 있는 전체 제품 판매량 상위 TOP 10 (ONLY_FULL_GROUP_BY mode 비활성화)
WITH normalized_product_sales AS(
	SELECT p.name
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on = '2023-12-31'
	GROUP BY p.name
)

SELECT name AS '제품명'
	, total_sales AS '총판매량'
FROM normalized_product_sales
ORDER BY normalized_sales DESC
LIMIT 10;

-- 판매 중단된 전체 제품 판매량 상위 TOP 10 (ONLY_FULL_GROUP_BY mode 비활성화)
WITH normalized_product_sales AS(
	SELECT p.name
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on != '2023-12-31'
	GROUP BY p.name
)

SELECT name AS '제품명'
	, total_sales AS '총판매량'
FROM normalized_product_sales
ORDER BY normalized_sales DESC
LIMIT 10;

-- 전체 제품 판매량 하위 TOP 10
WITH normalized_product_sales AS(
	SELECT p.product_id
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on = '2023-12-31'
	GROUP BY p.product_id
)

SELECT p.name AS '제품명'
    , p.temperature AS '제품 온도'
	, nps.total_sales AS '총판매량'
FROM normalized_product_sales AS nps
INNER JOIN product AS p ON nps.product_id = p.product_id
ORDER BY normalized_sales
LIMIT 10;

-- 현재 판매되고 있는 전체 제품 판매량 하위 TOP 10 (ONLY_FULL_GROUP_BY mode disabled)
WITH normalized_product_sales AS(
	SELECT p.name
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on = '2023-12-31'
	GROUP BY p.name
)

SELECT name AS '제품명'
	, total_sales AS '총판매량'
FROM normalized_product_sales
ORDER BY normalized_sales
LIMIT 10;

-- 카테고리별 제품 판매량 상위 TOP 5 순위 매기기
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

SELECT category AS '카테고리'
	, name AS '제품명'
    , temperature AS '제품 온도'
	, total_sales AS '총판매량'
    , rk AS '순위'
FROM (
	SELECT *
		, RANK() OVER (PARTITION BY category ORDER BY normalized_sales DESC) AS rk
	FROM product_sales_info
) AS ranked_product
WHERE rk <= 5;

-- 카테고리별 제품 판매량 하위 TOP 5 순위 매기기
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

SELECT category AS '카테고리'
	, name AS '제품명'
    , temperature AS '제품 온도'
	, total_sales AS '총판매량'
    , rk AS '순위'
FROM (
	SELECT *
		, RANK() OVER (PARTITION BY category ORDER BY normalized_sales) AS rk
	FROM product_sales_info
) AS ranked_product
WHERE rk <= 5;

-- 카테고리별 현재 판매되고 있는 제품 판매량 하위 TOP 15 (ONLY_FULL_GROUP_BY mode disabled)
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

SELECT category AS '카테고리'
	, name AS '제품명'
	, total_sales AS '총판매량'
    , rk AS '순위'
FROM (
	SELECT *
		, RANK() OVER (PARTITION BY category ORDER BY normalized_sales) AS rk
	FROM normalized_product_sales
) AS ranked_product
WHERE rk <= 20;

-- 각 요일을 세 가지 판매 지표로 순위 매기기
SELECT day_of_week AS '요일'
	, total_sales AS '총판매량'
    , ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS '매출 순위'
    , order_count AS '결제 건수'
    , ROW_NUMBER() OVER (ORDER BY order_count DESC) AS '결제 건수 순위'
    , average_order_value AS '영수 단가'
    , ROW_NUMBER() OVER (ORDER BY average_order_value DESC) AS '영수 단가 순위'
FROM sales_by_day_of_week
ORDER BY day_id;

-- 영업 시간 내 시간대가 차지하는 매출 비율 순위 매기기
SELECT start_hour AS '시작 시각'
	, end_hour AS '끝 시각'
    , sales_ratio AS '매출 비율'
    , ROW_NUMBER() OVER (ORDER BY sales_ratio DESC) AS '매출 순위'
FROM sales_by_hour
WHERE start_hour >= '10:00:00'  -- 오픈 시간
	AND end_hour <= '18:00:00'  -- 마감 시간
ORDER BY start_hour;

-- 계절별 인기 카테고리
WITH spring_category AS(
	SELECT ds.season AS '계절'
		, p.category AS '카테고리'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = '봄'
	GROUP BY category
    ORDER BY total_sales DESC
    LIMIT 1
),
summer_category AS(
	SELECT ds.season AS '계절'
		, p.category AS '카테고리'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = '여름'
	GROUP BY category
    ORDER BY total_sales DESC
    LIMIT 1
),
fall_category AS(
	SELECT ds.season AS '계절'
		, p.category AS '카테고리'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = '가을'
	GROUP BY category
    ORDER BY total_sales DESC
    LIMIT 1
),
winter_category AS(
	SELECT ds.season AS '계절'
		, p.category AS '카테고리'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = '겨울'
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

-- 계절별 비인기 카테고리
WITH spring_category AS(
	SELECT ds.season AS '계절'
		, p.category AS '카테고리'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = '봄'
	GROUP BY category
    ORDER BY total_sales
    LIMIT 1
),
summer_category AS(
	SELECT ds.season AS '계절'
		, p.category AS '카테고리'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = '여름'
	GROUP BY category
    ORDER BY total_sales
    LIMIT 1
),
fall_category AS(
	SELECT ds.season AS '계절'
		, p.category AS '카테고리'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = '가을'
	GROUP BY category
    ORDER BY total_sales
    LIMIT 1
),
winter_category AS(
	SELECT ds.season AS '계절'
		, p.category AS '카테고리'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	WHERE ds.season = '겨울'
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

-- 계절별 각 온도 카테고리의 제품 총판매량 계산하기 (피벗 테이블)
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

SELECT season AS '계절'
	, ROUND(SUM(CASE WHEN temperature = 'HOT' THEN normalized_sales ELSE 0 END), 2) AS HOT
    , ROUND(SUM(CASE WHEN temperature = 'COLD' THEN normalized_sales ELSE 0 END), 2) AS COLD
FROM seasonal_data
GROUP BY season
ORDER BY
    CASE season
        WHEN '봄' THEN 1
        WHEN '여름' THEN 2
        WHEN '가을' THEN 3
        WHEN '겨울' THEN 4
    END;

-- 계절별 인기 제품 TOP 5
WITH spring_product AS(
	SELECT ds.season AS '계절'
		, p.name AS '제품명'
		, p.temperature AS '제품 온도'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= '봄'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) DESC
	LIMIT 5
),
summer_product AS(
	SELECT ds.season AS '계절'
		, p.name AS '제품명'
		, p.temperature AS '제품 온도'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= '여름'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) DESC
	LIMIT 5
),
fall_product AS(
	SELECT ds.season AS '계절'
		, p.name AS '제품명'
		, p.temperature AS '제품 온도'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= '가을'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) DESC
	LIMIT 5
),
winter_product AS(
	SELECT ds.season AS '계절'
		, p.name AS '제품명'
		, p.temperature AS '제품 온도'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= '겨울'
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

-- 겨울 인기 제품 TOP 10
SELECT ds.season AS '계절'
	, p.name AS '제품명'
	, p.temperature AS '제품 온도'
	, SUM(ps.quantity_sold) AS '총판매량'
FROM product_sales AS ps
LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
LEFT JOIN product AS p ON ps.product_id = p.product_id
GROUP BY ds.season
	, p.product_id
HAVING ds.season= '겨울'
ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) DESC
LIMIT 10;

-- 계절별 비인기 제품 TOP 5
WITH spring_product AS(
	SELECT ds.season AS '계절'
		, p.name AS '제품명'
		, p.temperature AS '제품 온도'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= '봄'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on)
	LIMIT 5
),
summer_product AS(
	SELECT ds.season AS '계절'
		, p.name AS '제품명'
		, p.temperature AS '제품 온도'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= '여름'
		AND p.temperature != 'HOT'  -- 여름은 뜨거운 음료 제외
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on)
	LIMIT 5
),
fall_product AS(
	SELECT ds.season AS '계절'
		, p.name AS '제품명'
		, p.temperature AS '제품 온도'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= '가을'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on)
	LIMIT 5
),
winter_product AS(
	SELECT ds.season AS '계절'
		, p.name AS '제품명'
		, p.temperature AS '제품 온도'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= '겨울'
		AND p.temperature != 'COLD' -- 겨울은 차가운 음료 제외
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

-- 수익성 높은 제품 TOP 10
WITH sales AS(
SELECT p.name
	, SUM(quantity_sold) AS quantity_sold
    , SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_quantity_sold
FROM product_sales AS ps
LEFT JOIN product AS p ON ps.product_id = p.product_id
GROUP BY p.product_id
)

SELECT name AS '제품명'
    , quantity_sold AS '총판매량'
    , (normalized_quantity_sold / SUM(normalized_quantity_sold) OVER ()) AS '수익성'
FROM sales
ORDER BY 수익성 DESC
LIMIT 10;

-- 수익성 낮은 제품 TOP 10
WITH sales AS(
SELECT p.name
	, SUM(quantity_sold) AS quantity_sold
    , SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_quantity_sold
FROM product_sales AS ps
LEFT JOIN product AS p ON ps.product_id = p.product_id
GROUP BY p.product_id
)

SELECT name AS '제품명'
    , quantity_sold AS '총판매량'
    , (normalized_quantity_sold / SUM(normalized_quantity_sold) OVER ()) AS '수익성'
FROM sales
ORDER BY 수익성
LIMIT 10;


-- 카테고리별 홍차 제품과 비홍차 제품의 평균 판매량 계산하기
WITH black_tea_data AS(
	SELECT p.product_id
		, CASE WHEN p.category = '디저트' THEN '디저트' ELSE '음료' END AS adjusted_category
        , SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    GROUP BY p.product_id
)

SELECT adjusted_category AS '조정된 카테고리'
	, ROUND(AVG(CASE WHEN product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 73, 74, 76) THEN normalized_sales ELSE 0 END), 2) AS '홍차 제품 판매량'
    , ROUND(AVG(CASE WHEN product_id NOT IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 73, 74, 76) THEN normalized_sales ELSE 0 END), 2) AS '비홍차 제품 판매량'
FROM black_tea_data
GROUP BY adjusted_category;

-- 카테고리별 상단 좌측/우측에 위치한 제품의 평균 판매량 계산하기
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

SELECT category AS '카테고리'
	, ROUND(AVG(CASE WHEN product_id IN (1, 2, 7, 8, 11, 12, 26, 27, 32, 33, 66, 82, 85, 25, 10, 18, 50, 83, 84, 73, 74, 75, 63) THEN normalized_sales ELSE NULL END), 2) AS '타겟 제품 판매량'
    , ROUND(AVG(CASE WHEN product_id NOT IN (1, 2, 7, 8, 11, 12, 26, 27, 32, 33, 66, 82, 85, 25, 10, 18, 50, 83, 84, 73, 74, 75, 63) THEN normalized_sales ELSE NULL END), 2) AS '일반 제품 판매량'
FROM position_data
GROUP BY category;

-- 추천 문구를 포함한 제품과 그렇지 않은 제품의 평균 판매량 계산하기
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

SELECT ROUND(AVG(CASE WHEN product_id IN (1, 2, 25, 73, 74, 75) THEN normalized_sales ELSE NULL END), 2) AS '추천 제품 판매량'
    , ROUND(AVG(CASE WHEN product_id NOT IN (1, 2, 25, 73, 74, 75) THEN normalized_sales ELSE NULL END), 2) AS '일반 제품 판매량'
FROM keyword_data;

-- 중단된 제품과 현재 판매되고 있는 제품의 평균 판매량 계산하기
WITH discontinued_product_sales AS(
	SELECT p.product_id
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on != '2023-12-31'  -- 단종된 제품
	GROUP BY p.product_id
),
all_available_product_sales AS(
	SELECT p.product_id
		, SUM(ps.quantity_sold) AS total_sales
		, SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) AS normalized_sales
	FROM product_sales AS ps
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.discontinued_on = '2023-12-31'  -- 현재 판매하고 있는 제품
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

SELECT ROUND(AVG(discontinued_normalized_sales), 2) AS '단종된 제품 판매량'
	, ROUND(AVG(available_normalized_sales), 2) AS '판매 제품 판매량'
FROM combined_product_sales;

-- 겨울 음료 판매량 상위 TOP 10
WITH winter_product AS(
	SELECT ds.season AS '계절'
		, p.name AS '제품명'
		, p.temperature AS '제품 온도'
		, SUM(ps.quantity_sold) AS '총판매량'
	FROM product_sales AS ps
	LEFT JOIN daily_sales AS ds ON ps.date_id = ds.date_id
	LEFT JOIN product AS p ON ps.product_id = p.product_id
    WHERE p.category != '디저트'
	GROUP BY ds.season
		, p.product_id
	HAVING ds.season= '겨울'
	ORDER BY SUM(ps.quantity_sold) / DATEDIFF(p.discontinued_on, p.launched_on) DESC
	LIMIT 10
)

SELECT *
FROM winter_product;
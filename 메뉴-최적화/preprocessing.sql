USE cafe_db;

-- 날짜 형식을 업데이트하고 금액 데이터에서 쉼표 제거
UPDATE daily_sales
SET date = DATE_FORMAT(STR_TO_DATE(date, '%m/%d/%y'), '%Y-%m-%d'),
	total_sales = REPLACE(total_sales, ',', ''),
	average_order_value = REPLACE(average_order_value, ',', '');

-- daily_sales 테이블의 컬럼들을 적절한 데이터 타입으로 수정하고 제약 조건 추가
ALTER TABLE daily_sales
	MODIFY COLUMN date_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	MODIFY COLUMN date DATE,
	MODIFY COLUMN day_id INT,
	MODIFY COLUMN total_sales INT,
	MODIFY COLUMN order_count INT,
	MODIFY COLUMN average_order_value INT;

-- daily_sales 테이블에 계절 컬럼 추가
ALTER TABLE daily_sales
	ADD COLUMN season VARCHAR(10);

UPDATE daily_sales
SET season = 
    CASE 
        WHEN MONTH(date) BETWEEN 3 AND 5 THEN '봄'  -- 3, 4, 5월
        WHEN MONTH(date) BETWEEN 6 AND 8 THEN '여름'  -- 6, 7, 8월
        WHEN MONTH(date) BETWEEN 9 AND 11 THEN '가을'   -- 9, 10, 11월
        ELSE '겨울'  -- 1, 2, 12월
    END;

-- daily_sales 테이블 NULL 값 확인
SELECT *
FROM daily_sales
WHERE date IS NULL
	OR day_id IS NULL
	OR total_sales IS NULL
	OR order_count IS NULL
	OR average_order_value IS NULL;

-- 온도 컬럼에서 'ICE'를 'COLD'로 수정하고 빈 문자열은 'N/A' 입력
UPDATE product
SET temperature = 'COLD'
WHERE temperature = 'ICE';

-- 빈 문자열은 'N/A' 입력
UPDATE product
SET temperature = 'N/A'  -- 디저트 카테고리 제품
WHERE temperature = '';

-- 데이터 수집 기간에 존재하지 않는 제품을 제거
DELETE FROM product
WHERE launched_on = '';

-- 날짜 형식을 업데이트하고 금액 데이터에서 쉼표 제거
UPDATE product
SET launched_on = DATE_FORMAT(STR_TO_DATE(launched_on, '%m/%d/%y'), '%Y-%m-%d'),
	discontinued_on = DATE_FORMAT(STR_TO_DATE(discontinued_on, '%m/%d/%y'), '%Y-%m-%d'),
	price = REPLACE(price, ',', '');

-- product 테이블의 컬럼들을 적절한 데이터 타입으로 수정하고 제약 조건 추가
ALTER TABLE product
	MODIFY COLUMN product_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	MODIFY COLUMN name VARCHAR(30),
	MODIFY COLUMN price INT,
	MODIFY COLUMN category VARCHAR(15),
	MODIFY COLUMN temperature ENUM('HOT', 'COLD', 'N/A'),
	MODIFY COLUMN launched_on DATE,
	MODIFY COLUMN discontinued_on DATE;

-- product 테이블 NULL 값 확인
SELECT *
FROM product
WHERE name IS NULL
	OR price IS NULL
	OR category IS NULL
    OR temperature IS NULL
    OR launched_on IS NULL
    OR discontinued_on IS NULL;

-- product_sales 테이블의 컬럼들을 적절한 데이터 타입으로 수정
ALTER TABLE product_sales
	MODIFY COLUMN date_id INT,
	MODIFY COLUMN product_id INT,
	MODIFY COLUMN quantity_sold INT;

-- 금액 데이터에서 쉼표 제거
UPDATE sales_by_day_of_week
SET total_sales = REPLACE(total_sales, ',', ''),
	average_order_value = REPLACE(average_order_value, ',', '');

-- sales_by_day_of_week 테이블의 컬럼들을 적절한 데이터 타입으로 수정
ALTER TABLE sales_by_day_of_week
	MODIFY COLUMN day_id INT NOT NULL PRIMARY KEY,
	MODIFY COLUMN day_of_week VARCHAR(3),
	MODIFY COLUMN total_sales INT,
	MODIFY COLUMN order_count INT,
	MODIFY COLUMN average_order_value INT;

-- sales_by_day_of_week 테이블 NULL 값 확인
SELECT *
FROM sales_by_day_of_week
WHERE day_of_week IS NULL
	OR total_sales IS NULL
	OR order_count IS NULL
	OR average_order_value IS NULL;

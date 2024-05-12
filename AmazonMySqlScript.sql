create database amazondb;
show database;
use amazondb;

CREATE TABLE amazon (
  invoice_id VARCHAR(30) NOT NULL,
  branch VARCHAR(5) NOT NULL,
  city VARCHAR(30) NOT NULL,
  customer_type VARCHAR(30) NOT NULL,
  gender VARCHAR(10) NOT NULL,
  product_line VARCHAR(100) NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  quantity INT NOT NULL,
  VAT FLOAT(6, 4) NOT NULL,
  total DECIMAL(10, 2) NOT NULL,
  date DATE NOT NULL,
  time TIMESTAMP NOT NULL,
  payment_method DECIMAL(10, 2) NOT NULL,
  cogs DECIMAL(10, 2) NOT NULL,
  gross_margin_percentage FLOAT(11, 9) NOT NULL,
  gross_income DECIMAL(10, 2) NOT NULL,
  rating FLOAT(2, 1) NOT NULL
);

select * from amazon;

LOAD DATA INFILE 'D:\Dont Touch\Downloads\Amazon.csv'
INTO TABLE amazon
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from amazon;

ALTER TABLE amazon
ADD COLUMN timeofday VARCHAR(10);

UPDATE amazon
SET timeofday = CASE
    WHEN TIME(time) >= '06:00:01' AND TIME(time) < '12:00:00' THEN 'Morning'
    WHEN TIME(time) >= '12:00:01' AND TIME(time) < '16:00:00' THEN 'Afternoon'
    WHEN TIME(time) >= '16:00:01' AND TIME(time) < '20:00:00' THEN 'Evening'
    ELSE 'Night'
END;

ALTER TABLE amazon
ADD COLUMN dayname VARCHAR(10);

UPDATE amazon
SET dayname = DAYNAME(date);

ALTER TABLE amazon 
ADD COLUMN monthname VARCHAR(20);

UPDATE amazon SET monthname = MONTHNAME(date);

select * from amazon;

SELECT COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_name = 'amazon';

-- 1. What is the count of distinct cities in the dataset?
SELECT COUNT(DISTINCT city) AS distinct_city_count FROM amazon;

-- 2. For each branch, what is the corresponding city?
SELECT DISTINCT branch, city FROM amazon;

-- 3. What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT product_line) AS unique_product_lines FROM amazon;

-- 4. Which payment method occurs most frequently?
SELECT payment_method, COUNT(payment_method) AS frequency
FROM amazon
GROUP BY payment_method
ORDER BY frequency DESC
LIMIT 1;

-- 5. Which product line has the highest sales?
SELECT product_line, SUM(total_revenue) AS total_sales
FROM amazon
GROUP BY product_line
ORDER BY total_sales DESC
LIMIT 1;

-- 6. How much revenue is generated each month?
SELECT monthname, SUM(total_revenue) AS monthly_revenue
FROM amazon
GROUP BY monthname
ORDER BY monthly_revenue DESC;

-- 7. In which month did the cost of goods sold reach its peak?
SELECT monthname, SUM(cogs) AS total_cogs
FROM amazon
GROUP BY monthname
ORDER BY total_cogs DESC
LIMIT 1;

-- 8. Which product line generated the highest revenue?
SELECT product_line, SUM(gross_income) AS highest_revenue
FROM amazon
GROUP BY product_line
ORDER BY highest_revenue DESC
LIMIT 1;

-- 9. In which city was the highest revenue recorded?
SELECT city, MAX(total_revenue) AS city_max_revenue
FROM amazon
GROUP BY city
ORDER BY city_max_revenue DESC
LIMIT 1;

-- 10. Which product line incurred the highest Value Added Tax (VAT) ?
SELECT product_line, SUM(VAT) AS total_vat
FROM amazon
GROUP BY product_line
ORDER BY total_vat DESC
LIMIT 1;

-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT
  product_line,
  SUM(total_revenue) AS total_sales,
  CASE
    WHEN SUM(total_revenue) > (SELECT AVG(sum_revenue)
                               FROM (SELECT product_line, SUM(total_revenue) AS sum_revenue
                                     FROM amazon
                                     GROUP BY product_line) AS avg_sales)
    THEN 'Good'
    ELSE 'Bad'
  END AS sales_performance
FROM amazon
GROUP BY product_line;

-- 12. Identify the branch that exceeded the average number of products sold.
SELECT
  branch,
  SUM(quantity) AS total_products_sold,
  CASE
    WHEN SUM(quantity) > (SELECT AVG(sum_quantity)
                          FROM (SELECT branch, SUM(quantity) AS sum_quantity
                                FROM amazon
                                GROUP BY branch) AS avg_products)
    THEN 'Exceeded Average'
    ELSE 'Below Average'
  END AS performance
FROM amazon
GROUP BY branch;

-- 13. Which product line is most frequently associated with each gender?
SELECT
  gender,
  (SELECT product_line
   FROM amazon
   WHERE gender = t.gender
   GROUP BY product_line
   ORDER BY COUNT(*) DESC
   LIMIT 1) AS most_frequent_product_line
FROM
  (SELECT DISTINCT gender FROM amazon) t;
  
-- 14. Calculate the average rating for each product line.
SELECT
  product_line,
  AVG(rating) AS average_rating
FROM
  amazon
GROUP BY
  product_line;
  
-- 15. Count the sales occurrences for each time of day on every weekday.
SELECT
  dayname,
  timeofday,
  COUNT(*) AS sale_occurrences
FROM
  amazon
WHERE dayname IN ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday")
GROUP BY
  dayname, timeofday
ORDER BY
  timeofday;
  
-- 16. Identify the customer type contributing the highest revenue.
SELECT
  customer_type,
  SUM(total_revenue) AS total_revenue
FROM
  amazon
GROUP BY
  customer_type
ORDER BY
  total_revenue DESC
LIMIT 1;

-- 17. Determine the city with the highest VAT percentage.
SELECT
  city,
  SUM(VAT) / SUM(total_revenue) * 100 AS vat_percentage
FROM
  amazon
GROUP BY
  city
ORDER BY
  vat_percentage DESC
LIMIT 1;

-- 18. Identify the customer type with the highest VAT payments.
SELECT
  customer_type,
  SUM(VAT) AS total_vat_payments
FROM
  amazon
GROUP BY
  customer_type
ORDER BY
  total_vat_payments DESC
LIMIT 1;

-- 19. What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT customer_type) AS distinct_customer_types
FROM amazon
WHERE customer_type IS NOT NULL;

-- 20. What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT payment_method) AS distinct_payment_methods
FROM amazon
WHERE payment_method IS NOT NULL;

-- 21. Which customer type occurs most frequently?
SELECT 
    customer_type, COUNT(*) AS frequency
FROM
    amazon
GROUP BY customer_type
ORDER BY frequency DESC
LIMIT 1;

-- 22. Identify the customer type with the highest purchase frequency.
SELECT
  customer_type,
  COUNT(*) AS purchase_frequency
FROM
  amazon
GROUP BY
  customer_type
ORDER BY
  purchase_frequency DESC
LIMIT 1;

-- 23. Determine the predominant gender among customers.
SELECT
  gender,
  COUNT(*) AS gender_count
FROM
  amazon
GROUP BY
  gender
ORDER BY
  gender_count DESC
LIMIT 1;

-- 24. Examine the distribution of genders within each branch.
SELECT
  branch,
  gender,
  COUNT(*) AS gender_count
FROM
  amazon
GROUP BY
  branch, gender
ORDER BY
  branch, gender_count DESC;

-- 25. Identify the time of day when customers provide the most ratings.
SELECT
  timeofday,
  COUNT(*) AS rating_count
FROM
  amazon
WHERE
  rating IS NOT NULL
GROUP BY
  timeofday
ORDER BY
  rating_count DESC
LIMIT 1;

-- 26. Determine the time of day with the highest customer ratings for each branch.
SELECT
    branch,
    MAX(CASE 
        WHEN timeofday = 'Morning' THEN rating
        ELSE 0
    END) AS 'Morning_Max_Rating',
    MAX(CASE
        WHEN timeofday = 'Afternoon' THEN rating
        ELSE 0
    END) AS 'Afternoon_Max_Rating',
    MAX(CASE
        WHEN timeofday = 'Evening' THEN rating
        ELSE 0
    END) AS 'Evening_Max_Rating',
    MAX(CASE
        WHEN timeofday = 'Night' THEN rating
        ELSE 0
    END) AS 'Night_Max_Rating'
FROM
    amazon
GROUP BY
    branch;
    
-- 27. Identify the day of the week with the highest average ratings.
SELECT dayname, AVG(rating) AS avg_rating
FROM amazon
GROUP BY dayname
ORDER BY avg_rating DESC
LIMIT 1;

-- 28. Determine the day of the week with the highest average ratings for each branch.
SELECT branch, dayname, AVG(rating) AS average_rating
FROM amazon
GROUP BY branch, dayname
ORDER BY branch, average_rating DESC;
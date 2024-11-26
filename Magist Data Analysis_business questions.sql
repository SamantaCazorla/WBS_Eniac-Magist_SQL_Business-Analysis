/*****
 Analysis of Magist Database
 1. In relation to the products:
 2. In relation to the sellers:
 3. In relation to the delivery time:
*****/
USE magist;

/*****
In relation to the sellers:
*****/

-- 1. What categories of tech products does Magist have?
		-- e.g.
		-- "audio", 
		-- "computers", 
		-- "computers_accessories", 
		-- "consoles_games",
		-- "electronics",
		-- "pc_gamer", 
		-- "tablets_printing_image", 
		-- "telephony";

-- 2a. How many products of these tech categories have been sold (within the time window of the database snapshot)? 
select COUNT(DISTINCT(oi.product_id)) AS tech_products_sold
from order_items oi
LEFT JOIN products p 
	USING (product_id)
LEFT JOIN product_category_name_translation pt
	USING (product_category_name)
WHERE product_category_name_english = "audio"
	OR product_category_name_english =  "computers"
	OR product_category_name_english =  "computers_accessories"
	OR product_category_name_english =  "consoles_games"
	OR product_category_name_english =  "pc_gamer"
	OR product_category_name_english =  "electronics"
	OR product_category_name_english =  "tablets_printing_image"
	OR product_category_name_english =  "telephony";

-- ANSWER: 3707 Tech products.


-- 2b. What percentage does that represent from the overall number of products sold?
select COUNT(DISTINCT(product_id)) AS products_sold
from order_items;
	-- 32951 Total product sold
SELECT 3707 / 32951; 

-- ANSWER: 0.1125, therefore 11% of magist products are tech products.


-- 3. What’s the average price of the products being sold?
SELECT ROUND(AVG(price), 2)
FROM order_items;

-- ANSWER: The average price of products being sold is €120.65.


-- 4. Are expensive tech products popular? 
select COUNT(oi.product_id), 
	CASE 
		WHEN price > 1000 THEN "Expensive"
		WHEN price > 100 THEN "Mid-range"
		ELSE "Cheap"
	END AS "price_range"
from order_items oi
LEFT JOIN products p
	ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation pt
	USING (product_category_name)
WHERE pt.product_category_name_english IN ("audio", "computers", "computers_accessories", "consoles_games", "electronics", "pc_gamer", "tablets_printing_image", "telephony")
GROUP BY price_range
ORDER BY 1 DESC;

-- There are the following number of products sold:
	-- 12151 cheap products (which represents only a 72 % of the total number of products (16935))
    -- 4596 mid-range products (which represents only a 27 % of the total number of products (16935))
    -- 188 expensive products (which represents only a 1 % of the total number of products (16935))
SELECT 188 / 16935; 

-- ANSWER: expensive tech products represent only 1% of the sales.


/*****
In relation to the sellers:
*****/

-- 4. How many months of data are included in the magist database?
select 
    TIMESTAMPDIFF(MONTH,
        MIN(order_purchase_timestamp),
        MAX(order_purchase_timestamp))
from orders;
    
-- ANSWER: 25 months.
    
    
-- 5a. How many sellers are there?
select COUNT(DISTINCT seller_id)
from sellers;

-- ANSWER: 3095 sellers.
    
-- 5b. How many Tech sellers are there? 
select COUNT(DISTINCT seller_id)
from sellers
LEFT JOIN order_items 
	USING (seller_id)
LEFT JOIN products p 
	USING (product_id)
LEFT JOIN product_category_name_translation pt 
	USING (product_category_name)
WHERE pt.product_category_name_english 
	IN ('audio', 'computers', 'computers_accessories', 'consoles_games', 'electronics', 'pc_gamer', 'tablets_printing_image', 'telephony');

-- ANSWER: 477 tech sellers

-- 5c. What percentage of overall sellers are Tech sellers?
SELECT (477 / 3095) * 100;

-- ANSWER: 15.41 % of sellers are specialized on tech products.
   
   
-- 6a. What is the total amount earned by all sellers?
   -- used price from order_items and not payment_value from order_payments as an order may contain tech and non tech product. 
select SUM(oi.price) AS total
from order_items oi
LEFT JOIN orders o 
	USING (order_id)
WHERE o.order_status 
	NOT IN ('unavailable' , 'canceled');

-- ANSWER: Total amount earned by all sellers is €13494400.74
    
	-- the average monthly income of all sellers?
SELECT 13494400.74/ 3095 / 25;

-- ANSWER: Average amount of tech sellers income is €174.40 per month.


-- 6b. What is the total amount earned by all Tech sellers?
select SUM(oi.price) AS total
FROM order_items oi
LEFT JOIN orders o 
	USING (order_id)
LEFT JOIN products p 
	USING (product_id)
LEFT JOIN product_category_name_translation pt 
	USING (product_category_name)
WHERE o.order_status 
	NOT IN ('unavailable' , 'canceled')
AND pt.product_category_name_english 
	IN ('audio', 'computers', 'computers_accessories', 'consoles_games', 'electronics', 'pc_gamer', 'tablets_printing_image', 'telephony');

-- ANSWER: Total amount earned by all Tech sellers is €1821138.56
   
   
-- 7. What is the average monthly income of Tech sellers?
SELECT 1821138.56 / 477 / 25;

-- ANSWER: Average amount of tech sellers income is €152.72 per month.


/*****
In relation to the delivery time:
*****/

-- 8. What’s the average time between the order being placed and the product being delivered?
select 
	AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp))
from orders;

-- ANSWER: delivery time of 12.5035 days on average.


-- 9. How many orders are delivered on time vs orders delivered with a delay?
select 
    CASE 
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) > 0 THEN 'Delayed' 
        ELSE 'On time'
    END AS delivery_status, 
COUNT(DISTINCT order_id) AS orders_count
from orders 
WHERE order_status = 'delivered'
AND order_estimated_delivery_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

-- ANSWER:  7999 products on time  vs  88471 products delayed


-- 10. Is there any pattern for delayed orders, e.g. big products being delayed more often?
select
    CASE 
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) >= 100 THEN "> 100 day Delay"
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) >= 7 AND DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) < 100 THEN "1 week to 100 day delay"
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) > 3 AND DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) < 7 THEN "4-7 day delay"
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) >= 1  AND DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) <= 3 THEN "1-3 day delay"
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) > 0  AND DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) < 1 THEN "less than 1 day delay"
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) <= 0 THEN 'On time' 
    END AS "delay_range", 
    AVG(product_weight_g) AS weight_avg,
    MAX(product_weight_g) AS max_weight,
    MIN(product_weight_g) AS min_weight,
    SUM(product_weight_g) AS sum_weight,
    COUNT(DISTINCT a.order_id) AS orders_count
from orders a
LEFT JOIN order_items b
    USING (order_id)
LEFT JOIN products c
    USING (product_id)
WHERE order_estimated_delivery_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
AND order_status = 'delivered'
GROUP BY delay_range;

# total orders: 96470
select (5 / 96470) *100;      -- 0.01 % of the products has >100 days delay
select (75660 / 96470) *100;  -- 78.5 % of the products has 1 week to 100 days delay
select (8076 / 96470) *100;   -- 8.4 % of the products has 4-7 days delay
select (4730 / 96470) *100;   -- 4,9 % of the products has 1-3 days delay
select (7999 / 96470) *100;   -- 8,3 % of the products are on time

-- ANSWER:  The highest amount of products are delayed more than a week. Theseones are not the heaviest. 
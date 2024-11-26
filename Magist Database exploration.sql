/*****
 Exploratory of Magist Database
*****/

USE magist;

-- 1. How many orders are there in the dataset?  
select count(*) 
from orders;

-- ANSWER: There are 99441 orders.


-- 2. Are orders actually delivered, cancelled or unavailable?    
select order_status, 
	FORMAT(count(*),0) AS No_of_orders
from orders
group by order_status
order by count(order_id) desc;

-- ANSWER: we provide a table with all the orders delivered, shipped, cancelled and other status.


-- 3. Is Magist having user growth?  
select 
    YEAR(order_purchase_timestamp) AS `Year`,
    MONTH(order_purchase_timestamp) AS `Month`,
    COUNT(order_id)
from orders
GROUP BY `Year`, `Month`
ORDER BY `Year`, `Month`;

-- ANSWER: Yes, there is an increase on orders, with the exception of the last two months. 
--         In a real case we would ask Magist for a possible reason, but in this case we know that it is due to uncompleted data, so we will ignore these two months.
-- 	To filter these data:
select 
    YEAR(order_purchase_timestamp) AS `Year`,
    MONTH(order_purchase_timestamp) AS `Month`,
    COUNT(order_id)
from orders
GROUP BY `Year`, `Month`
HAVING `Year` > 2016 AND NOT(`Year` = 2018 AND `Month` >= 9)
ORDER BY `Year`, `Month`;


-- 4. How many products are there on the products table? (make sure that there are no duplicate products) 
select 
	count(DISTINCT product_id) AS num_products
FROM products;

-- ANSWER: There are 32951 products.


-- 5. Which are the categories with the most products? 
select 
	p.product_category_name, 
	p_c_n.product_category_name_english, 
    COUNT(p.product_id)
from products AS p
LEFT JOIN product_category_name_translation AS p_c_n   -- to have english names
-- ON p.product_category_name = p_c_n.product_category_name
USING (product_category_name)  -- because we have the same column name
GROUP BY p.product_category_name
ORDER BY COUNT(p.product_id) DESC
LIMIT 5;

-- ANSWER: the five most sold categories are: bed bath table, sports leisure, furniture decor, health beauty, and housewares.


-- 6. How many of those products were present in actual transactions (actually sold)? The products table is a “reference” of all the available products. Have all these products been involved in orders? 
select 
	count(DISTINCT product_id) AS n_products
from order_items;

-- ANSWER: 32951 items solds


-- 7. What’s the price for the most expensive and cheapest products? 
select 
	max(price) AS Maximum_price, 
    min(price) AS Minimum_price
from order_items;

-- ANSWER: 0.85 for the cheapeast and 6735 for the most expensive

-- The simplest way to find the most expensive and the cheapeast product name (without subqueries):
	# The most expensive item:
select product_id, price
from products
RIGHT JOIN order_items
USING (product_id)
ORDER BY price DESC
LIMIT 1;
	
	# The cheapest item:
select product_id, price
from products
RIGHT JOIN order_items
USING (product_id)
ORDER BY price ASC
LIMIT 1;


-- 8. What are the highest and lowest order payment values? (What’s the highest someone has paid for an order? Look at the order_payments table)
select
	MAX(payment_value) AS max_value,
    MIN(payment_value) AS min_value
from order_payments;

-- ANSWER: the lower payment was 0 and the highest payement was 13664.1

# the maxium someone has paid for an order is 13664.1:
select order_id, payment_value
from order_payments
ORDER BY payment_value DESC
LIMIT 1;

# the minium someone has paid for an order is 0.01:
SELECT order_id, payment_value
FROM order_payments
WHERE payment_value > 0
ORDER BY payment_value
LIMIT 1;
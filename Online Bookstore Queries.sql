--BUSINESS QUESTIONS AND QUERIES

--What is the total revenue generated in the past month?
SELECT 
	SUM(total_amount) AS total_revenue
FROM orders
WHERE order_date >= (SELECT MAX(order_date) - INTERVAL'1 month'
					 FROM orders);


--What are the top 10 best-selling books based on total sales?
	SELECT
		b.book_name AS books,
		SUM(oi.quantity) AS total_sales,
		SUM(oi.quantity * oi.sale_price) AS total_amount
FROM order_items AS oi
LEFT JOIN books AS b
ON oi.product_id = b.book_id
GROUP BY b.book_name
ORDER BY total_sales DESC
LIMIT 10;

--What is the average order value per customer?
SELECT 
	CONCAT(c.first_name, '  ', c.last_name) AS customer_name,
	ROUND(AVG(o.total_amount),2) AS average_order_value
FROM orders as o
LEFT JOIN customers AS c
USING(customer_id)
GROUP BY customer_name
ORDER BY average_order_value DESC;

--What is the average order value per customer(including customers without orders) ?
SELECT 
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	ROUND(COALESCE(AVG(o.total_amount),0),2) AS average_order_value
FROM customers as c
LEFT JOIN orders AS o
USING(customer_id)
GROUP BY c.customer_id
ORDER BY average_order_value DESC;


--How does the revenue trend over time (daily)?
	SELECT 
		DATE(o.order_date) AS order_day,
		SUM(oi.quantity * oi.sale_price) AS daily_revenue
FROM order_items as oi
LEFT JOIN orders as o
USING(order_id)
GROUP BY order_day
ORDER BY order_day ASC;

--How does the revenue trend over time (monthly)?
SELECT 
		DATE(DATE_TRUNC('month', o.order_date)) AS order_month,
		SUM(oi.quantity * oi.sale_price) AS monthly_revenue
FROM order_items as oi
LEFT JOIN orders as o
USING(order_id)
GROUP BY order_month
ORDER BY order_month ASC;

--How does the revenue trend over time (yearly)?
SELECT 
		DATE(DATE_TRUNC('year', order_date)) AS order_year,
		SUM(quantity * sale_price) AS yearly_revenue
FROM order_items as oi
LEFT JOIN orders as o
USING(order_id)
GROUP BY order_year
ORDER BY order_year ASC;

--Calculate the 7-day moving average.
SELECT
	DATE(o.order_date) AS order_day,
	SUM(oi.quantity * oi.sale_price) AS daily_revenue,
	ROUND(AVG(SUM(oi.quantity * oi.sale_price)) 
OVER(ORDER BY DATE(o.order_date)ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS moving_average_7days
FROM order_items as oi
LEFT JOIN orders as o
USING(order_id)
GROUP BY order_day
ORDER BY order_day ASC;


--Which shipping center generates the highest sales?
SELECT 
	sc.center_name AS shipping_center,
	SUM(oi.quantity) AS total_sales
FROM order_items AS oi
LEFT JOIN shipping_centers AS sc
USING(center_id)
GROUP BY center_name
ORDER BY total_sales DESC;

--Who are the top 10 customers by total spending?
SELECT
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	SUM(o.total_amount) AS total_spent
FROM orders AS o
LEFT JOIN customers AS c
USING(customer_id)
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;

--How many unique customers have placed orders in the past 6 months?
SELECT
	COUNT(DISTINCT(order_id)) AS unique_customers
FROM orders
WHERE order_date >=
		(SELECT MAX(order_date) - INTERVAL '6 months'
		 FROM orders);


--What is the percentage of returning customers versus new customers?
	WITH customer_orders AS( 
SELECT 
		customer_id,
		COUNT(order_id) AS order_count
FROM orders
GROUP BY customer_id)

SELECT
		ROUND((COUNT(CASE WHEN order_count > 1 THEN END)*100.0/COUNT(*)),2)  AS returning_customer_percentage
FROM customer_orders;

--What is the most common genre purchased by customers?
	SELECT 
		b.genre AS book_genre,
		SUM(oi. quantity) AS total_sale
FROM order_items AS oi
LEFT JOIN books AS b
ON oi.product_id = b.book_id
GROUP BY b.genre
ORDER BY total_sale DESC;

--In which month did the highest number of purchases occur?
SELECT
	DATE(DATE_TRUNC('month', order_date)) AS order_month,
	COUNT(order_id) AS purchase_count
FROM orders
GROUP BY order_month
ORDER BY purchase_count DESC;

--Which books are running low on stock?
SELECT
	b.book_name,
	SUM(i.stock_quantity) AS stock
FROM inventory as i
LEFT JOIN books as b
ON i.product_id = b.book_id
GROUP BY b.book_name
ORDER BY stock ASC;

--What is the total stock value of all books in inventory?
	SELECT
		SUM(i.stock_quantity * b.cost) AS total_inventory_value
FROM inventory AS i
LEFT JOIN books AS b
ON i.product_id = b.book_id;

--How many units of each book have been ordered, and what is the latest available stock for each book?
	SELECT 
   		 b.book_name,
   		 SUM(oi.quantity) AS order_quantity,
    		i.stock_quantity AS latest_stock_quantity
FROM order_items AS oi
LEFT JOIN orders AS o USING(order_id)
LEFT JOIN books AS b ON oi.product_id = b.book_id
LEFT JOIN inventory AS i 
    	ON b.book_id = i.product_id 
    	AND i.last_updated = (SELECT MAX(last_updated) 
        				FROM inventory i2 
       				WHERE i2.product_id = i.product_id )
GROUP BY b.book_name, i.stock_quantity
ORDER BY order_quantity ASC;

--Orders that cannot be fulfilled due to insufficient stock
	SELECT 
		b.book_name AS book,
		oi.order_id,
		oi.quantity AS order_quantity,
		i.stock_quantity AS stock_quantity
FROM order_items AS oi
LEFT JOIN inventory AS i
USING(product_id)
LEFT JOIN books as b
ON oi.product_id = b.book_id
WHERE oi.quantity > i.stock_quantity;
	
--Which shipping center processes the most orders?
SELECT 
	sc.center_name AS shipping_center,
	COUNT(o.order_id) AS order_count
FROM orders as o
LEFT JOIN shipping_centers as sc
USING(center_id)
GROUP BY sc.center_name
ORDER BY order_count DESC
LIMIT 1;

--What percentage of orders are canceled?
SELECT 
	ROUND((COUNT(CASE WHEN status = ('Cancelled') THEN 1 END )*100.0/ COUNT(*)),2) AS cancel_percent
FROM orders

What are the most common destinations for book shipments?
	SELECT
		sc.center_name AS shipping_center,
		sc.location,
		COUNT(o.order_id) AS order_count
FROM orders as o
LEFT JOIN shipping_centers as sc
USING(center_id)
WHERE o.status IN ('Shipped', 'Completed')
GROUP BY sc.center_name, sc.location
ORDER BY order_count DESC
LIMIT 1;













	





	









































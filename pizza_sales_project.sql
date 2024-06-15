
      /*    -------- Basic Questions ------- */

/* 1)  List all the unique pizza types available */
SELECT DISTINCT(name) AS distinct_pizza 
FROM pizza_types;

/* 2) Retrieve the names and prices of all pizzas. */
SELECT pizza_types.name ,pizzas.price
FROM pizza_types
INNER JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id ; 

/* 3) List all the Distinct catogories in pizza */ 
SELECT DISTINCT(category) FROM pizza_types;

/* 4) Retrieve the total number of orders placed. */
SELECT COUNT(*) FROM orders;

/* 5) Calculate the total revenue generated from pizza sales.*/
SELECT SUM(order_details.quantity * pizzas.price) AS revenue
FROM order_details
INNER JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id 
order by revenue  ;

/* 6) Identify the highest-priced pizza. */
SELECT pizza_types.name ,pizzas.price
FROM pizza_types
INNER JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC 
LIMIT 1;

/* 7) Identify the most common pizza size ordered.*/
SELECT pizzas.size ,COUNT(order_details.order_details_id) AS order_count
FROM pizzas
INNER JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY  pizzas.size
ORDER BY order_count DESC ;

/* 8) List all ingredients for a specific pizza type, say 'The Greek Pizza'. */
SELECT name FROM pizza_types
WHERE name = 'The Greek Pizza';

/* 9) Determine the distribution of orders by hour of the day. */
SELECT HOUR(order_time) AS hour ,COUNT(order_id) AS order_count
FROM orders
GROUP BY hour
ORDER BY order_count ;

/* 10) Find the total number of orders placed on weekends. */
SELECT COUNT(*) FROM orders
WHERE DAYOFWEEK(order_date) IN (1, 7);

		
        /* ----------- Intermediate Questions ----------- */

/* 11) Join the necessary tables to find the total quantity of each pizza category ordered.*/
SELECT pizza_types.category , SUM(order_details.quantity) AS quantity 
FROM pizza_types
INNER JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
INNER JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category 
ORDER BY quantity DESC ;

/* 12) Join relevant tables to find the category-wise distribution of pizzas. */
SELECT category ,COUNT(name) pizza_count FROM pizza_types
GROUP BY category;

/* 13) List the top 5 most ordered pizza types along with their quantities. */
SELECT pizza_types.name ,SUM(order_details.quantity) AS quantity 
FROM pizza_types
INNER JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
INNER JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5 ;

/* 14) Find the total number of pizzas sold for each pizza type */
SELECT pizza_types.name , SUM(order_details.quantity) AS total_quantity_sold
FROM pizza_types
INNER JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
INNER JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity_sold ;

/* 15) Group the orders by date and calculate the average number of pizzas ordered per day. */
SELECT ROUND(AVG(order_details.quantity),0) avg_pizza_ordered_per_day
FROM (SELECT orders.order_date , SUM(order_details.quantity ) AS quantity
	 FROM orders
	 INNER JOIN order_details ON orders.order_id = order_details.order_id
	 GROUP BY orders.order_date) AS order_quantity;
      
/* 16) Determine the top 3 most ordered pizza types based on revenue. */
SELECT pizza_types.name ,SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
INNER JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
INNER JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC

/* 17) Find the average price of pizzas sold in the 'Classic' category */
SELECT pizza_types.category ,ROUND(AVG(order_details.quantity * pizzas.price),2) AS avg_price
FROM pizza_types 
INNER JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
INNER JOIN order_details ON pizzas.pizza_id = order_details.pizza_id 
WHERE pizza_types.category = 'Classic'
GROUP BY pizza_types.category 
ORDER BY avg_price ; 

/* 18) which day of the week has the highest number of pizzas ordered . */
SELECT DAYNAME(orders.order_date) AS day_of_week, SUM(order_details.quantity) AS total_pizzas_ordered
FROM orders 
JOIN order_details  ON orders.order_id = order_details.order_id
GROUP BY DAYNAME(orders.order_date)
ORDER BY total_pizzas_ordered DESC
LIMIT 1;

    
    /* --------------Advance Questions ------------- */

/* 19) Calculate the percentage contribution of each pizza type to total revenue. */
WITH total_sales AS (
    SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total
    FROM order_details
    INNER JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
)
SELECT pizza_types.category,
CONCAT(ROUND((SUM(order_details.quantity * pizzas.price) / total_sales.total) * 100, 2), '%') AS revenue_percentage
FROM pizza_types
INNER JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
INNER JOIN order_details ON pizzas.pizza_id = order_details.pizza_id,total_sales
GROUP BY pizza_types.category, total_sales.total
ORDER BY revenue_percentage DESC ;

/* 20) Analyze the cumulative revenue generated over time. */
SELECT order_date ,
SUM(revenue) OVER(ORDER BY order_date) AS cumulative_revenue
FROM 
(SELECT orders.order_date ,SUM(order_details.quantity * pizzas.price) AS revenue
FROM orders
INNER JOIN order_details ON orders.order_id = order_details.order_id
INNER JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY orders.order_date) AS sales;

/* 21) Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/
SELECT category ,name ,revenue
FROM
(SELECT category ,name ,revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rnk
FROM
(SELECT pizza_types.category ,pizza_types.name ,SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types 
INNER JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
INNER JOIN order_details ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.category ,pizza_types.name) AS a) AS b
WHERE rnk <=3;

/* 22) List the top 5 days with the highest number of orders. */
SELECT order_date, COUNT(*) AS total_orders
FROM orders
GROUP BY order_date
ORDER BY total_orders DESC
LIMIT 5;

/* 23) Identify which pizza type has generated the highest revenue. */
SELECT pizza_types.name, SUM(order_details.quantity * pizzas.price) AS total_revenue
FROM pizza_types 
INNER JOIN pizzas  ON pizza_types.pizza_type_id = pizzas.pizza_type_id
INNER JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_revenue DESC
LIMIT 1;

/* 24) Identify the top 3 days with the highest revenue in 2015. */
SELECT DAYNAME(orders.order_date) AS day_name, SUM(order_details.quantity * pizzas.price) AS total_revenue
FROM orders
INNER JOIN order_details  ON orders.order_id = order_details.order_id
INNER JOIN pizzas  ON order_details.pizza_id = pizzas.pizza_id
INNER JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
WHERE YEAR(orders.order_date) = 2015
GROUP BY day_name
ORDER BY total_revenue DESC
LIMIT 3;


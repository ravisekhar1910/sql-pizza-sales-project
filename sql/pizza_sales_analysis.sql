-- BASIC ANALYSIS

-- Find the total number of orders placed

USE pizzahut;
SELECT COUNT(order_id) as total_orders
FROM orders;


-- Calculate the total revenue from pizza sales

SELECT ROUND(SUM(od.quantity * p.price), 2) as total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;


-- Identify the highest-priced pizza

SELECT p.pizza_id, pt.name, p.size, p.price
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
WHERE p.price = (SELECT MAX(price) FROM pizzas);


-- Determine the most frequently ordered pizza size

SELECT p.size, SUM(od.quantity) as total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC
LIMIT 1;


-- List the top 5 pizzas by order quantity

SELECT pt.name, SUM(od.quantity) as total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


-- INTERMEDIATE ANALYSIS

-- Calculate the total quantity ordered for each pizza category

SELECT pt.category, SUM(od.quantity) as total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;


-- Analyze the distribution of orders by hour of day

SELECT HOUR(time) as hour_of_day, COUNT(order_id) as order_count
FROM orders
GROUP BY HOUR(time)
ORDER BY hour_of_day;


-- Determine the order distribution of pizzas by category

SELECT category,
COUNT(NAME) AS distribution_of_pizza
FROM pizza_types
GROUP BY category;


-- Calculate the average number of pizzas ordered each day

SELECT ROUND(AVG(daily_quantity), 2) as avg_daily_pizzas
FROM (
    SELECT o.date, SUM(od.quantity) as daily_quantity
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.date
) as daily_totals;



-- Identify the top 3 pizzas based on revenue

SELECT pt.name, ROUND(SUM(od.quantity * p.price), 2) as revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;


-- ADVANCED ANALYSIS

-- Calculate each pizza type's percentage contribution to total revenue

SELECT pt.name,
       ROUND(SUM(od.quantity * p.price), 2) as revenue,
       ROUND((SUM(od.quantity * p.price) * 100.0 / 
             (SELECT SUM(od2.quantity * p2.price) 
              FROM order_details od2 
              JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id)), 2) as percentage_contribution
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC;


-- Track cumulative revenue growth over time

SELECT date,
       daily_revenue,
       SUM(daily_revenue) OVER (ORDER BY date) as cumulative_revenue
FROM (
    SELECT o.date,
           ROUND(SUM(od.quantity * p.price), 2) as daily_revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY o.date
    ORDER BY o.date
) as daily_revenue_table;


-- Determine the top 3 pizzas by revenue within each category

SELECT category, name, revenue, rank_in_category
FROM (
    SELECT pt.category,
           pt.name,
           ROUND(SUM(od.quantity * p.price), 2) as revenue,
           ROW_NUMBER() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) as rank_in_category
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) as ranked_pizzas
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;

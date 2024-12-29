-- 1. Creating Tables

-- Creating the orders table
CREATE TABLE orders (
	order_id INT PRIMARY KEY,
	date DATE NOT NULL,
	time TIME NOT NULL);

-- Creating the pizza_types table
CREATE TABLE pizza_types (
	pizza_type_id VARCHAR(50) PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	category VARCHAR(50),
	ingredients TEXT);

-- Creating the pizzas table
CREATE TABLE pizzas (
	pizza_id VARCHAR(50) PRIMARY KEY,
	pizza_type_id VARCHAR(50) REFERENCES pizza_types(pizza_type_id),
	size CHAR(1) CHECK (size IN ('S', 'M', 'L')),
	price NUMERIC(5, 2) NOT NULL);

-- Creating the order_details table
CREATE TABLE order_details (
	order_details_id INT PRIMARY KEY,
	order_id INT REFERENCES orders(order_id),
	pizza_id VARCHAR(50) REFERENCES pizzas(pizza_id),
	quantity INT CHECK (quantity > 0));

-- 2. Inserting Data

-- Inserting into orders
INSERT INTO orders (order_id, date, time)
VALUES
(1, '2015-01-01', '11:38:36'),
(2, '2015-01-01', '11:57:40'),
(3, '2015-01-01', '12:12:28');

-- Inserting into pizza_types
INSERT INTO pizza_types (pizza_type_id, name, category, ingredients)
VALUES
('bbq_ckn', 'The Barbecue Chicken Pizza', 'Chicken', 'Barbecued Chicken, Red Peppers, Green Peppers'),
('cali_ckn', 'The California Chicken Pizza', 'Chicken', 'Chicken, Artichoke, Spinach, Garlic, Jalapeno');

-- Inserting into pizzas
INSERT INTO pizzas (pizza_id, pizza_type_id, size, price)
VALUES
('bbq_ckn_s', 'bbq_ckn', 'S', 12.75),
('bbq_ckn_m', 'bbq_ckn', 'M', 16.75),
('cali_ckn_s', 'cali_ckn', 'S', 12.75);

-- Inserting into order_details
INSERT INTO order_details (order_details_id, order_id, pizza_id, quantity)
VALUES
(1, 1, 'bbq_ckn_s', 2),
(2, 2, 'cali_ckn_s', 1);

-- 3. Querying and Analysis

-- a. Which pizza type generates the highest revenue?
SELECT pizza_types.name AS pizza_name, SUM(order_details.quantity * pizzas.price) AS total_revenue
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY total_revenue DESC
LIMIT 1;

-- b. What are the top 5 most popular pizzas based on quantity sold?
SELECT pizzas.pizza_id, SUM(order_details.quantity) AS total_quantity
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.pizza_id
ORDER BY total_quantity DESC
LIMIT 5;

-- c. What is the total revenue earned for each day?
SELECT orders.date, SUM(order_details.quantity * pizzas.price) AS daily_revenue
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY orders.date
ORDER BY orders.date;

-- d. Which pizza category is most preferred by customers?
SELECT pizza_types.category, SUM(order_details.quantity) AS total_quantity
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC
LIMIT 1;

-- e. Rank the pizzas by total revenue generated.
SELECT pizzas.pizza_id, SUM(order_details.quantity * pizzas.price) AS total_revenue,
   	RANK() OVER (ORDER BY SUM(order_details.quantity * pizzas.price) DESC) AS revenue_rank
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.pizza_id;

-- f. Are there any incomplete records in the order details table?
SELECT *
FROM order_details
WHERE order_id IS NULL OR pizza_id IS NULL OR quantity IS NULL;

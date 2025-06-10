-- Creating a Database
create database if not exists Pizzahut;

-- Using the Database
use Pizzahut;

-- Creating a Orders table
create table Orders(
Order_Id int not null,
Order_Date date not null,
Order_Time time not null,
Primary key(Order_Id)
);

-- Creating a Orders_details table
create table Orders_details(
Order_Details_Id int not null,
Order_Id int not null,
Pizza_Id text not null,
Quantity int not null,
Primary key(Order_Details_Id)
);
-- First 10 rows of all tables
select * from orders;
select * from orders_details;
select * from pizzas;
select * from pizza_types;

-- 1.Retrieve the total number of orders placed.
SELECT COUNT(*) AS total_orders FROM Orders;

-- 2.Calculate the total revenue generated from pizza sales.
SELECT SUM(p.price * od.quantity) AS total_revenue
FROM Orders_Details od
JOIN Pizzas p ON od.pizza_id = p.pizza_id;

-- 3.Identify the highest-priced pizza.
SELECT * FROM Pizzas ORDER BY price DESC LIMIT 1;

-- 4.Identify the most common pizza size ordered.
SELECT p.size, COUNT(*) AS count
FROM Orders_Details od
JOIN Pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY count DESC
LIMIT 1;

-- 5.List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name, SUM(od.quantity) AS total_ordered
FROM Orders_Details od
JOIN Pizzas p ON od.pizza_id = p.pizza_id
JOIN Pizza_Types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_ordered DESC
LIMIT 5;

-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM Orders_Details od
JOIN Pizzas p ON od.pizza_id = p.pizza_id
JOIN Pizza_Types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- 7.Determine the distribution of orders by hour of the day.
SELECT EXTRACT(HOUR FROM Order_Time) AS order_hour, COUNT(*) AS total_orders
FROM Orders
GROUP BY order_hour
ORDER BY order_hour;

-- 8.Join relevant tables to find the category-wise distribution of pizzas.
SELECT pt.category, COUNT(DISTINCT p.pizza_id) AS total_pizzas
FROM Pizzas p
JOIN Pizza_Types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_pizzas DESC;

-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT Order_Date, AVG(daily_total) OVER () AS avg_pizzas_per_day
FROM (
  SELECT o.Order_Date, SUM(od.quantity) AS daily_total
  FROM Orders o
  JOIN Orders_Details od ON o.Order_Id = od.Order_Id
  GROUP BY o.Order_Date
) AS daily_totals;

-- 10.Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name, SUM(od.quantity * p.price) AS total_revenue
FROM Orders_Details od
JOIN Pizzas p ON od.pizza_id = p.pizza_id
JOIN Pizza_Types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- 11.Calculate the percentage contribution of each pizza type to total revenue.
WITH RevenuePerPizza AS (
  SELECT pt.name, SUM(od.quantity * p.price) AS revenue
  FROM Orders_Details od
  JOIN Pizzas p ON od.pizza_id = p.pizza_id
  JOIN Pizza_Types pt ON p.pizza_type_id = pt.pizza_type_id
  GROUP BY pt.name
),
TotalRevenue AS (
  SELECT SUM(revenue) AS total_revenue FROM RevenuePerPizza
)
SELECT rpp.name,
       rpp.revenue,
       ROUND((rpp.revenue / tr.total_revenue) * 100, 2) AS percentage_contribution
FROM RevenuePerPizza rpp, TotalRevenue tr
ORDER BY percentage_contribution DESC;

-- 12.Analyze the cumulative revenue generated over time.
SELECT o.Order_Date,
       SUM(od.quantity * p.price) AS daily_revenue,
       SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.Order_Date) AS cumulative_revenue
FROM Orders o
JOIN Orders_Details od ON o.Order_Id = od.Order_Id
JOIN Pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.Order_Date
ORDER BY o.Order_Date;

-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT r1.category, r1.name, r1.revenue
FROM (
    SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
    FROM Orders_Details od
    JOIN Pizzas p ON od.pizza_id = p.pizza_id
    JOIN Pizza_Types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) r1
WHERE (
    SELECT COUNT(*)
    FROM (
        SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
        FROM Orders_Details od
        JOIN Pizzas p ON od.pizza_id = p.pizza_id
        JOIN Pizza_Types pt ON p.pizza_type_id = pt.pizza_type_id
        GROUP BY pt.category, pt.name
    ) r2
    WHERE r2.category = r1.category AND r2.revenue > r1.revenue
) < 3
ORDER BY r1.category, r1.revenue DESC; 
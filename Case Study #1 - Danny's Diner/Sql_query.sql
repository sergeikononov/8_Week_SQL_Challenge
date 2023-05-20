--1.What is the total amount each customer spent at the restaurant?

SELECT
	customer_id AS customer,
	SUM(price) AS total_amount
FROM sales
JOIN menu USING(product_id)
GROUP BY customer_id
ORDER BY total_amount DESC

customer|total_amount|
--------+------------+
A       |          76|
B       |          74|
C       |          36|


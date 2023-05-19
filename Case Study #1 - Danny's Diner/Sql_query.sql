--1.What is the total amount each customer spent at the restaurant?

SELECT
	customer_id,
	SUM(price) AS total_amount
FROM sales
JOIN menu USING(product_id)
GROUP BY customer_id
ORDER BY total_amount DESC

1.What is the total amount each customer spent at the restaurant?

```
SELECT
	customer_id AS customer,
	SUM(price) AS total_amount
FROM sales
JOIN menu USING(product_id)
GROUP BY customer_id
ORDER BY total_amount DESC

```
| customer  | total_amount  |
|:----------|:----------|
|   A | 76 |
|   B | 74    |
| C | 36    |



2.How many days has each customer visited the restaurant?

```
SELECT
	customer_id AS customer,
	COUNT(DISTINCT order_date) AS amount_of_days
FROM sales
GROUP BY customer_id
ORDER BY amount_of_days DESC

```
| customer  | amount_of_days  |
|:----------|:----------|
|    B | 6 |
|   A | 4    |
| C | 2    |

3.What was the first item from the menu purchased by each customer?

```
WITH t1 AS
(
	SELECT 
		customer_id AS customer,
		product_name,
		ROW_NUMBER() OVER(
			PARTITION BY customer_id 
			ORDER BY order_date, product_id) AS rang
	FROM sales
	JOIN menu USING(product_id)
)

SELECT 
	customer,
	product_name
FROM t1
WHERE rang = 1

```
| customer  | product_name  |
|:----------|:----------|
|    A | sushi |
|   B | curry    |
| C | ramen    |

4. What is the most purchased item on the menu and 
how many times was it purchased by all customers?

```
WITH t1 AS 
(
SELECT 
	product_name, 
	COUNT(*) AS amount
FROM sales
JOIN menu USING(product_id)
GROUP BY product_name
)
SELECT 
	product_name,
	amount
FROM t1
WHERE amount = (SELECT MAX(amount) FROM t1)

```
| product_name  | amount  |
|:----------|:----------|
|    ramen | 8 |

5.Which item was the most popular for each customer?

```
WITH t1 AS
(
SELECT
	customer_id AS customer,
	product_name,
	RANK() OVER(
		PARTITION BY customer_id 
		ORDER BY COUNT(product_name) DESC) AS rang
FROM sales
JOIN menu USING(product_id)
GROUP BY customer, product_name
)
SELECT 
	customer,
	product_name
FROM t1
WHERE rang = 1

```
| customer | product_name |  
|----------|--------------|
| A        | ramen        |   
| B        | sushi        |   
| B        | curry        |   
| B        | ramen        |   
| C        | ramen  
6. Which item was purchased first by the customer after they became a member?
```
WITH t1 AS
(
SELECT 
	s.customer_id AS customer,
	product_name,
	RANK() OVER(
		PARTITION BY s.customer_id 
		ORDER BY order_date) AS rang
FROM sales AS s
JOIN members AS m 
	ON s.customer_id = m.customer_id AND
	   s.order_date >= m.join_date
JOIN menu AS me 
	ON s.product_id = me.product_id
)

SELECT 
	customer,
	product_name
FROM t1
WHERE rang =1

```
| customer | product_name |
|----------|--------------|
| A        | curry        |
| B        | sushi        |
7. Which item was purchased just before the customer became a member?

```
WITH t1 AS
(
SELECT 
	s.customer_id AS customer,
	product_name,
	RANK() OVER(
		PARTITION BY s.customer_id 
		ORDER BY order_date DESC) AS rang
FROM sales AS s
JOIN members AS m 
	ON s.customer_id = m.customer_id AND
	   s.order_date < m.join_date
JOIN menu AS me 
	ON s.product_id = me.product_id
)

SELECT 
	customer,
	product_name
FROM t1
WHERE rang =1

```
| customer | product_name |
|----------|--------------|
| A        | sushi        |
| A        | curry        |
| B        | sushi        |
8. What is the total items and amount spent for each member before they became a member?

```
SELECT 
	s.customer_id AS customer,
	COUNT(s.product_id),
	SUM(me.price)
FROM sales AS s
JOIN members AS m 
	ON s.customer_id = m.customer_id AND
	   s.order_date < m.join_date
JOIN menu AS me 
	ON s.product_id = me.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id

```
| customer | count | sum |
|----------|-------|-----|
| A        | 2     | 25  |
| B        | 3     | 40  |

9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
how many points would each customer have?

```
SELECT
	customer_id AS customer,
	SUM(
		CASE
			WHEN product_name = 'sushi' THEN price*20
			ELSE price*10
		END
	)
FROM sales
JOIN menu USING(product_id)
JOIN members USING(customer_id)
GROUP BY customer_id

```
| customer | sum |
|----------|-----|
| A        | 860 |
| B        | 940 |

10 In the first week after a customer joins the program 
(including their join date)they earn 2x points on all items, not just sushi 
how many points do customer A and B have at the end of January?

```
SELECT 
	s.customer_id AS customer,
	SUM(
		CASE
			WHEN s.order_date BETWEEN  
				m.join_date AND m.join_date + INTERVAL '6' DAY
				THEN price*20
			WHEN product_name = 'sushi' 
				THEN price*20
			ELSE price*10
		END
	)
FROM sales AS s
JOIN members AS m 
	ON s.customer_id = m.customer_id 
JOIN menu AS me 
	ON s.product_id = me.product_id
WHERE  order_date < '2021-02-01'
GROUP BY s.customer_id 
ORDER BY s.customer_id 

```
| customer | sum  |
|----------|------|
| A        | 1370 |
| B        | 820  |

11. Recreate the following tablе with a column 'membership'
('Y' for loyalty program members, 'N' - for others )

```
SELECT
	customer_id AS customer,
	order_date,
	product_name,
	price,
	CASE
		WHEN join_date IS NOT NULL THEN 'Y'
		ELSE 'N'
	END AS member
FROM sales
JOIN menu USING(product_id)
LEFT JOIN members USING(customer_id)

```
| customer | order_date | product_name | price | member |
|----------|------------|--------------|-------|--------|
| A        | 2021-01-07 | curry        | 15    | Y      |
| A        | 2021-01-11 | ramen        | 12    | Y      |
| A        | 2021-01-11 | ramen        | 12    | Y      |
| A        | 2021-01-10 | ramen        | 12    | Y      |
| A        | 2021-01-01 | sushi        | 10    | Y      |
| A        | 2021-01-01 | curry        | 15    | Y      |
| B        | 2021-01-04 | sushi        | 10    | Y      |
| B        | 2021-01-11 | sushi        | 10    | Y      |
| B        | 2021-01-01 | curry        | 15    | Y      |
| B        | 2021-01-02 | curry        | 15    | Y      |
| B        | 2021-01-16 | ramen        | 12    | Y      |
| B        | 2021-02-01 | ramen        | 12    | Y      |
| C        | 2021-01-01 | ramen        | 12    | N      |
| C        | 2021-01-01 | ramen        | 12    | N      |
| C        | 2021-01-07 | ramen        | 12    | N      |

12 Danny also requires further information about the ranking of customer products, 
but he purposely does not need the ranking for non-member purchases so he expects 
null ranking values for the records when customers are not yet part of the loyalty program.

```
WITH t1 AS
(
SELECT
	customer_id AS customer,
	order_date,
	product_name,
	price,
	CASE
		WHEN join_date IS NULL OR
			 order_date < join_date THEN 'N'
		ELSE 'Y'
	END AS member
FROM sales
JOIN menu USING(product_id)
LEFT JOIN members USING(customer_id)
ORDER BY customer, order_date
)

SELECT 
	*,
	CASE
		WHEN  member = 'Y' THEN 
		DENSE_RANK() OVER(
				PARTITION BY customer, member 
				ORDER BY order_date)
		ELSE NULL
	END AS ranking
FROM t1
```
| customer | order_date | product_name | price | member | ranking |
|----------|------------|--------------|-------|--------|---------|
| A        | 2021-01-01 | sushi        | 10    | N      | NULL    |
| A        | 2021-01-01 | curry        | 15    | N      | NULL    |
| A        | 2021-01-07 | curry        | 15    | Y      | 1       |
| A        | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A        | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A        | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B        | 2021-01-01 | curry        | 15    | N      | NULL    |
| B        | 2021-01-02 | curry        | 15    | N      | NULL    |
| B        | 2021-01-04 | sushi        | 10    | N      | NULL    |
| B        | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B        | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B        | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C        | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C        | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C        | 2021-01-07 | ramen        | 12    | N      | NULL    |

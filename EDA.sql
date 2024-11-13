--1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, sum(price) as totalprice
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY customer_id;

--2. How many days has each customer visited the restaurant?
SELECT customer_id, count(distinct(order_date)) as number_of_days
FROM sales
GROUP BY customer_id;

--3. What was the first item from the menu purchased by each customer?
WITH first_purchase AS
(SELECT product_id, product_name
FROM menu)
SELECT customer_id, product_name, min(order_date) AS first_order_date
FROM sales s
JOIN first_purchase f
ON s.product_id =f.product_id
GROUP BY customer_id,product_name
ORDER BY customer_id asc, min(order_date) asc;

--4. What is the most purchased item on the menu, and how many times was it purchased by all customers?
SELECT product_name, SUM(number_of_item) AS Total_no_sold
        FROM(
   SELECT count(product_name) as number_of_item, product_name, customer_id
   FROM sales s
   JOIN menu m
   ON s.product_id = m.product_id
   GROUP BY customer_id, m.product_id, product_name) items
GROUP BY product_name
ORDER BY total_no_sold DESC;

--5. What item was the most popular for each customer?
SELECT customer_id,product_name,count(product_name) as most_popular_item
FROM menu m
JOIN sales s
ON m.product_id =s.product_id
GROUP BY customer_id,product_name
ORDER BY customer_id desc, count(product_name) desc;

--6. What item was purchased first by customer after they became a member?
SELECT ms.customer_id,product_name,order_date,join_date
FROM menu m
JOIN sales s
ON m.product_id =s.product_id
JOIN members ms
ON ms.customer_id =s.customer_id
WHERE order_date >join_date;

--7. Which items was purchased just before the customer became a member?
SELECT ms.customer_id,product_name,order_date,join_date
FROM menu m
JOIN sales s
ON m.product_id =s.product_id
JOIN members ms
ON ms.customer_id = s.customer_id
WHERE order_date <join_date;

--8. What is the total item and amount spent by each customer before they became a member?
SELECT s.customer_id,count(product_name) as total_item, sum(price) as total_amount, order_date,join_date
FROM menu m
JOIN sales s
ON m.product_id =s.product_id
JOIN members ms
ON ms.customer_id =s.customer_id
WHERE order_date <join_date
GROUP BY s.customer_id,order_date,join_date;

--9. If $1 spent equates to 10 points, and sushi has 2x multiplier, how many points will each customer have?
SELECT customer_id,
        sum(CASE WHEN product_name ='sushi' THEN price *20 ELSE price *10 END) AS total_points
FROM sales s
JOIN menu m
ON s.product_id =m.product_id
GROUP BY customer_id;

--10. In the first week after a customer joins the program(including their join date), they earn 2x on all their items, not just sushi-how many points do customer A and B have by the end of January?
WITH first_week_order AS
    (SELECT ms.customer_id, order_date, join_date, SUM(price*20) AS total_points
    FROM menu m
    JOIN sales s
    ON m.product_id =s.product_id
    JOIN members ms
    ON ms.customer_id =s.customer_id 
    WHERE order_date BETWEEN '2021-01-07' AND '2021-01-14' OR order_date BETWEEN '2021-01-09' AND '2021-01-16'
    GROUP BY ms.customer_id,order_date,join_date)
SELECT fw.customer_id, fw.order_date,total_points
FROM first_week_order fw
LEFT JOIN (SELECT s.customer_id,s.order_date, SUM(price*10) AS Final_price
          FROM menu m
          JOIN sales s
    ON m.product_id = s.product_id
          JOIN members ms
    ON ms.customer_id =s.customer_id
    WHERE s.order_date BETWEEN '2021-01-14' AND '2021-01-31' AND s.order_date  BETWEEN '2021-01-16' AND '2021-01-31'
          GROUP BY s.customer_id,s.order_date) AS sub
ON fw.customer_id =sub.customer_id






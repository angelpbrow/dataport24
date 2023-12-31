/*Counting the number customers by country*/

SELECT country, COUNT(customerName) AS customers
  FROM customers
 GROUP BY country;
    
*How many orders placed by product line*

SELECT orderLineNumber, COUNT(quantityOrdered)
  FROM orderdetails
 GROUP BY orderLineNumber
    
*counting amount of distinct product lines*

SELECT DISTINCT productLine
  FROM products
 LIMIT 5;


*generating pragma table*

SELECT 'customers' table_name, COUNT(*) number_of_attributes,(
    SELECT COUNT(*)
      FROM customers)
        number_of_rows 
    FROM pragma_table_info('customers')

UNION ALL

SELECT 'products' table_name, COUNT(*) number_of_attributes,(
    SELECT COUNT(*)FROM products ) number_of_rows 
    FROM pragma_table_info('products')
    
UNION ALL

SELECT 'productlines' table_name, COUNT(*) number_of_attributes,(
    SELECT COUNT(*)
      FROM productlines ) number_of_rows 
   FROM pragma_table_info('productlines')
   
UNION ALL

SELECT 'orders' table_name, COUNT(*) number_of_attributes,(
    SELECT count(*)FROM orders ) number_of_rows 
     FROM pragma_table_info('orders')
     
UNION ALL

SELECT 'orderdetails' table_name, COUNT(*) number_of_attributes,(
    SELECT COUNT(*)
     FROM orderdetails ) number_of_rows 
   FROM pragma_table_info('orderdetails')
   
UNION ALL

SELECT 'payments' table_name, COUNT(*) number_of_attributes,(
    SELECT COUNT(*)
      FROM payments ) number_of_rows 
   FROM pragma_table_info('payments')
   
UNION ALL

SELECT 'employees' table_name, COUNT(*) number_of_attributes,(
    SELECT count(*)
     FROM employees ) number_of_rows 
   FROM pragma_table_info('employees')
                                                                                                                                  
UNION ALL

SELECT 'offices' table_name, COUNT(*) number_of_attributes,(
    SELECT count(*)
        FROM offices) number_of_rows 
   FROM pragma_table_info('offices');



*Question 1: Which Products Should We Order More of or Less of?*

WITH 
tab1 AS (
SELECT 
	p.productCode
FROM
	(
	SELECT
		p.productCode ,
		p.productName ,
		sum(o.quantityOrdered)/ p.quantityInStock as low_stock
	FROM
		products p
	JOIN orderdetails o ON
		p.productCode = o.productCode
	GROUP BY 
		p.productCode
	ORDER BY 
		low_stock DESC) p ),
tab2 AS (
SELECT 
	p.productCode
FROM
	(
	SELECT
		p.productCode ,p.productLine,
		p.productName,
		round(sum(o.quantityOrdered * o.priceEach),
		2) as product_performance
	FROM
		orderdetails o
	JOIN products p ON
		p.productCode = o.productCode
	GROUP BY 
		p.productCode
	ORDER BY 
		product_performance DESC
	LIMIT 10)p)
SELECT
	p.productCode, p.productName,p.productLine
FROM
	products p
WHERE
	p.productCode IN tab1
	AND p.productCode IN tab2;


*Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior?*

SELECT customerNumber, ROUND(SUM(quantityOrdered * (priceEach - buyPrice)),2) AS profit
FROM orders AS o
JOIN orderdetails AS d
ON o.orderNumber = d.orderNumber
JOIN products AS p
ON d.productCode = p.productCode
GROUP BY customerNumber
ORDER BY profit DESC;

*Finding the VIP and Less Engaged Customers*

*Top Five VIP customers*

WITH AS cust_profits (
SELECT o.customerNumber, ROUND(SUM(quantityOrdered * (priceEach - buyPrice)),2) AS profit
  FROM orders AS o
      JOIN orderdetails AS d
        ON o.orderNumber = d.orderNumber
      JOIN products AS p
        ON d.productCode = p.productCode
 GROUP BY customerNumber
 ORDER BY profit DESC
)


SELECT c.contactLastName ||' '|| c.contactFirstName, c.city, c.country, pr.profit
FROM customers AS c
JOIN cust_profits AS pr
ON pr.customerNumber = c.customerNumber
LIMIT 5;

*Five Least-engaged customers*

WITH AS cust_profits (
SELECT o.customerNumber, ROUND(SUM(quantityOrdered * (priceEach - buyPrice)),2) AS profit
FROM orders AS o
JOIN orderdetails AS d
ON o.orderNumber = d.orderNumber
JOIN products AS p
ON d.productCode = p.productCode
GROUP BY customerNumber
ORDER BY profit ASC
)

SELECT c.contactLastName ||' '|| c.contactFirstName, c.city, c.country, pr.profit
FROM customers AS c
JOIN cust_profits AS pr
ON pr.customerNumber = c.customerNumber
LIMIT 5;

*Question 3: How Much Can We Spend on Acquiring New Customers?*

/*To determine how much money we can spend acquiring new customers, we can compute the Customer Lifetime Value (LTV), 
which represents the average amount of money a customer generates. We can then determine how much we can spend on marketing.*/

*LTV of customers*
WITH cust_profits AS
(
SELECT o.customerNumber, ROUND(SUM(quantityOrdered * (priceEach - buyPrice)),2) AS profit
  FROM orders AS o
      JOIN orderdetails AS d
        ON o.orderNumber = d.orderNumber
      JOIN products AS p
        ON d.productCode = p.productCode
 GROUP BY customerNumber
 ORDER BY profit DESC
)

SELECT ROUND(AVG(profit),2) AS LTV
  FROM cust_profits;

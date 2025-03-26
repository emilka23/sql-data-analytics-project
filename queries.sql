-- Retrieve all rows from the dim_customers table
SELECT * FROM [gold.dim_customers];

-- Retrieve all rows from the dim_products table
SELECT * FROM [gold.dim_products];

-- Retrieve all rows from the fact_sales table
SELECT * FROM [gold.fact_sales];
-- Find the Total Sales
SELECT SUM(sales_amount) AS total_sales FROM [gold.fact_sales]
-- Find how many items are sold
SELECT SUM(quantity) AS total_quantity FROM [gold.fact_sales]

-- Find the average selling price
SELECT AVG(price) AS avg_price FROM [gold.fact_sales]

-- Find the Total number of Orders
SELECT COUNT(order_number) AS total_orders FROM [gold.fact_sales]
SELECT COUNT(DISTINCT order_number) AS total_orders FROM [gold.fact_sales]

-- Find the total number of products
SELECT COUNT(product_key) AS total_products FROM [gold.fact_sales]

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM [gold.fact_sales];

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM [gold.fact_sales];

-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM [gold.fact_sales]
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM [gold.fact_sales]
UNION ALL
SELECT 'Average Price', AVG(price) FROM [gold.fact_sales]
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM [gold.fact_sales]
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_key) FROM [gold.fact_sales]
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM [gold.fact_sales];

-- Find total products by category
SELECT
	category,
	count(product_key) AS total_products
FROM [gold.dim_products]
GROUP BY category
ORDER BY total_products DESC;

-- What is the average costs in each category?
SELECT 
	category,
	AVG(cost) as avg_cost
FROM [gold.dim_products]
GROUP BY category
ORDER BY avg_cost DESC;

-- What is the total revenue generated for each category?
SELECT 
	p.category,
	SUM(f.sales_amount) AS total_revenue
FROM [gold.fact_sales] f 
LEFT JOIN [gold.dim_products] p
	ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Which 5 products Generating the Highest Revenue?
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_products] P
	ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_products] p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue;

-- Analyse sales performance over time
-- Quick Date Functions
SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM 
    [gold.fact_sales]
WHERE 
    order_date IS NOT NULL
GROUP BY 
    YEAR(order_date), MONTH(order_date)
ORDER BY 
    YEAR(order_date), MONTH(order_date);

-- DATETRUNC()
SELECT 
    DATETRUNC(month, order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM 
    [gold.fact_sales]
WHERE 
    order_date IS NOT NULL
GROUP BY 
    DATETRUNC(month, order_date)
ORDER BY 
    DATETRUNC(month, order_date);

-- FORMAT()
-- NOTE: The format function returns a string, which may not sort correctly
SELECT 
    FORMAT(order_date, 'yyyy-MMM') AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM 
    [gold.fact_sales]
WHERE 
    order_date IS NOT NULL
GROUP BY 
    FORMAT(order_date, 'yyyy-MMM')
ORDER BY 
    FORMAT(order_date, 'yyyy-MMM');

-- Calculate total sales per month and the running total of sales over time
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_total_price
FROM (
    SELECT
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM 
        [gold.fact_sales]
    WHERE 
        order_date IS NOT NULL
    GROUP BY 
        DATETRUNC(year, order_date)
) t;

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year, 
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM 
        [gold.fact_sales] f
    LEFT JOIN 
        [gold.dim_products] p
    ON 
        f.product_key = p.product_key
    WHERE 
        f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date), p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'above avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'below avg'
        ELSE 'avg'
    END AS avg_change,
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'decrease'
        ELSE 'no change'
    END AS py_change
FROM 
    yearly_product_sales
ORDER BY 
    product_name, order_year;

-- Which categories contribute the most to overall sales?
WITH category_sales AS (
    SELECT 
        category,
        SUM(sales_amount) AS total_sales
    FROM 
        [gold.fact_sales] f
    LEFT JOIN 
        [gold.dim_products] p
    ON 
        p.product_key = f.product_key
    GROUP BY 
        category
)
SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM 
    category_sales
ORDER BY 
    total_sales DESC;

-- Segment products into cost ranges and count how many products fall into each segment
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'above 1000'
        END AS cost_range
    FROM 
        [gold.dim_products]
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM 
    product_segments
GROUP BY 
    cost_range
ORDER BY 
    total_products DESC;

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM 
        [gold.fact_sales] f
    LEFT JOIN 
        [gold.dim_customers] c
    ON 
        f.customer_key = c.customer_key
    GROUP BY 
        c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        total_spending,
        lifespan,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM 
        customer_spending
) t
GROUP BY 
    customer_segment
ORDER BY 
    COUNT(customer_key) DESC;

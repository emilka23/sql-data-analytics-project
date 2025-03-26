# SQL Data Analysis Project

## Project Description
This project contains a collection of SQL queries designed for data analysis in a data warehouse. These queries provide key metrics and reports related to sales, customers, and products. The data is stored in three tables:

- `gold.dim_customers` - customers table.
- `gold.dim_products` - products table.
- `gold.fact_sales` - sales table.

## Project Structure
The project includes the following SQL queries:

### 1. Basic Queries
- Retrieving all rows from the `dim_customers`, `dim_products`, and `fact_sales` tables.
- Calculating total sales, the number of products sold, the average sales price, and the number of orders.

### 2. Business Reports
- Generating summary reports with key business metrics such as total sales, the number of products, the number of customers, etc.
- Analyzing product categories (e.g., the number of products per category, the average cost per category).

### 3. Sales Analysis
- Identifying products generating the highest and lowest revenues.
- Analyzing sales performance over time (monthly, yearly).

### 4. Customer Reports
- Segmenting customers based on their purchase history (VIP, Regular, New).
- Calculating key indicators such as recency (time since last order), the number of orders, and total sales.

### 5. Advanced Data Analysis
- Calculating metrics related to product performance in various price ranges.
- Analyzing annual product performance, comparing sales to previous years and the average sales.


## Results
The query results can be used for:
- Identifying the best-performing and worst-performing products.
- Analyzing sales by category or customers.
- Generating reports for business stakeholders.

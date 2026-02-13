-- CUSTOMERS
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    region CHAR(7),
    customer_type CHAR(9)
);

-- PRODUCTS
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    sku_code VARCHAR(10) UNIQUE,
    category TEXT,
    brand TEXT,
    unit_cost DECIMAL(10,2),
    selling_price DECIMAL(10,2)
);

-- SUPPLIERS
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name TEXT,
    avg_lead_time_days INT
);

-- WAREHOUSES
CREATE TABLE warehouses (
    warehouse_id INT PRIMARY KEY,
    locations TEXT
);

-- INVENTORY
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY,
    product_id INT,
    warehouse_id INT,
    supplier_id INT,
    opening_stock INT,
    closing_stock INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- SALES
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity_sold INT NOT NULL,
    revenue DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

-- PURCHASE ORDERS
CREATE TABLE purchase_orders (
    po_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    supplier_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_qty INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- SALES RETURNS
CREATE TABLE sales_returns (
    return_id INT PRIMARY KEY,
    sale_id INT NOT NULL,
    return_reason TEXT,
    return_date DATE NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
);

-- Customers
COPY customers
FROM 'F:\Business Analytics\Projects\Inventory Optimization & Demand Analysis\Core Master Data\customers.csv'
DELIMITER ',' CSV HEADER;

-- Products
COPY products
FROM 'F:\Business Analytics\Projects\Inventory Optimization & Demand Analysis\Core Master Data\products.csv'
DELIMITER ',' CSV HEADER;

-- Suppliers
COPY suppliers
FROM 'F:\Business Analytics\Projects\Inventory Optimization & Demand Analysis\Core Master Data\suppliers.csv'
DELIMITER ',' CSV HEADER;

-- Warehouses
COPY warehouses
FROM 'F:\Business Analytics\Projects\Inventory Optimization & Demand Analysis\Core Master Data\warehouses.csv'
DELIMITER ',' CSV HEADER;

-- Inventory
COPY inventory
FROM 'F:\Business Analytics\Projects\Inventory Optimization & Demand Analysis\Transactional Data\inventory.csv'
DELIMITER ',' CSV HEADER;

-- Sales
COPY sales
FROM 'F:\Business Analytics\Projects\Inventory Optimization & Demand Analysis\Transactional Data\sales.csv'
DELIMITER ',' CSV HEADER;

-- Purchase Orders
COPY purchase_orders
FROM 'F:\Business Analytics\Projects\Inventory Optimization & Demand Analysis\Transactional Data\purchase_orders.csv'
DELIMITER ',' CSV HEADER;

-- Returns
COPY sales_returns
FROM 'F:\Business Analytics\Projects\Inventory Optimization & Demand Analysis\Transactional Data\returns.csv'
DELIMITER ',' CSV HEADER;


-- SALES CHECKS
SELECT COUNT(*) AS total_sales,
       COUNT(DISTINCT sale_id) AS unique_sales,
       COUNT(DISTINCT warehouse_id) AS warehouses_used
FROM sales;

SELECT * FROM sales WHERE quantity_sold < 1;
SELECT * FROM sales WHERE revenue <= 0;

-- PRODUCTS CHECK
SELECT * FROM products WHERE unit_cost <= 0 OR selling_price <= 0;

-- INVENTORY CHECK
SELECT * FROM inventory WHERE opening_stock < 0 OR closing_stock < 0;

SELECT product_id, warehouse_id, COUNT(*)
FROM inventory
GROUP BY product_id, warehouse_id
HAVING COUNT(*) > 1;

-- PURCHASE ORDER CHECK
SELECT * FROM purchase_orders WHERE order_qty <= 0;

-- RETURNS CHECK
SELECT * FROM sales_returns WHERE return_date > CURRENT_DATE;

-- CUSTOMER CHECK
SELECT * FROM customers WHERE region IS NULL OR customer_type IS NULL;

-- SUPPLIER CHECK
SELECT * FROM suppliers WHERE avg_lead_time_days <= 0;


-- Q1: Which products sell the most?
SELECT product_id,
       SUM(quantity_sold) AS total_quantity
FROM sales
GROUP BY product_id
ORDER BY total_quantity DESC;

-- Q2: Is demand seasonal?
SELECT TO_CHAR(sale_date, 'Mon') AS month,
       SUM(quantity_sold) AS total_demand
FROM sales
GROUP BY TO_CHAR(sale_date, 'Mon'), EXTRACT(MONTH FROM sale_date)
ORDER BY EXTRACT(MONTH FROM sale_date);

-- Q3: Stock analysis
SELECT inventory_id,
       product_id,
       opening_stock,
       closing_stock,
       (opening_stock - closing_stock) AS stock_used,
       (opening_stock + closing_stock)/2 AS avg_inventory
FROM inventory;

-- Zero / No movement stock
SELECT *
FROM inventory
WHERE (opening_stock - closing_stock) >= opening_stock;

-- Q4: Fast / Slow Moving Products
SELECT product_id,
       SUM(quantity_sold) AS demand,
       CASE
           WHEN SUM(quantity_sold) >= 400 THEN 'Fast Moving'
           WHEN SUM(quantity_sold) >= 200 THEN 'Medium Moving'
           ELSE 'Slow Moving'
       END AS sku_category
FROM sales
GROUP BY product_id
ORDER BY demand DESC;

-- Q5: Overstock vs Understock
SELECT i.product_id,
       i.closing_stock,
       d.total_demand,
       CASE
           WHEN i.closing_stock > d.total_demand * 3 THEN 'Overstock'
           WHEN i.closing_stock < d.total_demand * 0.5 THEN 'Understock'
           ELSE 'Optimal'
       END AS stock_status
FROM inventory i
JOIN (
    SELECT product_id, SUM(quantity_sold) AS total_demand
    FROM sales
    GROUP BY product_id
) d ON i.product_id = d.product_id;

-- Q6: Supplier delivery performance
SELECT supplier_name,
       avg_lead_time_days,
       CASE
           WHEN avg_lead_time_days <= 10 THEN 'Rapid'
           WHEN avg_lead_time_days <= 15 THEN 'Moderate'
           ELSE 'Late'
       END AS delivery_category
FROM suppliers
ORDER BY avg_lead_time_days;

-- Q7: Return reasons
SELECT return_reason,
       COUNT(*) AS total_returns
FROM sales_returns
GROUP BY return_reason
ORDER BY total_returns DESC;

-- Q8: Demand by customer type
SELECT c.customer_type,
       SUM(s.quantity_sold) AS total_quantity
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_type;

-- Q9: Best performing category
SELECT p.category,
       SUM(s.quantity_sold) AS quantity_sold,
       SUM(s.revenue) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY quantity_sold DESC;

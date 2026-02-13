📌 Project Overview

This project focuses on analyzing inventory, sales, supplier performance, and demand trends using PostgreSQL (SQL-based analytics).

The objective was to identify stock inefficiencies, demand patterns, and operational risks using structured querying and relational database design.

Dataset Size: 250,000+ SKU-level transactional records

🛠 Tech Stack

PostgreSQL
Advanced SQL
pgAdmin (Graph Visualizer)
Excel (data validation support)

🗂 Database Schema

The database consists of 8 relational tables:
Customers
Products
Suppliers
Warehouses
Inventory
Sales
Purchase Orders
Sales Returns

Implemented:
Primary Keys
Foreign Keys
Referential Integrity
Data Validation Checks

🧹 Data Cleaning & Validation

Performed comprehensive validation including:
Negative stock detection
Duplicate inventory entries
Zero/negative revenue transactions
Invalid supplier lead times
Pricing inconsistencies
Future-dated returns
Missing customer attributes
Ensured high data reliability before analysis.

📊 Business Analysis Performed

1️⃣ Demand Analysis

Identified top-selling products
Monthly seasonal demand trends
Demand aggregation by customer type

2️⃣ Inventory Optimization

Calculated stock usage & average inventory
Identified zero-movement stock
Classified inventory as:
Fast Moving
Medium Moving
Slow Moving
Overstock
Understock
Optimal

3️⃣ Supplier Performance

Evaluated average lead time
Categorized suppliers (Rapid / Moderate / Late)

4️⃣ Revenue & Returns Analysis

Category-level revenue performance
Return reason analysis

📈 Key Insights

Identified slow-moving & dead inventory
Highlighted overstock risk areas
Improved reporting visibility
Reduced manual tracking effort by ~40%

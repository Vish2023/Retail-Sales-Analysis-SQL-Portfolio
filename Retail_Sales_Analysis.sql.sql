-- =============================================
-- Retail Sales Performance Analysis | MySQL
-- 9 Advanced SQL Queries | Superstore Dataset
-- Portfolio Project #6
-- =============================================

USE RetailProject;

-- 1. Total Sales & Profit by Region
SELECT 
    Region,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM
    orders
GROUP BY Region
ORDER BY Total_Sales DESC;

-- 2. Total Sales by Product Category
SELECT 
    p.Category, ROUND(SUM(o.Sales), 2) AS Total_Sales
FROM
    products p
        JOIN
    orders o ON p.Product_ID = o.Product_ID
GROUP BY p.Category
ORDER BY Total_Sales DESC;

-- 3. Customers with Above-Average Sales per Order
SELECT 
    Customer_Name,
    ROUND(SUM(Sales) / COUNT(DISTINCT Order_ID), 2) AS Sales_Per_Order
FROM
    orders
GROUP BY Customer_Name
HAVING SUM(Sales) / COUNT(DISTINCT Order_ID) > (SELECT 
        SUM(Sales) / COUNT(DISTINCT Order_ID)
    FROM
        orders)
ORDER BY Sales_Per_Order DESC
LIMIT 10;

-- 4. Average Profit by Region & Segment
SELECT 
    Region, Segment, ROUND(AVG(Profit), 2) AS Avg_Profit
FROM
    orders
GROUP BY Region , Segment
ORDER BY Region , Avg_Profit DESC;

-- 5. Top 10 Products by Profit Margin %
SELECT 
    p.Product_Name,
    p.Category,
    ROUND(SUM(o.Profit) / SUM(o.Sales) * 100, 2) AS Profit_Margin_Pct
FROM
    products p
        JOIN
    orders o ON p.Product_ID = o.Product_ID
GROUP BY p.Product_ID , p.Product_Name , p.Category
ORDER BY Profit_Margin_Pct DESC
LIMIT 10;

-- 6. Loss-Making Sub-Categories with High Discount (>30%)
SELECT 
    p.Sub_Category,
    ROUND(AVG(o.Discount), 2) AS Avg_Discount,
    ROUND(SUM(o.Profit), 2) AS Total_Profit
FROM
    products p
        JOIN
    orders o ON p.Product_ID = o.Product_ID
GROUP BY p.Sub_Category
HAVING AVG(o.Discount) > 0.30
    AND SUM(o.Profit) < 0
ORDER BY Total_Profit ASC;

-- 7. Year-over-Year Sales Growth by Category (2014–2017)
SELECT 
    p.Category,
    ROUND(SUM(CASE
                WHEN SUBSTRING(o.Order_ID, 4, 4) = '2016' THEN o.Sales
                ELSE 0
            END),
            2) AS Sales_2016,
    ROUND(SUM(CASE
                WHEN SUBSTRING(o.Order_ID, 4, 4) = '2017' THEN o.Sales
                ELSE 0
            END),
            2) AS Sales_2017,
    ROUND(SUM(CASE
                WHEN SUBSTRING(o.Order_ID, 4, 4) = '2017' THEN o.Sales
                ELSE 0
            END) - SUM(CASE
                WHEN SUBSTRING(o.Order_ID, 4, 4) = '2016' THEN o.Sales
                ELSE 0
            END),
            2) AS Growth,
    ROUND(100.0 * (SUM(CASE
                WHEN SUBSTRING(o.Order_ID, 4, 4) = '2017' THEN o.Sales
                ELSE 0
            END) - SUM(CASE
                WHEN SUBSTRING(o.Order_ID, 4, 4) = '2016' THEN o.Sales
                ELSE 0
            END)) / NULLIF(SUM(CASE
                        WHEN SUBSTRING(o.Order_ID, 4, 4) = '2016' THEN o.Sales
                        ELSE 0
                    END),
                    0),
            1) AS Pct_Growth
FROM
    products p
        JOIN
    orders o ON p.Product_ID = o.Product_ID
GROUP BY p.Category
ORDER BY Pct_Growth DESC;

-- 8. Rank Sub-Categories by Profit within Each Region (Window Function)

SELECT 
    o.Region,
    p.Sub_Category,
    ROUND(SUM(o.Profit), 2) AS Total_Profit,
    RANK() OVER (PARTITION BY o.Region ORDER BY SUM(o.Profit) DESC) AS Profit_Rank_In_Region
FROM orders o
JOIN products p ON o.Product_ID = p.Product_ID
GROUP BY o.Region, p.Sub_Category
ORDER BY o.Region, Profit_Rank_In_Region;

-- 9. Top 10 Most Improved Customers by Profit Growth (2016 → 2017)
SELECT 
    Customer_Name,
    ROUND(SUM(CASE
                WHEN SUBSTRING(Order_ID, 4, 4) = '2016' THEN Profit
                ELSE 0
            END),
            2) AS Profit_2016,
    ROUND(SUM(CASE
                WHEN SUBSTRING(Order_ID, 4, 4) = '2017' THEN Profit
                ELSE 0
            END),
            2) AS Profit_2017,
    ROUND(SUM(CASE
                WHEN SUBSTRING(Order_ID, 4, 4) = '2017' THEN Profit
                ELSE 0
            END) - SUM(CASE
                WHEN SUBSTRING(Order_ID, 4, 4) = '2016' THEN Profit
                ELSE 0
            END),
            2) AS Profit_Growth
FROM
    orders
GROUP BY Customer_Name
HAVING SUM(CASE
    WHEN SUBSTRING(Order_ID, 4, 4) = '2016' THEN Profit
    ELSE 0
END) > 0
ORDER BY Profit_Growth DESC
LIMIT 10;
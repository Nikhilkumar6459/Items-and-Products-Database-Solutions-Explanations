/*
SQL ASSIGNMENT 1: ITEMS AND PRODUCTS DATABASE
Prepared for: Nikhilkumar Ghatage
Platform: Microsoft SQL Server (T-SQL)

IMPORTANT ASSUMPTIONS
1. The assignment PDF provides 8 sample rows for ITEMS_TABLE and 8 for PRODUCTS_SALES_TABLE.
2. Some advanced questions require joining the tables, but the supplied sample tables have no true shared key.
   A vendor_nos-to-Product_Id join is NOT a valid business relationship; an example join is included only
   to demonstrate syntax and is clearly marked as illustrative.
3. The question asks to delete three products by Units_Sold. The DELETE statement is shown in a transaction
   and rolled back by default to prevent accidental permanent deletion. Commit only after checking results.
4. Revenue columns in the supplied product table have data that may not be internally consistent, so the
   queries use the supplied Gross_Sales, Sales, COGS and Profit values unless the question specifically asks
   to recalculate Gross_Sales.
*/

-- ============================================================
-- 0. CREATE DATABASES (run as a user permitted to create DBs)
-- ============================================================
IF DB_ID(N'Brands') IS NULL CREATE DATABASE Brands;
GO
IF DB_ID(N'Products') IS NULL CREATE DATABASE Products;
GO

USE Brands;
GO

IF OBJECT_ID(N'dbo.ITEMS_TABLE', N'U') IS NOT NULL DROP TABLE dbo.ITEMS_TABLE;
GO
CREATE TABLE dbo.ITEMS_TABLE (
    Item_Id INT NOT NULL,
    item_description NVARCHAR(150) NOT NULL,
    vendor_nos INT NOT NULL,
    vendor_name NVARCHAR(150) NOT NULL,
    bottle_size INT NOT NULL,
    bottle_price DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_ITEMS_TABLE PRIMARY KEY (Item_Id)
);
GO

INSERT INTO dbo.ITEMS_TABLE
(Item_Id, item_description, vendor_nos, vendor_name, bottle_size, bottle_price)
VALUES
(1, N'Travis Hasse Apple Pie', 305, N'Mhw Ltd', 750, 9.77),
(2, N'D''aristi Xtabentun', 391, N'Anchor Distilling (preiss Imports)', 750, 14.12),
(3, N'Hiram Walker Peach Brandy', 370, N'Pernod Ricard Usa/austin Nichols', 1000, 6.50),
(4, N'Oak Cross Whisky', 305, N'Mhw Ltd', 750, 25.33),
(5, N'Uv Red(cherry) Vodka', 380, N'Phillips Beverage Company', 200, 1.97),
(6, N'Heaven Hill Old Style White Label', 259, N'Heaven Hill Distilleries Inc.', 750, 6.37),
(7, N'Hyde Herbal Liqueur', 194, N'Fire Tail Brands Llc', 750, 5.06),
(8, N'Dupont Calvados Fine Reserve', 403, N'Robert Kacher Selections', 750, 23.61);
GO

USE Products;
GO
IF OBJECT_ID(N'dbo.PRODUCT_TABLE', N'U') IS NOT NULL DROP TABLE dbo.PRODUCT_TABLE;
GO
CREATE TABLE dbo.PRODUCT_TABLE (
    Product_Id INT NOT NULL PRIMARY KEY,
    Country NVARCHAR(50) NOT NULL,
    Product NVARCHAR(80) NOT NULL,
    Units_Sold DECIMAL(12,2) NOT NULL,
    Manufacturing_Price DECIMAL(10,2) NOT NULL,
    Sale_Price DECIMAL(10,2) NOT NULL,
    Gross_Sales DECIMAL(14,2) NOT NULL,
    Sales DECIMAL(14,2) NOT NULL,
    COGS DECIMAL(14,2) NOT NULL,
    Profit DECIMAL(14,2) NOT NULL,
    [Date] DATE NOT NULL,
    Month_Number INT NOT NULL,
    Month_Name NVARCHAR(20) NOT NULL,
    [Year] INT NOT NULL
);
GO

INSERT INTO dbo.PRODUCT_TABLE
(Product_Id, Country, Product, Units_Sold, Manufacturing_Price, Sale_Price,
 Gross_Sales, Sales, COGS, Profit, [Date], Month_Number, Month_Name, [Year])
VALUES
(1, N'Canada',  N'Carretera', 1618.5, 3, 20, 32370, 32370, 16185, 16185, '20140101', 1, N'January', 2014),
(2, N'Germany', N'Carretera', 1321,   3, 20, 26420, 26420, 13210, 13210, '20150101', 1, N'January', 2015),
(3, N'France',  N'Carretera', 2178,   3, 15, 32670, 32670, 21780, 10890, '20160601', 6, N'June', 2016),
(4, N'Germany', N'Carretera', 888,    3, 15, 13320, 13320, 8880, 4440, '20170601', 6, N'June', 2017),
(5, N'Mexico',  N'Carretera', 2470,   3, 15, 37050, 37050, 24700, 12350, '20180601', 6, N'June', 2018),
(6, N'Germany', N'Montana', 1513, 350, 350, 529550, 529550, 393380, 136170, '20191201', 12, N'December', 2019),
(7, N'Germany', N'Montana', 921, 5, 15, 13815, 13815, 9210, 4605, '20200301', 3, N'March', 2020),
(8, N'Canada', N'Montana', 2518, 5, 12, 30216, 30216, 7554, 22662, '20210601', 6, N'June', 2021);
GO

-- ============================================================
-- BASIC QUESTIONS (PDF pages 2-3)
-- ============================================================

-- B1. Create databases: completed above.
-- B2-B3. Create tables and insert records: completed above.

-- B4. Delete records where Units_Sold is 1618.5, 888, 2470.
-- Safe demonstration: inspect affected rows, then rollback.
BEGIN TRANSACTION;
DELETE FROM Products.dbo.PRODUCT_TABLE
WHERE Units_Sold IN (1618.5, 888, 2470);
SELECT @@ROWCOUNT AS RowsDeletedInsideTransaction;
SELECT * FROM Products.dbo.PRODUCT_TABLE ORDER BY Product_Id;
ROLLBACK TRANSACTION;
-- To make deletion permanent, replace ROLLBACK with COMMIT after review.

-- B5. Select all records from ITEMS_TABLE.
SELECT * FROM Brands.dbo.ITEMS_TABLE;

-- B6. Select item description and bottle price.
SELECT item_description, bottle_price
FROM Brands.dbo.ITEMS_TABLE;

-- B7. Items with bottle_price > 20.
SELECT item_description, bottle_price
FROM Brands.dbo.ITEMS_TABLE
WHERE bottle_price > 20;

-- B8. Unique countries.
SELECT DISTINCT Country
FROM Products.dbo.PRODUCT_TABLE
ORDER BY Country;

-- B9. Number of distinct countries represented in the table.
SELECT COUNT(DISTINCT Country) AS NumberOfCountries
FROM Products.dbo.PRODUCT_TABLE;

-- B10. Number of countries with Sale_Price between 10 and 20.
-- Interpretation: count distinct countries having at least one qualifying row.
SELECT COUNT(DISTINCT Country) AS CountriesWithSalePrice10To20
FROM Products.dbo.PRODUCT_TABLE
WHERE Sale_Price BETWEEN 10 AND 20;

-- ============================================================
-- INTERMEDIATE QUESTIONS (PDF page 3)
-- ============================================================

-- I1. Total Sale_Price and Gross_Sales (sum of column values).
SELECT SUM(Sale_Price) AS TotalSalePriceColumnSum,
       SUM(Gross_Sales) AS TotalGrossSales
FROM Products.dbo.PRODUCT_TABLE;

-- I2. Year with highest total sales (sum Sales).
SELECT TOP (1) [Year], SUM(Sales) AS TotalSales
FROM Products.dbo.PRODUCT_TABLE
GROUP BY [Year]
ORDER BY SUM(Sales) DESC, [Year];

-- I3. Product with Sales = 37,050.
SELECT Product, Sales
FROM Products.dbo.PRODUCT_TABLE
WHERE Sales = 37050;

-- I4. Countries with Profit between 4,605 and 22,662 (inclusive).
SELECT DISTINCT Country, Profit
FROM Products.dbo.PRODUCT_TABLE
WHERE Profit BETWEEN 4605 AND 22662
ORDER BY Country;

-- I5. Product_Id for Sales = 24,700.
-- Note: supplied sample has COGS = 24,700 for Product_Id 5, but Sales = 37,050.
SELECT Product_Id
FROM Products.dbo.PRODUCT_TABLE
WHERE Sales = 24700;

-- I6. Total Units_Sold for each country.
SELECT Country, SUM(Units_Sold) AS TotalUnitsSold
FROM Products.dbo.PRODUCT_TABLE
GROUP BY Country
ORDER BY Country;

-- I7. Average Sales for each country.
SELECT Country, AVG(Sales) AS AverageSales
FROM Products.dbo.PRODUCT_TABLE
GROUP BY Country
ORDER BY Country;

-- I8. Products sold in 2014.
SELECT *
FROM Products.dbo.PRODUCT_TABLE
WHERE [Year] = 2014;

-- I9. Maximum profit.
SELECT MAX(Profit) AS MaximumProfit
FROM Products.dbo.PRODUCT_TABLE;

-- I10. Records whose Profit exceeds average Profit of all rows.
SELECT *
FROM Products.dbo.PRODUCT_TABLE
WHERE Profit > (SELECT AVG(Profit) FROM Products.dbo.PRODUCT_TABLE);

-- I11. Items with bottle_size = 750.
SELECT item_description
FROM Brands.dbo.ITEMS_TABLE
WHERE bottle_size = 750;

-- I12. Vendor names for vendor_nos 305, 380, 391.
SELECT vendor_nos, vendor_name
FROM Brands.dbo.ITEMS_TABLE
WHERE vendor_nos IN (305, 380, 391)
ORDER BY vendor_nos, vendor_name;

-- I13. Total bottle_price.
SELECT SUM(bottle_price) AS TotalBottlePrice
FROM Brands.dbo.ITEMS_TABLE;

-- I14. Primary key on Item_Id is created in table definition (PK_ITEMS_TABLE).

-- I15. Item_Id for bottle_price = 5.06.
SELECT Item_Id, item_description
FROM Brands.dbo.ITEMS_TABLE
WHERE bottle_price = 5.06;

-- ============================================================
-- ADVANCED QUESTIONS (PDF page 4)
-- ============================================================

-- A1. JOIN demonstrations.
-- No valid shared key exists between these two sample tables.
-- The following are syntax demonstrations only and are not meaningful business joins.
-- INNER JOIN (illustrative only):
SELECT i.Item_Id, i.item_description, p.Product_Id, p.Product, p.Country
FROM Brands.dbo.ITEMS_TABLE AS i
INNER JOIN Products.dbo.PRODUCT_TABLE AS p
    ON i.vendor_nos = p.Product_Id;

-- LEFT JOIN (illustrative only):
SELECT i.Item_Id, i.item_description, p.Product_Id, p.Product
FROM Brands.dbo.ITEMS_TABLE AS i
LEFT JOIN Products.dbo.PRODUCT_TABLE AS p
    ON i.vendor_nos = p.Product_Id;

-- FULL OUTER JOIN (illustrative only):
SELECT i.Item_Id, i.item_description, p.Product_Id, p.Product
FROM Brands.dbo.ITEMS_TABLE AS i
FULL OUTER JOIN Products.dbo.PRODUCT_TABLE AS p
    ON i.vendor_nos = p.Product_Id;

-- A2. Item description and Product where Gross_Sales = 13,320.
-- No valid relationship exists in source tables; show the product row and item descriptions separately.
SELECT Product, Gross_Sales
FROM Products.dbo.PRODUCT_TABLE
WHERE Gross_Sales = 13320;
SELECT Item_Id, item_description FROM Brands.dbo.ITEMS_TABLE;

-- A3. Split item_description into Item_desc1 and Item_desc2 (first word / remaining text).
SELECT item_description,
       LEFT(item_description, CHARINDEX(N' ', item_description + N' ') - 1) AS Item_desc1,
       LTRIM(SUBSTRING(item_description,
           CHARINDEX(N' ', item_description + N' ') + 1, LEN(item_description))) AS Item_desc2
FROM Brands.dbo.ITEMS_TABLE;

-- A4. Top 3 most expensive items.
SELECT TOP (3) Item_Id, item_description, bottle_price
FROM Brands.dbo.ITEMS_TABLE
ORDER BY bottle_price DESC;

-- A5. Total Gross Sales and Profit by Product and Country.
SELECT Country, Product, SUM(Gross_Sales) AS TotalGrossSales, SUM(Profit) AS TotalProfit
FROM Products.dbo.PRODUCT_TABLE
GROUP BY Country, Product
ORDER BY Country, Product;

-- A6. Vendor and item descriptions where bottle_size = 750 and bottle_price < 10.
SELECT vendor_name, item_description
FROM Brands.dbo.ITEMS_TABLE
WHERE bottle_size = 750 AND bottle_price < 10;

-- A7. Product with highest Profit in 2019.
SELECT TOP (1) Product, Country, Profit, [Year]
FROM Products.dbo.PRODUCT_TABLE
WHERE [Year] = 2019
ORDER BY Profit DESC;

-- A8. Product_Id and Country where Profit >= 2 * COGS.
SELECT Product_Id, Country
FROM Products.dbo.PRODUCT_TABLE
WHERE Profit >= 2 * COGS;

-- A9. Country with highest total Gross Sales in 2018.
SELECT TOP (1) Country, SUM(Gross_Sales) AS TotalGrossSales
FROM Products.dbo.PRODUCT_TABLE
WHERE [Year] = 2018
GROUP BY Country
ORDER BY SUM(Gross_Sales) DESC;

-- A10. Total Sales for each Month_Name across all years.
SELECT Month_Name, SUM(Sales) AS TotalSales
FROM Products.dbo.PRODUCT_TABLE
GROUP BY Month_Number, Month_Name
ORDER BY Month_Number;

-- A11. Items whose vendor_nos appears more than once.
SELECT item_description, vendor_name, vendor_nos
FROM Brands.dbo.ITEMS_TABLE
WHERE vendor_nos IN (
    SELECT vendor_nos
    FROM Brands.dbo.ITEMS_TABLE
    GROUP BY vendor_nos
    HAVING COUNT(*) > 1
)
ORDER BY vendor_nos, Item_Id;

-- A12. Average Manufacturing_Price by Country and Product, only averages > 3.
SELECT Country, Product, AVG(Manufacturing_Price) AS AverageManufacturingPrice
FROM Products.dbo.PRODUCT_TABLE
GROUP BY Country, Product
HAVING AVG(Manufacturing_Price) > 3
ORDER BY Country, Product;

-- ============================================================
-- SUPER-ADVANCED QUESTIONS (PDF pages 5-6)
-- ============================================================

-- S1. Items with same vendor_name as Item_Id 1.
SELECT item_description, bottle_price
FROM Brands.dbo.ITEMS_TABLE
WHERE vendor_name = (
    SELECT vendor_name
    FROM Brands.dbo.ITEMS_TABLE
    WHERE Item_Id = 1
);

-- S2. Stored procedure: retrieve items whose bottle_price exceeds input value.
USE Brands;
GO
CREATE OR ALTER PROCEDURE dbo.GetItemsAboveBottlePrice
    @MinimumPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Item_Id, item_description, vendor_nos, vendor_name, bottle_size, bottle_price
    FROM dbo.ITEMS_TABLE
    WHERE bottle_price > @MinimumPrice
    ORDER BY bottle_price DESC;
END;
GO
-- Example: EXEC dbo.GetItemsAboveBottlePrice @MinimumPrice = 10.00;

-- S3. Stored procedure: insert a new record into product table.
USE Products;
GO
CREATE OR ALTER PROCEDURE dbo.InsertProductSale
    @Product_Id INT,
    @Country NVARCHAR(50),
    @Product NVARCHAR(80),
    @Units_Sold DECIMAL(12,2),
    @Manufacturing_Price DECIMAL(10,2),
    @Sale_Price DECIMAL(10,2),
    @Gross_Sales DECIMAL(14,2),
    @Sales DECIMAL(14,2),
    @COGS DECIMAL(14,2),
    @Profit DECIMAL(14,2),
    @Date DATE,
    @Month_Number INT,
    @Month_Name NVARCHAR(20),
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.PRODUCT_TABLE
    (Product_Id, Country, Product, Units_Sold, Manufacturing_Price, Sale_Price,
     Gross_Sales, Sales, COGS, Profit, [Date], Month_Number, Month_Name, [Year])
    VALUES
    (@Product_Id, @Country, @Product, @Units_Sold, @Manufacturing_Price, @Sale_Price,
     @Gross_Sales, @Sales, @COGS, @Profit, @Date, @Month_Number, @Month_Name, @Year);
END;
GO

-- S4. Trigger: update Gross_Sales whenever Units_Sold or Sale_Price changes.
-- This trigger recalculates Gross_Sales = Units_Sold * Sale_Price for changed rows.
CREATE OR ALTER TRIGGER dbo.trg_RecalculateGrossSales
ON dbo.PRODUCT_TABLE
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(Units_Sold) OR UPDATE(Sale_Price)
    BEGIN
        UPDATE p
        SET Gross_Sales = i.Units_Sold * i.Sale_Price
        FROM dbo.PRODUCT_TABLE AS p
        INNER JOIN inserted AS i ON p.Product_Id = i.Product_Id;
    END
END;
GO

-- S5. Case-insensitive search for "Whisky" (explicit CI collation).
USE Brands;
GO
SELECT item_description
FROM dbo.ITEMS_TABLE
WHERE item_description COLLATE Latin1_General_100_CI_AI LIKE N'%whisky%';

-- S6. Country and Product where Profit exceeds the average Profit of all rows.
USE Products;
GO
SELECT Country, Product, Profit
FROM dbo.PRODUCT_TABLE
WHERE Profit > (SELECT AVG(Profit) FROM dbo.PRODUCT_TABLE)
ORDER BY Profit DESC;

-- S7. Illustrative join using vendor_nos = Product_Id (not a true key).
USE Brands;
GO
SELECT i.Item_Id, i.item_description, i.vendor_name, p.Product_Id, p.Country, p.Product
FROM dbo.ITEMS_TABLE AS i
INNER JOIN Products.dbo.PRODUCT_TABLE AS p
    ON i.vendor_nos = p.Product_Id;

-- S8. Combine item description and vendor name with hyphen.
SELECT CONCAT(item_description, N' - ', vendor_name) AS ItemAndVendor
FROM Brands.dbo.ITEMS_TABLE;

-- S9. Round bottle_price to one decimal place.
SELECT Item_Id, item_description, ROUND(bottle_price, 1) AS BottlePriceRounded
FROM Brands.dbo.ITEMS_TABLE;

-- S10. Number of days between today and each product Date.
SELECT Product_Id, Country, Product, [Date],
       DATEDIFF(DAY, [Date], CAST(GETDATE() AS DATE)) AS DaysSinceSaleDate
FROM Products.dbo.PRODUCT_TABLE
ORDER BY [Date];

-- =============================================
-- Performance Optimization for Pagination
-- =============================================
-- Best practices, indexing strategies, and optimization techniques
-- for efficient pagination queries

-- =============================================
-- Example 1: Creating Appropriate Indexes
-- =============================================

-- Index for simple pagination sorted by ID
CREATE NONCLUSTERED INDEX IX_Customers_CustomerID 
ON Customers(CustomerID ASC)
INCLUDE (FirstName, LastName, Email, CreatedDate);

-- Index for date-based pagination
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate_OrderID
ON Orders(OrderDate DESC, OrderID DESC)
INCLUDE (CustomerID, TotalAmount, Status);

-- Index for filtered pagination
CREATE NONCLUSTERED INDEX IX_Products_Category_Price
ON Products(Category ASC, Price DESC)
INCLUDE (ProductName, StockQuantity, Status);

-- Index for cursor pagination with composite key
CREATE NONCLUSTERED INDEX IX_Transactions_Date_ID
ON Transactions(TransactionDate DESC, TransactionID DESC)
INCLUDE (AccountID, Amount, TransactionType, Description);

-- Index for search and pagination
CREATE NONCLUSTERED INDEX IX_Products_Search
ON Products(ProductName)
INCLUDE (Description, Price, Category);

GO

-- =============================================
-- Example 2: Query Performance Analysis
-- =============================================

-- Enable actual execution plan and statistics
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

-- Bad: Missing ORDER BY causes undefined behavior
-- SELECT TOP (@PageSize) * FROM Orders; -- WRONG!

-- Good: Proper ORDER BY with index support
SELECT 
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount
FROM Orders
ORDER BY OrderDate DESC, OrderID DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

GO

-- =============================================
-- Example 3: Avoiding Common Performance Pitfalls
-- =============================================

-- BAD: Using SELECT * instead of specific columns
-- This query reads more data than needed
DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

-- Don't do this:
-- SELECT * FROM Products ORDER BY ProductID OFFSET (@PageNumber - 1) * @PageSize ROWS FETCH NEXT @PageSize ROWS ONLY;

-- GOOD: Select only required columns
SELECT 
    ProductID,
    ProductName,
    Price,
    Category
FROM Products
ORDER BY ProductID
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

-- BAD: Complex calculations in ORDER BY
-- This prevents index usage
-- SELECT CustomerID, FirstName, LastName 
-- FROM Customers 
-- ORDER BY (FirstName + ' ' + LastName) -- Computed column in ORDER BY
-- OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- GOOD: Use persisted computed column with index
-- ALTER TABLE Customers ADD FullName AS (FirstName + ' ' + LastName) PERSISTED;
-- CREATE INDEX IX_Customers_FullName ON Customers(FullName);

GO

-- =============================================
-- Example 4: Optimizing COUNT(*) OVER()
-- =============================================

-- For large datasets, COUNT(*) OVER() can be expensive
-- Consider these alternatives:

-- Option 1: Approximate count (fast but not exact)
DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

SELECT 
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    o.TotalAmount,
    (SELECT SUM(rows) 
     FROM sys.partitions 
     WHERE object_id = OBJECT_ID('Orders') 
     AND index_id IN (0,1)) AS ApproxTotalRecords
FROM Orders o
ORDER BY o.OrderDate DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

-- Option 2: Cache the count separately
-- Store count in application cache or separate table with timestamp
CREATE TABLE PaginationCache (
    TableName NVARCHAR(128) PRIMARY KEY,
    RecordCount BIGINT,
    LastUpdated DATETIME2 DEFAULT SYSUTCDATETIME()
);

-- Update cache periodically
MERGE PaginationCache AS target
USING (SELECT 'Orders' AS TableName, COUNT(*) AS RecordCount FROM Orders) AS source
ON target.TableName = source.TableName
WHEN MATCHED THEN UPDATE SET RecordCount = source.RecordCount, LastUpdated = SYSUTCDATETIME()
WHEN NOT MATCHED THEN INSERT (TableName, RecordCount) VALUES (source.TableName, source.RecordCount);

-- Use cached count
DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

SELECT 
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    o.TotalAmount,
    (SELECT RecordCount FROM PaginationCache WHERE TableName = 'Orders') AS TotalRecords
FROM Orders o
ORDER BY o.OrderDate DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 5: Efficient Deep Pagination Strategy
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetOrdersOptimized
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @UseDeepPaginationOptimization BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    -- For deep pages, use a more efficient approach
    IF @UseDeepPaginationOptimization = 1 AND @PageNumber > 100
    BEGIN
        -- Use a two-step approach for deep pagination
        -- Step 1: Get only the IDs
        DECLARE @OrderIDs TABLE (OrderID INT);
        
        INSERT INTO @OrderIDs
        SELECT OrderID
        FROM Orders
        ORDER BY OrderDate DESC, OrderID DESC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;
        
        -- Step 2: Get full data only for selected IDs
        SELECT 
            o.OrderID,
            o.CustomerID,
            o.OrderDate,
            o.TotalAmount,
            o.Status
        FROM Orders o
        INNER JOIN @OrderIDs ids ON o.OrderID = ids.OrderID
        ORDER BY o.OrderDate DESC, o.OrderID DESC;
    END
    ELSE
    BEGIN
        -- Standard pagination for shallow pages
        SELECT 
            OrderID,
            CustomerID,
            OrderDate,
            TotalAmount,
            Status
        FROM Orders
        ORDER BY OrderDate DESC, OrderID DESC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;
    END
END;
GO

-- =============================================
-- Example 6: Partitioning for Large Tables
-- =============================================

-- For very large tables, consider table partitioning
-- Example: Partition Orders by year

/*
-- Create partition function
CREATE PARTITION FUNCTION pf_OrderYear (DATE)
AS RANGE RIGHT FOR VALUES 
    ('2020-01-01', '2021-01-01', '2022-01-01', '2023-01-01', '2024-01-01', '2025-01-01');

-- Create partition scheme
CREATE PARTITION SCHEME ps_OrderYear
AS PARTITION pf_OrderYear
ALL TO ([PRIMARY]);

-- Create partitioned table
CREATE TABLE Orders_Partitioned (
    OrderID INT IDENTITY(1,1),
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10,2),
    Status NVARCHAR(20),
    CONSTRAINT PK_Orders_Partitioned PRIMARY KEY (OrderDate, OrderID)
) ON ps_OrderYear(OrderDate);

-- Pagination benefits from partition elimination
DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;
DECLARE @Year INT = 2024;

SELECT 
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount
FROM Orders_Partitioned
WHERE YEAR(OrderDate) = @Year -- Partition elimination
ORDER BY OrderDate DESC, OrderID DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;
*/

GO

-- =============================================
-- Example 7: Covering Index for Common Queries
-- =============================================

-- Identify your most common pagination query
-- Create a covering index that includes all needed columns

-- Example: Common query for customer orders
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID_OrderDate_Covering
ON Orders(CustomerID, OrderDate DESC)
INCLUDE (OrderID, TotalAmount, Status, ShippingAddress);

-- Now this query is fully covered
DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;
DECLARE @CustomerID INT = 123;

SELECT 
    OrderID,
    OrderDate,
    TotalAmount,
    Status,
    ShippingAddress
FROM Orders
WHERE CustomerID = @CustomerID
ORDER BY OrderDate DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 8: Query Store and Plan Forcing
-- =============================================

-- Enable Query Store to identify slow pagination queries
-- ALTER DATABASE YourDatabase SET QUERY_STORE = ON;

-- Query to find slow pagination queries in Query Store
SELECT 
    qsq.query_id,
    qsqt.query_sql_text,
    qsrs.avg_duration / 1000.0 AS avg_duration_ms,
    qsrs.avg_logical_io_reads,
    qsrs.count_executions,
    qsp.plan_id
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qsqt ON qsq.query_text_id = qsqt.query_text_id
JOIN sys.query_store_plan qsp ON qsq.query_id = qsp.query_id
JOIN sys.query_store_runtime_stats qsrs ON qsp.plan_id = qsrs.plan_id
WHERE qsqt.query_sql_text LIKE '%OFFSET%FETCH%'
    AND qsrs.avg_duration > 100000 -- More than 100ms average
ORDER BY qsrs.avg_duration DESC;

GO

-- =============================================
-- Example 9: Using Filtered Indexes
-- =============================================

-- For common filter + pagination scenarios
-- Create filtered index for frequently queried subsets

-- Example: Active products are queried 99% of the time
CREATE NONCLUSTERED INDEX IX_Products_Active_Category_Price
ON Products(Category, Price DESC)
INCLUDE (ProductName, StockQuantity)
WHERE Status = 'Active'; -- Filtered index

-- This query benefits from the filtered index
DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;
DECLARE @Category NVARCHAR(50) = 'Electronics';

SELECT 
    ProductID,
    ProductName,
    Price,
    StockQuantity
FROM Products
WHERE Status = 'Active'
    AND Category = @Category
ORDER BY Price DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 10: Monitoring and Maintenance
-- =============================================

-- Query to identify missing indexes for pagination
SELECT 
    OBJECT_NAME(mid.object_id) AS TableName,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.avg_user_impact,
    migs.user_seeks,
    migs.user_scans
FROM sys.dm_db_missing_index_details mid
JOIN sys.dm_db_missing_index_groups mig ON mid.index_handle = mig.index_handle
JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
WHERE OBJECT_NAME(mid.object_id) IN ('Orders', 'Products', 'Customers', 'Transactions')
ORDER BY migs.avg_user_impact DESC;

-- Check index fragmentation (run periodically)
SELECT 
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10
    AND ips.page_count > 1000
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- Rebuild fragmented indexes
-- ALTER INDEX IX_Orders_OrderDate_OrderID ON Orders REBUILD;

GO

-- =============================================
-- Example 11: Best Practices Summary
-- =============================================

/*
PAGINATION PERFORMANCE BEST PRACTICES:

1. INDEXING:
   - Always have an index that supports your ORDER BY clause
   - Use covering indexes with INCLUDE clause for frequently accessed columns
   - Consider filtered indexes for common WHERE predicates
   
2. QUERY DESIGN:
   - Always use ORDER BY with deterministic sort (include unique column)
   - Select only required columns, avoid SELECT *
   - For deep pagination (page > 100), consider cursor-based approach
   - Avoid complex calculations in ORDER BY clause
   
3. COUNT OPTIMIZATION:
   - For large tables, cache total count separately
   - Consider approximate counts for non-critical scenarios
   - Avoid COUNT(*) OVER() on every query if possible
   
4. MONITORING:
   - Use Query Store to track pagination query performance
   - Monitor index usage and fragmentation
   - Look for missing index recommendations
   
5. SCALING STRATEGIES:
   - For very large tables (> 100M rows), consider partitioning
   - Use cursor/keyset pagination for infinite scroll scenarios
   - Implement hybrid approach: OFFSET for shallow, cursor for deep pages
   - Consider read replicas for read-heavy pagination workloads
   
6. CACHING:
   - Cache frequently accessed pages at application level
   - Use Redis/Memcached for pagination metadata
   - Implement cache invalidation strategy for data changes
*/

-- =============================================
-- Example 12: Performance Testing Template
-- =============================================

-- Use this to compare different pagination approaches
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

PRINT '=== Test 1: OFFSET-FETCH Shallow Page ===';
DECLARE @PageNumber1 INT = 5;
DECLARE @PageSize1 INT = 10;
SELECT OrderID, OrderDate, TotalAmount
FROM Orders
ORDER BY OrderDate DESC, OrderID DESC
OFFSET (@PageNumber1 - 1) * @PageSize1 ROWS
FETCH NEXT @PageSize1 ROWS ONLY;

PRINT '=== Test 2: OFFSET-FETCH Deep Page ===';
DECLARE @PageNumber2 INT = 1000;
DECLARE @PageSize2 INT = 10;
SELECT OrderID, OrderDate, TotalAmount
FROM Orders
ORDER BY OrderDate DESC, OrderID DESC
OFFSET (@PageNumber2 - 1) * @PageSize2 ROWS
FETCH NEXT @PageSize2 ROWS ONLY;

PRINT '=== Test 3: Cursor-Based Pagination ===';
DECLARE @LastOrderID INT = 10000;
DECLARE @PageSize3 INT = 10;
SELECT TOP (@PageSize3) OrderID, OrderDate, TotalAmount
FROM Orders
WHERE OrderID > @LastOrderID
ORDER BY OrderID;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

GO

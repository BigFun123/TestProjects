-- =============================================
-- Advanced Pagination with Filtering, Sorting, and Search
-- =============================================
-- These queries demonstrate complex real-world scenarios
-- with multiple filters, dynamic sorting, and full-text search

-- =============================================
-- Example 1: Pagination with Multiple Filters
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;
DECLARE @MinPrice DECIMAL(10,2) = 10.00;
DECLARE @MaxPrice DECIMAL(10,2) = 1000.00;
DECLARE @Category NVARCHAR(50) = NULL; -- NULL means no filter
DECLARE @Status NVARCHAR(20) = 'Active';
DECLARE @MinStock INT = 5;

SELECT 
    ProductID,
    ProductName,
    Category,
    Price,
    StockQuantity,
    Status,
    COUNT(*) OVER() AS TotalRecords
FROM Products
WHERE Price >= @MinPrice
    AND Price <= @MaxPrice
    AND (@Category IS NULL OR Category = @Category)
    AND Status = @Status
    AND StockQuantity >= @MinStock
ORDER BY ProductName
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 2: Dynamic Sorting with Pagination
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetProductsWithDynamicSort
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(50) = 'ProductName',
    @SortDirection NVARCHAR(4) = 'ASC'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate sort direction
    IF @SortDirection NOT IN ('ASC', 'DESC')
        SET @SortDirection = 'ASC';
    
    -- Dynamic SQL for flexible sorting
    DECLARE @SQL NVARCHAR(MAX);
    
    SET @SQL = N'
    SELECT 
        ProductID,
        ProductName,
        Category,
        Price,
        StockQuantity,
        CreatedDate,
        COUNT(*) OVER() AS TotalRecords
    FROM Products
    ORDER BY ' + QUOTENAME(@SortColumn) + ' ' + @SortDirection + '
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;';
    
    EXEC sp_executesql @SQL, 
        N'@PageNumber INT, @PageSize INT', 
        @PageNumber, @PageSize;
END;
GO

-- Test dynamic sorting
EXEC sp_GetProductsWithDynamicSort @PageNumber = 1, @PageSize = 10, @SortColumn = 'Price', @SortDirection = 'DESC';
GO

-- =============================================
-- Example 3: Pagination with Search Filter
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 20;
DECLARE @SearchTerm NVARCHAR(100) = 'laptop';

SELECT 
    ProductID,
    ProductName,
    Description,
    Category,
    Price,
    COUNT(*) OVER() AS TotalRecords
FROM Products
WHERE ProductName LIKE '%' + @SearchTerm + '%'
    OR Description LIKE '%' + @SearchTerm + '%'
    OR Category LIKE '%' + @SearchTerm + '%'
ORDER BY 
    CASE 
        WHEN ProductName LIKE @SearchTerm + '%' THEN 1  -- Exact prefix match first
        WHEN ProductName LIKE '%' + @SearchTerm + '%' THEN 2  -- Contains match
        ELSE 3
    END,
    ProductName
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 4: Full-Text Search with Pagination
-- =============================================
-- Note: Requires full-text index on the table

/*
-- Create full-text catalog and index (run once)
CREATE FULLTEXT CATALOG ftCatalog AS DEFAULT;
CREATE FULLTEXT INDEX ON Products(ProductName, Description)
    KEY INDEX PK_Products ON ftCatalog;
*/

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;
DECLARE @SearchTerm NVARCHAR(100) = 'wireless bluetooth';

SELECT 
    ProductID,
    ProductName,
    Description,
    Price,
    COUNT(*) OVER() AS TotalRecords
FROM Products
WHERE CONTAINS((ProductName, Description), @SearchTerm)
ORDER BY ProductID
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 5: Complex Multi-Table Join with Pagination
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 15;
DECLARE @CustomerCountry NVARCHAR(50) = 'USA';
DECLARE @StartDate DATE = '2024-01-01';
DECLARE @MinOrderAmount DECIMAL(10,2) = 100.00;

SELECT 
    o.OrderID,
    o.OrderDate,
    o.TotalAmount,
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Email,
    c.Country,
    COUNT(*) OVER() AS TotalRecords
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.Country = @CustomerCountry
    AND o.OrderDate >= @StartDate
    AND o.TotalAmount >= @MinOrderAmount
ORDER BY o.OrderDate DESC, o.OrderID DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 6: Pagination with Multiple Search Terms (OR Logic)
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;
DECLARE @SearchTerms NVARCHAR(500) = 'laptop,tablet,phone'; -- Comma-separated

-- Split search terms into a table
DECLARE @Terms TABLE (Term NVARCHAR(100));
INSERT INTO @Terms (Term)
SELECT LTRIM(RTRIM(value)) 
FROM STRING_SPLIT(@SearchTerms, ',');

SELECT DISTINCT
    p.ProductID,
    p.ProductName,
    p.Category,
    p.Price,
    COUNT(*) OVER() AS TotalRecords
FROM Products p
WHERE EXISTS (
    SELECT 1 
    FROM @Terms t 
    WHERE p.ProductName LIKE '%' + t.Term + '%' 
        OR p.Description LIKE '%' + t.Term + '%'
)
ORDER BY p.ProductName
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 7: Comprehensive Filter with All Options
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetOrdersAdvancedFilter
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @CustomerID INT = NULL,
    @Status NVARCHAR(20) = NULL,
    @MinAmount DECIMAL(10,2) = NULL,
    @MaxAmount DECIMAL(10,2) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @Country NVARCHAR(50) = NULL,
    @SearchTerm NVARCHAR(100) = NULL,
    @SortBy NVARCHAR(50) = 'OrderDate',
    @SortDirection NVARCHAR(4) = 'DESC'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Build dynamic WHERE clause
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Where NVARCHAR(MAX) = ' WHERE 1=1 ';
    
    IF @CustomerID IS NOT NULL
        SET @Where = @Where + ' AND o.CustomerID = @CustomerID ';
    
    IF @Status IS NOT NULL
        SET @Where = @Where + ' AND o.Status = @Status ';
    
    IF @MinAmount IS NOT NULL
        SET @Where = @Where + ' AND o.TotalAmount >= @MinAmount ';
    
    IF @MaxAmount IS NOT NULL
        SET @Where = @Where + ' AND o.TotalAmount <= @MaxAmount ';
    
    IF @StartDate IS NOT NULL
        SET @Where = @Where + ' AND o.OrderDate >= @StartDate ';
    
    IF @EndDate IS NOT NULL
        SET @Where = @Where + ' AND o.OrderDate < DATEADD(DAY, 1, @EndDate) ';
    
    IF @Country IS NOT NULL
        SET @Where = @Where + ' AND c.Country = @Country ';
    
    IF @SearchTerm IS NOT NULL
        SET @Where = @Where + ' AND (c.FirstName LIKE ''%'' + @SearchTerm + ''%'' 
                                       OR c.LastName LIKE ''%'' + @SearchTerm + ''%'' 
                                       OR c.Email LIKE ''%'' + @SearchTerm + ''%'') ';
    
    SET @SQL = N'
    SELECT 
        o.OrderID,
        o.OrderDate,
        o.TotalAmount,
        o.Status,
        c.CustomerID,
        c.FirstName,
        c.LastName,
        c.Email,
        c.Country,
        COUNT(*) OVER() AS TotalRecords
    FROM Orders o
    INNER JOIN Customers c ON o.CustomerID = c.CustomerID '
    + @Where + 
    ' ORDER BY ' + QUOTENAME(@SortBy) + ' ' + @SortDirection + 
    ' OFFSET (@PageNumber - 1) * @PageSize ROWS
      FETCH NEXT @PageSize ROWS ONLY;';
    
    EXEC sp_executesql @SQL,
        N'@PageNumber INT, @PageSize INT, @CustomerID INT, @Status NVARCHAR(20), 
          @MinAmount DECIMAL(10,2), @MaxAmount DECIMAL(10,2), @StartDate DATE, 
          @EndDate DATE, @Country NVARCHAR(50), @SearchTerm NVARCHAR(100)',
        @PageNumber, @PageSize, @CustomerID, @Status, @MinAmount, @MaxAmount,
        @StartDate, @EndDate, @Country, @SearchTerm;
END;
GO

-- Test with multiple filters
EXEC sp_GetOrdersAdvancedFilter 
    @PageNumber = 1, 
    @PageSize = 10,
    @MinAmount = 50.00,
    @StartDate = '2024-01-01',
    @Country = 'USA',
    @SortBy = 'TotalAmount',
    @SortDirection = 'DESC';
GO

-- =============================================
-- Example 8: Pagination with IN Clause Filter
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;
DECLARE @Categories NVARCHAR(500) = 'Electronics,Computers,Gaming'; -- Comma-separated

SELECT 
    ProductID,
    ProductName,
    Category,
    Price,
    COUNT(*) OVER() AS TotalRecords
FROM Products
WHERE Category IN (SELECT value FROM STRING_SPLIT(@Categories, ','))
ORDER BY Category, ProductName
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 9: Pagination with Aggregated Subquery Filter
-- =============================================
-- Find customers with pagination, filtered by order count

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;
DECLARE @MinOrderCount INT = 5;

SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email,
    c.Country,
    (SELECT COUNT(*) FROM Orders WHERE CustomerID = c.CustomerID) AS OrderCount,
    (SELECT SUM(TotalAmount) FROM Orders WHERE CustomerID = c.CustomerID) AS TotalSpent,
    COUNT(*) OVER() AS TotalRecords
FROM Customers c
WHERE (SELECT COUNT(*) FROM Orders WHERE CustomerID = c.CustomerID) >= @MinOrderCount
ORDER BY OrderCount DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 10: Pagination with Range Filter and Limits
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetTransactionsWithLimits
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @MaxPageSize INT = 100,
    @AccountID INT = NULL,
    @MinAmount DECIMAL(10,2) = NULL,
    @MaxAmount DECIMAL(10,2) = NULL,
    @TransactionType NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Enforce limits
    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 10;
    IF @PageSize > @MaxPageSize SET @PageSize = @MaxPageSize;
    
    SELECT 
        TransactionID,
        AccountID,
        TransactionDate,
        Amount,
        TransactionType,
        Description,
        COUNT(*) OVER() AS TotalRecords,
        @PageNumber AS CurrentPage,
        @PageSize AS PageSize
    FROM Transactions
    WHERE (@AccountID IS NULL OR AccountID = @AccountID)
        AND (@MinAmount IS NULL OR Amount >= @MinAmount)
        AND (@MaxAmount IS NULL OR Amount <= @MaxAmount)
        AND (@TransactionType IS NULL OR TransactionType = @TransactionType)
    ORDER BY TransactionDate DESC, TransactionID DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- Test with limits
EXEC sp_GetTransactionsWithLimits 
    @PageNumber = 1, 
    @PageSize = 150, -- Will be limited to 100
    @MinAmount = 100.00,
    @TransactionType = 'Credit';
GO

-- =============================================
-- Pagination with Total Count
-- =============================================
-- These queries return both paginated results and total record count
-- Essential for displaying "Page X of Y" in the UI

-- =============================================
-- Example 1: Two Separate Queries (Simple Approach)
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

-- Get total count
SELECT COUNT(*) AS TotalRecords
FROM Customers;

-- Get paginated results
SELECT 
    CustomerID,
    FirstName,
    LastName,
    Email,
    CreatedDate
FROM Customers
ORDER BY CustomerID
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 2: Using COUNT(*) OVER() - Single Query
-- =============================================
-- More efficient as it returns count with data in one query

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

SELECT 
    CustomerID,
    FirstName,
    LastName,
    Email,
    CreatedDate,
    COUNT(*) OVER() AS TotalRecords  -- Window function for total count
FROM Customers
ORDER BY CustomerID
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 3: Stored Procedure Returning Multiple Result Sets
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetOrdersPaginatedWithCount
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate parameters
    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 10;
    IF @PageSize > 100 SET @PageSize = 100;
    
    -- Result Set 1: Pagination metadata
    SELECT 
        COUNT(*) AS TotalRecords,
        @PageNumber AS CurrentPage,
        @PageSize AS PageSize,
        CEILING(CAST(COUNT(*) AS FLOAT) / @PageSize) AS TotalPages
    FROM Orders;
    
    -- Result Set 2: Paginated data
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
END;
GO

-- Test the stored procedure
EXEC sp_GetOrdersPaginatedWithCount @PageNumber = 1, @PageSize = 20;
GO

-- =============================================
-- Example 4: Pagination with Filtered Count
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 15;
DECLARE @Status NVARCHAR(20) = 'Active';

SELECT 
    ProductID,
    ProductName,
    Category,
    Price,
    Status,
    COUNT(*) OVER() AS TotalRecords
FROM Products
WHERE Status = @Status
ORDER BY ProductName
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 5: Complete Pagination Info with CTE
-- =============================================

DECLARE @PageNumber INT = 2;
DECLARE @PageSize INT = 10;

WITH PaginatedData AS (
    SELECT 
        CustomerID,
        FirstName,
        LastName,
        Email,
        City,
        Country,
        ROW_NUMBER() OVER (ORDER BY CustomerID) AS RowNum,
        COUNT(*) OVER() AS TotalRecords
    FROM Customers
)
SELECT 
    CustomerID,
    FirstName,
    LastName,
    Email,
    City,
    Country,
    RowNum,
    TotalRecords,
    @PageNumber AS CurrentPage,
    @PageSize AS PageSize,
    CEILING(CAST(TotalRecords AS FLOAT) / @PageSize) AS TotalPages,
    CASE 
        WHEN @PageNumber > 1 THEN 1 
        ELSE 0 
    END AS HasPreviousPage,
    CASE 
        WHEN @PageNumber < CEILING(CAST(TotalRecords AS FLOAT) / @PageSize) THEN 1 
        ELSE 0 
    END AS HasNextPage
FROM PaginatedData
WHERE RowNum BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize);

GO

-- =============================================
-- Example 6: JSON Response Format (API-Friendly)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetProductsPaginatedJSON
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TotalRecords INT;
    DECLARE @TotalPages INT;
    
    -- Get total count
    SELECT @TotalRecords = COUNT(*) FROM Products;
    SET @TotalPages = CEILING(CAST(@TotalRecords AS FLOAT) / @PageSize);
    
    -- Return single JSON result
    SELECT 
        (SELECT 
            @PageNumber AS currentPage,
            @PageSize AS pageSize,
            @TotalRecords AS totalRecords,
            @TotalPages AS totalPages,
            CASE WHEN @PageNumber > 1 THEN 1 ELSE 0 END AS hasPreviousPage,
            CASE WHEN @PageNumber < @TotalPages THEN 1 ELSE 0 END AS hasNextPage
         FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS pagination,
        (SELECT 
            ProductID,
            ProductName,
            Category,
            Price,
            StockQuantity
         FROM Products
         ORDER BY ProductID
         OFFSET (@PageNumber - 1) * @PageSize ROWS
         FETCH NEXT @PageSize ROWS ONLY
         FOR JSON PATH) AS data
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END;
GO

-- Test JSON procedure
EXEC sp_GetProductsPaginatedJSON @PageNumber = 1, @PageSize = 5;
GO

-- =============================================
-- Example 7: Pagination with Aggregate Information
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 20;
DECLARE @Category NVARCHAR(50) = 'Electronics';

SELECT 
    ProductID,
    ProductName,
    Price,
    StockQuantity,
    COUNT(*) OVER() AS TotalRecords,
    SUM(Price) OVER() AS TotalValue,
    AVG(Price) OVER() AS AveragePrice,
    MIN(Price) OVER() AS MinPrice,
    MAX(Price) OVER() AS MaxPrice
FROM Products
WHERE Category = @Category
ORDER BY Price DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

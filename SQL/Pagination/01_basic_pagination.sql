-- =============================================
-- Basic Pagination Examples
-- =============================================
-- These queries demonstrate simple OFFSET-FETCH pagination
-- which is the standard SQL Server approach introduced in SQL Server 2012

-- =============================================
-- Example 1: Basic Offset-Fetch Pagination
-- =============================================
-- Parameters:
-- @PageNumber: Current page (1-based)
-- @PageSize: Number of records per page

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

SELECT 
    CustomerID,
    FirstName,
    LastName,
    Email,
    CreatedDate
FROM Customers
ORDER BY CustomerID -- ORDER BY is required for OFFSET-FETCH
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 2: Pagination with Different Sort Order
-- =============================================

DECLARE @PageNumber INT = 2;
DECLARE @PageSize INT = 25;

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

GO

-- =============================================
-- Example 3: Pagination with Multiple Sort Columns
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 20;

SELECT 
    ProductID,
    ProductName,
    Category,
    Price,
    StockQuantity
FROM Products
ORDER BY Category ASC, Price DESC, ProductName ASC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 4: Simple Stored Procedure for Pagination
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetCustomersPaginated
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate parameters
    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 10;
    IF @PageSize > 100 SET @PageSize = 100; -- Max page size limit
    
    SELECT 
        CustomerID,
        FirstName,
        LastName,
        Email,
        Phone,
        CreatedDate
    FROM Customers
    ORDER BY CustomerID
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- Test the stored procedure
EXEC sp_GetCustomersPaginated @PageNumber = 1, @PageSize = 10;
GO

-- =============================================
-- Example 5: Pagination with WHERE Clause
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 15;
DECLARE @MinPrice DECIMAL(10,2) = 50.00;

SELECT 
    ProductID,
    ProductName,
    Price,
    Category
FROM Products
WHERE Price >= @MinPrice
    AND IsActive = 1
ORDER BY Price DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Cursor-Based (Keyset) Pagination
-- =============================================
-- Alternative to OFFSET-FETCH for better performance on large datasets
-- Uses the values from the last row to fetch the next page
-- More efficient as it doesn't skip rows like OFFSET does

-- =============================================
-- Example 1: Basic Cursor Pagination (Forward Only)
-- =============================================
-- First page: No cursor needed
-- Subsequent pages: Use the last ID from previous page

-- First page request
DECLARE @PageSize INT = 10;

SELECT TOP (@PageSize)
    CustomerID,
    FirstName,
    LastName,
    Email,
    CreatedDate
FROM Customers
ORDER BY CustomerID ASC;

-- Next page request (using last CustomerID from previous page)
DECLARE @PageSize INT = 10;
DECLARE @LastCustomerID INT = 10; -- ID of last record from previous page

SELECT TOP (@PageSize)
    CustomerID,
    FirstName,
    LastName,
    Email,
    CreatedDate
FROM Customers
WHERE CustomerID > @LastCustomerID
ORDER BY CustomerID ASC;

GO

-- =============================================
-- Example 2: Cursor Pagination with Descending Order
-- =============================================

-- First page (most recent orders)
DECLARE @PageSize INT = 20;

SELECT TOP (@PageSize)
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount,
    Status
FROM Orders
ORDER BY OrderDate DESC, OrderID DESC;

-- Next page (using last OrderDate and OrderID from previous page)
DECLARE @PageSize INT = 20;
DECLARE @LastOrderDate DATETIME = '2024-06-15 14:30:00';
DECLARE @LastOrderID INT = 1234;

SELECT TOP (@PageSize)
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount,
    Status
FROM Orders
WHERE OrderDate < @LastOrderDate
    OR (OrderDate = @LastOrderDate AND OrderID < @LastOrderID)
ORDER BY OrderDate DESC, OrderID DESC;

GO

-- =============================================
-- Example 3: Bidirectional Cursor Pagination
-- =============================================
-- Supports both forward and backward navigation

CREATE OR ALTER PROCEDURE sp_GetOrdersCursorPaginated
    @PageSize INT = 10,
    @CursorOrderDate DATETIME = NULL,
    @CursorOrderID INT = NULL,
    @Direction NVARCHAR(10) = 'NEXT' -- 'NEXT' or 'PREV'
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @Direction = 'NEXT' OR @CursorOrderDate IS NULL
    BEGIN
        -- Forward pagination or first page
        SELECT TOP (@PageSize)
            OrderID,
            CustomerID,
            OrderDate,
            TotalAmount,
            Status
        FROM Orders
        WHERE @CursorOrderDate IS NULL
            OR OrderDate < @CursorOrderDate
            OR (OrderDate = @CursorOrderDate AND OrderID < @CursorOrderID)
        ORDER BY OrderDate DESC, OrderID DESC;
    END
    ELSE IF @Direction = 'PREV'
    BEGIN
        -- Backward pagination
        SELECT TOP (@PageSize)
            OrderID,
            CustomerID,
            OrderDate,
            TotalAmount,
            Status
        FROM Orders
        WHERE OrderDate > @CursorOrderDate
            OR (OrderDate = @CursorOrderDate AND OrderID > @CursorOrderID)
        ORDER BY OrderDate ASC, OrderID ASC;
    END
END;
GO

-- Test forward pagination
EXEC sp_GetOrdersCursorPaginated @PageSize = 10, @Direction = 'NEXT';
EXEC sp_GetOrdersCursorPaginated @PageSize = 10, @CursorOrderDate = '2024-06-15', @CursorOrderID = 100, @Direction = 'NEXT';

-- Test backward pagination
EXEC sp_GetOrdersCursorPaginated @PageSize = 10, @CursorOrderDate = '2024-06-15', @CursorOrderID = 100, @Direction = 'PREV';
GO

-- =============================================
-- Example 4: Cursor Pagination with Composite Key
-- =============================================
-- When sorting by multiple columns

-- First page
DECLARE @PageSize INT = 15;

SELECT TOP (@PageSize)
    ProductID,
    ProductName,
    Category,
    Price,
    CreatedDate
FROM Products
ORDER BY Category ASC, Price DESC, ProductID ASC;

-- Next page (using composite cursor)
DECLARE @PageSize INT = 15;
DECLARE @LastCategory NVARCHAR(50) = 'Electronics';
DECLARE @LastPrice DECIMAL(10,2) = 499.99;
DECLARE @LastProductID INT = 567;

SELECT TOP (@PageSize)
    ProductID,
    ProductName,
    Category,
    Price,
    CreatedDate
FROM Products
WHERE 
    Category > @LastCategory
    OR (Category = @LastCategory AND Price < @LastPrice)
    OR (Category = @LastCategory AND Price = @LastPrice AND ProductID > @LastProductID)
ORDER BY Category ASC, Price DESC, ProductID ASC;

GO

-- =============================================
-- Example 5: Cursor Pagination with Date and Unique ID
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetTransactionsCursor
    @PageSize INT = 20,
    @LastTransactionDate DATETIME = NULL,
    @LastTransactionID BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Determine if this is the first page
    DECLARE @IsFirstPage BIT = CASE WHEN @LastTransactionDate IS NULL THEN 1 ELSE 0 END;
    
    IF @IsFirstPage = 1
    BEGIN
        -- First page
        SELECT TOP (@PageSize)
            TransactionID,
            AccountID,
            TransactionDate,
            Amount,
            TransactionType,
            Description
        FROM Transactions
        ORDER BY TransactionDate DESC, TransactionID DESC;
    END
    ELSE
    BEGIN
        -- Subsequent pages
        SELECT TOP (@PageSize)
            TransactionID,
            AccountID,
            TransactionDate,
            Amount,
            TransactionType,
            Description
        FROM Transactions
        WHERE TransactionDate < @LastTransactionDate
            OR (TransactionDate = @LastTransactionDate AND TransactionID < @LastTransactionID)
        ORDER BY TransactionDate DESC, TransactionID DESC;
    END
    
    -- Return cursor info for next page
    -- Client should use the last row's TransactionDate and TransactionID
END;
GO

-- Test cursor pagination
EXEC sp_GetTransactionsCursor @PageSize = 20; -- First page
EXEC sp_GetTransactionsCursor @PageSize = 20, @LastTransactionDate = '2024-06-01 10:30:00', @LastTransactionID = 5000;
GO

-- =============================================
-- Example 6: Cursor Pagination with Filter
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetFilteredProductsCursor
    @Category NVARCHAR(50),
    @PageSize INT = 10,
    @LastPrice DECIMAL(10,2) = NULL,
    @LastProductID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @LastPrice IS NULL
    BEGIN
        -- First page
        SELECT TOP (@PageSize)
            ProductID,
            ProductName,
            Category,
            Price,
            StockQuantity
        FROM Products
        WHERE Category = @Category
        ORDER BY Price DESC, ProductID ASC;
    END
    ELSE
    BEGIN
        -- Next page
        SELECT TOP (@PageSize)
            ProductID,
            ProductName,
            Category,
            Price,
            StockQuantity
        FROM Products
        WHERE Category = @Category
            AND (Price < @LastPrice OR (Price = @LastPrice AND ProductID > @LastProductID))
        ORDER BY Price DESC, ProductID ASC;
    END
END;
GO

-- Test filtered cursor pagination
EXEC sp_GetFilteredProductsCursor @Category = 'Electronics', @PageSize = 10;
EXEC sp_GetFilteredProductsCursor @Category = 'Electronics', @PageSize = 10, @LastPrice = 599.99, @LastProductID = 123;
GO

-- =============================================
-- Example 7: Infinite Scroll Pattern
-- =============================================
-- Optimized for social media feeds and real-time data

CREATE OR ALTER PROCEDURE sp_GetActivityFeedCursor
    @UserID INT,
    @PageSize INT = 20,
    @LastActivityTimestamp DATETIME2 = NULL,
    @LastActivityID BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Results TABLE (
        ActivityID BIGINT,
        UserID INT,
        ActivityType NVARCHAR(50),
        ActivityTimestamp DATETIME2,
        Content NVARCHAR(MAX),
        LikesCount INT,
        CommentsCount INT
    );
    
    -- Get activities from followed users
    IF @LastActivityTimestamp IS NULL
    BEGIN
        -- Initial load
        INSERT INTO @Results
        SELECT TOP (@PageSize)
            a.ActivityID,
            a.UserID,
            a.ActivityType,
            a.ActivityTimestamp,
            a.Content,
            a.LikesCount,
            a.CommentsCount
        FROM Activities a
        INNER JOIN Followers f ON a.UserID = f.FollowedUserID
        WHERE f.FollowerUserID = @UserID
        ORDER BY a.ActivityTimestamp DESC, a.ActivityID DESC;
    END
    ELSE
    BEGIN
        -- Load more (scroll down)
        INSERT INTO @Results
        SELECT TOP (@PageSize)
            a.ActivityID,
            a.UserID,
            a.ActivityType,
            a.ActivityTimestamp,
            a.Content,
            a.LikesCount,
            a.CommentsCount
        FROM Activities a
        INNER JOIN Followers f ON a.UserID = f.FollowedUserID
        WHERE f.FollowerUserID = @UserID
            AND (a.ActivityTimestamp < @LastActivityTimestamp
                OR (a.ActivityTimestamp = @LastActivityTimestamp AND a.ActivityID < @LastActivityID))
        ORDER BY a.ActivityTimestamp DESC, a.ActivityID DESC;
    END
    
    SELECT * FROM @Results;
    
    -- Return metadata for next request
    SELECT 
        @PageSize AS RequestedSize,
        COUNT(*) AS ReturnedSize,
        CASE WHEN COUNT(*) = @PageSize THEN 1 ELSE 0 END AS HasMore
    FROM @Results;
END;
GO

-- =============================================
-- Example 8: Cursor Pagination with Search
-- =============================================

CREATE OR ALTER PROCEDURE sp_SearchProductsCursor
    @SearchTerm NVARCHAR(100),
    @PageSize INT = 15,
    @LastRelevanceScore FLOAT = NULL,
    @LastProductID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    ;WITH SearchResults AS (
        SELECT 
            ProductID,
            ProductName,
            Description,
            Price,
            -- Simple relevance scoring
            (CASE WHEN ProductName LIKE @SearchTerm + '%' THEN 100 ELSE 0 END +
             CASE WHEN ProductName LIKE '%' + @SearchTerm + '%' THEN 50 ELSE 0 END +
             CASE WHEN Description LIKE '%' + @SearchTerm + '%' THEN 25 ELSE 0 END) AS RelevanceScore
        FROM Products
        WHERE ProductName LIKE '%' + @SearchTerm + '%'
            OR Description LIKE '%' + @SearchTerm + '%'
    )
    SELECT TOP (@PageSize)
        ProductID,
        ProductName,
        Description,
        Price,
        RelevanceScore
    FROM SearchResults
    WHERE @LastRelevanceScore IS NULL
        OR RelevanceScore < @LastRelevanceScore
        OR (RelevanceScore = @LastRelevanceScore AND ProductID > @LastProductID)
    ORDER BY RelevanceScore DESC, ProductID ASC;
END;
GO

-- Test search with cursor
EXEC sp_SearchProductsCursor @SearchTerm = 'laptop', @PageSize = 15;
EXEC sp_SearchProductsCursor @SearchTerm = 'laptop', @PageSize = 15, @LastRelevanceScore = 75, @LastProductID = 456;
GO

-- =============================================
-- Example 9: Comparing OFFSET vs Cursor Performance
-- =============================================

-- OFFSET approach (slower on large offsets)
DECLARE @PageNumber INT = 1000; -- Deep page
DECLARE @PageSize INT = 10;

SELECT 
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount
FROM Orders
ORDER BY OrderID
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

-- Cursor approach (faster regardless of depth)
DECLARE @LastOrderID INT = 10000; -- Equivalent to page 1000
DECLARE @PageSize INT = 10;

SELECT TOP (@PageSize)
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount
FROM Orders
WHERE OrderID > @LastOrderID
ORDER BY OrderID;

GO

-- =============================================
-- Example 10: Hybrid Approach with Page Limits
-- =============================================
-- Use cursor for deep pages, OFFSET for shallow ones

CREATE OR ALTER PROCEDURE sp_GetOrdersHybridPagination
    @PageNumber INT = NULL,
    @PageSize INT = 10,
    @LastOrderID INT = NULL,
    @MaxOffsetPages INT = 100 -- Switch to cursor after this many pages
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @LastOrderID IS NOT NULL
    BEGIN
        -- Use cursor-based pagination
        SELECT TOP (@PageSize)
            OrderID,
            CustomerID,
            OrderDate,
            TotalAmount,
            'CURSOR' AS PaginationType
        FROM Orders
        WHERE OrderID > @LastOrderID
        ORDER BY OrderID;
    END
    ELSE IF @PageNumber IS NOT NULL AND @PageNumber <= @MaxOffsetPages
    BEGIN
        -- Use OFFSET for shallow pages
        SELECT 
            OrderID,
            CustomerID,
            OrderDate,
            TotalAmount,
            'OFFSET' AS PaginationType
        FROM Orders
        ORDER BY OrderID
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;
    END
    ELSE
    BEGIN
        RAISERROR('For deep pagination beyond page %d, please use cursor-based pagination with @LastOrderID', 16, 1, @MaxOffsetPages);
    END
END;
GO

-- Test hybrid approach
EXEC sp_GetOrdersHybridPagination @PageNumber = 5, @PageSize = 10; -- OFFSET
EXEC sp_GetOrdersHybridPagination @LastOrderID = 50, @PageSize = 10; -- CURSOR
GO

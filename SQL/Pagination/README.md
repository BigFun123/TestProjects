# SQL Pagination Examples

This folder contains comprehensive examples of SQL Server pagination techniques, from basic to advanced patterns.

## Files Overview

### 01_basic_pagination.sql
- Simple OFFSET-FETCH pagination
- Page number and page size parameters
- Different sorting approaches
- Basic stored procedures
- Simple WHERE clause filtering

**Key Concepts:**
- `OFFSET (@PageNumber - 1) * @PageSize ROWS`
- `FETCH NEXT @PageSize ROWS ONLY`
- ORDER BY requirement

### 02_pagination_with_count.sql
- Total record count with pagination
- `COUNT(*) OVER()` window function
- Multiple result sets approach
- JSON response formatting
- Pagination metadata (HasNext, HasPrevious)
- Aggregate information with pagination

**Key Concepts:**
- Returning total count for UI pagination
- Calculating total pages
- API-friendly responses

### 03_date_range_pagination.sql
- Date range filtering with pagination
- Current month/year queries
- Last N days patterns
- Quarter and year/month filtering
- Relative date ranges (TODAY, THIS_WEEK, etc.)
- Business days filtering
- Date bucketing with aggregation

**Key Concepts:**
- `DATEFROMPARTS()`, `DATEADD()`, `DATEPART()`
- Period-based queries
- Efficient date range handling

### 04_advanced_filtering.sql
- Multiple simultaneous filters
- Dynamic sorting (column + direction)
- Search functionality (LIKE, CONTAINS)
- Full-text search with pagination
- Multi-table joins with pagination
- Complex WHERE clauses with NULLable parameters
- Multiple search terms (OR logic)
- IN clause filtering
- Comprehensive filter stored procedures

**Key Concepts:**
- Dynamic SQL for flexible sorting
- Optional parameter handling
- Search relevance ordering
- Parameter validation and limits

### 05_cursor_pagination.sql
- Keyset/cursor-based pagination (alternative to OFFSET)
- Forward and backward navigation
- Composite key cursors
- Infinite scroll pattern
- Search with cursor pagination
- Bidirectional pagination
- Hybrid OFFSET/cursor approach

**Key Concepts:**
- `WHERE ID > @LastID` instead of OFFSET
- Better performance for deep pages
- No skipping of rows
- Stateless pagination tokens

### 06_performance_optimization.sql
- Index creation strategies
- Query performance analysis
- Common pitfalls and solutions
- COUNT optimization techniques
- Deep pagination strategies
- Table partitioning examples
- Covering indexes
- Filtered indexes
- Query Store usage
- Monitoring and maintenance queries
- Performance testing templates

**Key Concepts:**
- Proper indexing for ORDER BY
- Covering indexes with INCLUDE
- Partition elimination
- Cache strategies
- Missing index identification

## Common Pagination Patterns

### Standard OFFSET-FETCH Pattern
```sql
SELECT columns
FROM table
ORDER BY sort_columns
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;
```

### Cursor-Based Pattern
```sql
SELECT TOP (@PageSize) columns
FROM table
WHERE ID > @LastID
ORDER BY ID;
```

### With Total Count
```sql
SELECT columns, COUNT(*) OVER() AS TotalRecords
FROM table
ORDER BY sort_columns
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;
```

## When to Use Each Approach

### OFFSET-FETCH Pagination
**Use when:**
- Users need to jump to specific pages
- Page numbers are displayed in UI
- Dataset is relatively small (< 10M rows)
- Pages are shallow (page number < 100)

**Avoid when:**
- Deep pagination (high page numbers)
- Real-time data with frequent inserts
- Infinite scroll interfaces

### Cursor-Based Pagination
**Use when:**
- Implementing infinite scroll
- Deep pagination needed
- Large datasets (> 10M rows)
- Real-time feeds (social media, activity logs)
- Performance is critical

**Avoid when:**
- Users need to jump to arbitrary pages
- Page numbers must be displayed

## Performance Considerations

1. **Always include ORDER BY** - Required for deterministic results
2. **Use unique sort key** - Include ID in ORDER BY to ensure consistent ordering
3. **Create appropriate indexes** - Index should match ORDER BY columns
4. **Select specific columns** - Avoid SELECT *
5. **Cache total counts** - Don't calculate on every request
6. **Consider cursor pagination** - For page numbers > 100
7. **Use covering indexes** - Include frequently selected columns
8. **Monitor query performance** - Use Query Store and execution plans

## Index Recommendations

```sql
-- For date-based pagination
CREATE NONCLUSTERED INDEX IX_TableName_Date_ID
ON TableName(DateColumn DESC, ID DESC)
INCLUDE (Column1, Column2, Column3);

-- For filtered pagination
CREATE NONCLUSTERED INDEX IX_TableName_Category_Price
ON TableName(Category, Price DESC)
INCLUDE (Column1, Column2)
WHERE Status = 'Active';
```

## Testing Your Pagination

1. Test with different page sizes (1, 10, 25, 50, 100)
2. Test deep pages (page 1, 100, 1000, 10000)
3. Test with filters and without
4. Check execution plans
5. Monitor IO and CPU statistics
6. Test with concurrent users
7. Verify consistent results across pages

## Common Mistakes to Avoid

❌ Missing ORDER BY clause  
❌ Non-deterministic ORDER BY (duplicate values)  
❌ Using SELECT * instead of specific columns  
❌ Calculating COUNT(*) on every request  
❌ Not validating page parameters  
❌ Missing indexes on ORDER BY columns  
❌ Complex calculations in ORDER BY  
❌ Using OFFSET for deep pages without optimization  

## Additional Resources

- [SQL Server OFFSET-FETCH Documentation](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-order-by-clause-transact-sql)
- [Pagination Best Practices](https://use-the-index-luke.com/sql/partial-results/fetch-next-page)
- [Query Performance Tuning](https://learn.microsoft.com/en-us/sql/relational-databases/performance/performance-monitoring-and-tuning-tools)

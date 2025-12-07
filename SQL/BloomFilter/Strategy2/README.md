# Bloom Filter Strategy 2 - SQL Implementation

## Overview
This implementation demonstrates a Bloom filter using a SQL table with a 64-bit BIGINT UNSIGNED column to store the bloom filter bitmap. The bloom filter uses multiple hash functions to set bits based on the string content of the name column.

## Files Created

### 1. `create_table.sql`
Creates the table structure and supporting functions:
- **Table**: `bloom_names` with columns: `id`, `name` (VARCHAR(64)), `bloom` (BIGINT UNSIGNED)
- **Function**: `calculate_bloom()` - Implements 4 hash functions to generate bloom filter bitmap
- **Triggers**: Automatically calculate bloom values on INSERT and UPDATE operations
- **Indexes**: Created on both `bloom` and `name` columns for performance comparison

### 2. `insert_demo.sql`
Demonstrates data insertion and bloom filter calculation:
- Sample INSERT statements with automatic bloom calculation via triggers
- UPDATE examples showing bloom recalculation
- Bulk insert procedure (`insert_test_data()`) to create 10,000 test records
- Statistics queries to analyze collision rates

### 3. `search_bloom.sql`
Implements search operations using bitwise operators:
- **Stored Procedure**: `search_by_bloom()` - Two-phase search (bloom filter + exact match)
- **Bitwise Operations**: Uses `(bloom & search_bloom) = search_bloom` to quickly eliminate non-matches
- Examples of single and batch searches
- False positive analysis

### 4. `performance_test.sql`
Comprehensive performance testing suite with 5 test scenarios:
- **Test 1**: Single name lookup (indexed SELECT vs bloom filter)
- **Test 2**: Multiple name lookups (IN clause vs bloom pre-filtering)
- **Test 3**: Pattern matching with LIKE (full scan vs bloom pre-filter)
- **Test 4**: Full table scan for multiple patterns
- **Test 5**: Non-existent name lookup (shows bloom filter's rejection capability)
- Performance summary with ratios and statistics

## How to Use

### Step 1: Create the table and functions
```sql
SOURCE create_table.sql;
```

### Step 2: Insert sample data
```sql
SOURCE insert_demo.sql;
```

### Step 3: (Optional) Generate bulk test data
```sql
CALL insert_test_data();
```

### Step 4: Test search functionality
```sql
SOURCE search_bloom.sql;
```

### Step 5: Run performance tests
```sql
SOURCE performance_test.sql;
```

## How the Bloom Filter Works

### Hash Functions
The implementation uses 4 different hash functions to set bits in the 64-bit bloom filter:

1. **Sum Hash**: Sum of all character ASCII codes
2. **Product Hash**: Product of character codes (modulo prime)
3. **Position-weighted Hash**: Character code multiplied by position
4. **XOR Hash**: XOR of character code and position

### Bit Setting
Each hash function generates a position (0-63) and sets the corresponding bit using bitwise OR:
```sql
SET bloom_value = bloom_value | (1 << bit_pos);
```

### Search Process
1. Calculate bloom filter for search term
2. Use bitwise AND to check if all search bits are present: `(bloom & search_bloom) = search_bloom`
3. Candidates pass to exact string comparison
4. Eliminates non-matches without string operations

## Performance Characteristics

### Advantages
- **Fast rejection**: Non-matching records eliminated with single bitwise operation
- **Index efficiency**: BIGINT column is faster to index than VARCHAR
- **Memory efficient**: 64-bit bloom filter per record
- **No false negatives**: All actual matches are found

### Trade-offs
- **False positives possible**: Some non-matches pass bloom filter and require exact comparison
- **Limited hash space**: 64 bits means higher collision rate with large datasets
- **Best for**: Large datasets where most searches are for non-existent or rare values

## Expected Results

For a dataset with 10,000+ records:
- Bloom filter typically eliminates 95%+ of non-matching records
- Performance gain is most noticeable for:
  - Non-existent name lookups
  - Pattern matching with LIKE
  - Multiple simultaneous searches
- Traditional indexed SELECT may still be faster for exact matches in small datasets

## Notes
- Collision rate increases with dataset size (64-bit limitation)
- For production use, consider 128-bit or 256-bit bloom filters using multiple BIGINT columns
- Index on `bloom` column is crucial for performance gains

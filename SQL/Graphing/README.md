# FinTech Graphing Queries

Comprehensive SQL queries optimized for data visualization and graphing in FinTech applications.

## 📊 Query Categories

### 📈 Time Series Queries
**TimeSeriesVolume.sql** - Transaction volume trends over time (daily, hourly, weekly, monthly, quarterly)

**TimeSeriesRevenue.sql** - Revenue trends with moving averages, YoY comparison, MoM growth, and cumulative revenue

**TimeSeriesSuccessRate.sql** - Success/failure rates over time, hourly patterns, and status distribution trends

### 🥧 Distribution Queries (Pie & Donut Charts)
**DistributionPaymentMethods.sql** - Payment method usage breakdown, transaction type distribution, status breakdown

**DistributionAmounts.sql** - Transaction amount ranges, account balance distribution, failure reasons, account types

**DistributionGeographic.sql** - Transaction volume by country/state/city, cross-border flows, account distribution

### 📊 Segmentation Queries (Bar & Tree Charts)
**SegmentationCustomers.sql** - Customer value tiers, RFM analysis, transaction frequency segments, account age groups

**SegmentationRevenue.sql** - Revenue by segment, payment method, transaction type, top customers, Pareto analysis

**SegmentationChannels.sql** - Channel performance, device types, OS/browser distribution, acquisition channels

### 📉 Cohort Analysis Queries
**CohortRetention.sql** - Monthly/weekly retention curves, survival analysis, average retention rates

**CohortRevenue.sql** - Cumulative revenue by cohort, LTV projections, transaction frequency evolution

**CohortChurn.sql** - Churn rate trends, survival curves, at-risk customer tracking

### 📊 Histogram Queries
**HistogramAmounts.sql** - Transaction amount distribution with binning, percentiles, log-scale views

**HistogramProcessingTime.sql** - Processing time distribution, settlement time, response time by hour

**HistogramBalances.sql** - Account balance distribution, credit utilization, statistical summaries

**HistogramFrequency.sql** - Transaction frequency per customer, recency distribution, day-of-week patterns

## 🎯 Visualization Types Supported

### Line Charts
- Time series volume and revenue
- Retention curves
- Churn trends
- Moving averages

### Bar Charts
- Customer segmentation
- Revenue breakdown
- Channel performance
- Frequency distribution

### Pie/Donut Charts
- Payment method split
- Transaction type distribution
- Geographic breakdown
- Status distribution

### Area Charts
- Cumulative revenue
- Stacked transaction types
- Cohort performance

### Heatmaps
- Hourly success rates by day
- Transaction patterns
- Response time by hour

### Histograms
- Amount distribution
- Processing time
- Balance distribution
- Frequency patterns

### Scatter Plots
- Transaction amount vs frequency
- Balance vs activity
- Performance metrics

### Treemaps
- Top customers by revenue
- Revenue contribution
- Geographic concentration

## 💡 Key Features

- **Time-bucketed data** for trend analysis
- **Percentage calculations** for pie charts
- **Percentiles and statistics** for distributions
- **Moving averages** for smoothing trends
- **YoY and MoM comparisons** for growth analysis
- **Cohort-based tracking** for retention
- **Binned data** for histograms
- **Top-N queries** for rankings

## 🚀 Usage Guidelines

### For Dashboards
- Use daily/hourly queries for real-time monitoring
- Use monthly/quarterly for executive reports
- Combine multiple queries for comprehensive views

### For Analytics
- Use cohort queries to track user behavior over time
- Use segmentation queries to identify patterns
- Use histogram queries for distribution analysis

### Performance Tips
- Add appropriate date range filters
- Index commonly queried columns (TransactionDate, AccountID)
- Use materialized views for complex aggregations
- Consider partitioning for large tables

## 📋 Common Patterns

### Time Ranges
- Last 7/30/90 days for recent trends
- Last 12/24 months for long-term analysis
- Last 12/26 weeks for medium-term trends

### Aggregation Levels
- Hourly: Intraday patterns
- Daily: Short-term trends
- Weekly: Medium-term patterns
- Monthly: Long-term analysis
- Quarterly: Business reporting

### Grouping
- By customer segment
- By payment method
- By geographic region
- By cohort
- By channel/device

## 🎨 Graphing Library Support

These queries are designed to work with:
- **Chart.js** - Line, bar, pie, doughnut
- **D3.js** - Custom visualizations
- **Plotly** - Interactive charts
- **Recharts** - React charts
- **Highcharts** - Professional charts
- **Power BI / Tableau** - BI tools

## 📝 Notes

- Queries use DATEADD for dynamic date ranges
- Percentage calculations use DECIMAL(5,2) for precision
- NULL handling with NULLIF to avoid division errors
- Window functions for advanced analytics
- CTEs for readable, maintainable code

## 🔧 Customization

Adjust these parameters based on your needs:
- **Bin sizes** for histograms (currently 100, 1000, etc.)
- **Time ranges** for analysis periods
- **Thresholds** for segmentation
- **Top-N limits** for rankings
- **Percentile values** for distribution analysis

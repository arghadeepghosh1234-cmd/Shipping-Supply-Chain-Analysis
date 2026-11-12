# Supply Chain Delivery Performance Analysis

**Why are deliveries late, and how accurate are the delivery promises?**
An end-to-end analysis of 180K order lines (65K orders) from the DataCo Smart Supply Chain dataset, using Python, MySQL and Power BI.

![Dashboard](docs/dashboard.png)

## Key findings

| # | Finding | Evidence |
|---|---------|----------|
| 1 | **57.3% of orders are delivered late.** | 36,048 of 62,897 delivered orders; late orders average 1.6 days past the promise |
| 2 | **Shipping mode drives lateness, not geography.** | First Class 100% late, Second Class 80.0%, Same Day 48.4%, Standard Class 39.9% |
| 3 | **First Class promises 1 day and always takes 2.** | 100% late in all 23 regions and in every year |
| 4 | **Two modes cause most delays.** | First + Second Class are 34.8% of orders but 53.8% of late orders |
| 5 | **Region, market, segment, category and season barely matter.** | Markets 56.6-57.7% late; segments 57.1-57.6%; monthly 55.0-59.9%; no trend across years |
| 6 | **Averages hide the problem.** | Standard Class averages exactly its 4-day promise, yet 39.9% of its orders are late (delivery spreads from 2 to 6 days) |
| 7 | **Cancellations and suspected fraud cost 4.3% of net revenue.** | 1.41M of 33.05M net revenue; 2.1% of orders canceled, 2.3% flagged as suspected fraud |

## Recommendations

1. **Set realistic promises for First and Second Class.** Re-basing First Class to 2 days and Second Class to 4 days (no operational change) cuts the late rate from **57.31% to 34.26%**. Setting each promise to about the 80th percentile of actual transit time brings it to **15.89%**. Trade-off: longer promised times may reduce competitiveness.
2. **Reduce the slow tail in Second and Standard Class.** About 40% of their orders take 5-6 days (19,903 orders, 31.6% of delivered orders). Tightening this spread improves reliability even with promises unchanged.
3. **Track promise accuracy as a standing KPI.** Monitor late rate and the gap between actual and promised days by shipping mode every month, with an alert threshold. An order-level predicted delivery date would beat a fixed promise per shipping mode.

## Approach

1. **Data understanding and cleaning (Python, pandas).** 180,519 rows x 53 columns, one row per order item. Checked duplicates, parsed dates, standardised column names, translated 103 Spanish country names to English, dropped redundant and sensitive columns, and added flags for late, canceled, fraud and in-scope orders (final: 46 columns).
2. **Scope definition.** Delivery is an order-level event, so delivery metrics are computed on one row per order. 7,754 canceled or suspected-fraud rows are flagged (`in_scope = 0`), not deleted: they are excluded from delivery metrics and analysed separately as lost revenue.
3. **EDA (Python).** KPIs, late rate by shipping mode, region, market, segment, category and month, plus revenue and profit.
4. **SQL (MySQL 8).** 25 business questions answered with aggregation, CTEs, window functions and an order-level view, cross-checked against the Python results.
5. **Dashboard (Power BI).** KPI cards, shipping-mode, promised-vs-actual and monthly-trend visuals with market and segment slicers.

## KPI definitions

| KPI | Definition |
|-----|------------|
| Orders | Distinct orders with `in_scope = 1` |
| Late order | Actual shipping days > scheduled shipping days |
| Late rate | Late orders / delivered orders |
| Avg promised / actual days | Mean scheduled / real shipping days per order |
| Net revenue | `Order Item Total` (sales minus discount) |

## Data notes and limitations

- The dataset looks **simulated**: delivery days are close to uniformly distributed within each shipping mode, and region, market, category and segment effects are almost flat. Findings describe this dataset, not real-world logistics performance.
- From **October 2017** the number of items per order drops from about 3 to 1, so monthly revenue trends are not comparable across that break. Order counts stay stable.
- Profit barely differs between on-time and late orders (12.3% vs 11.8% margin), so no profit impact of lateness is claimed.
- `delay_days` and `is_late` are outcome variables. They must not be used as predictors in any model that forecasts delivery (target leakage).
- The what-if scenarios assume actual transit times do not change.
- `tokenized_access_logs.csv` (web clickstream) cannot be joined to orders and is not used.

## Repository structure

```
supply-chain-delivery-performance/
├── README.md
├── notebooks/
│   ├── 01_data_cleaning.ipynb
│   └── 02_eda.ipynb
├── sql/
│   ├── 01_create_table.sql        # schema and indexes
│   └── 02_all_25_queries.sql      # business questions
├── dashboard/
│   ├── supply_chain_dashboard.pbix
│   └── supply_chain_dashboard.pdf
├── docs/
│   └── dashboard.png
└── data/                          # not committed (see below)
```

## How to reproduce

1. Download `DataCoSupplyChainDataset.csv` (Kaggle: "DataCo Smart Supply Chain for Big Data Analysis") and put it in `data/raw/`.
2. Run `notebooks/01_data_cleaning.ipynb` to produce `data/processed/dataco_clean.csv`.
3. Run `sql/01_create_table.sql` in MySQL, load the cleaned CSV into `supply_chain.dataco_clean`, then run `sql/02_all_25_queries.sql`.
4. Open `dashboard/supply_chain_dashboard.pbix` in Power BI Desktop (it reads the `orders_delivery` view from MySQL).

## Tools

Python (pandas, matplotlib, SQLAlchemy), MySQL 8 and Workbench, Power BI Desktop.

## Next steps

- Predict delivery delay per order (a leak-free model using shipping mode, region, order timing and product features) to replace the fixed promise per shipping mode.
- Add a significance test on regional differences to confirm they are noise.

## Author

Arghadeep Ghosh - Data Analytics Consultant
[LinkedIn](https://www.linkedin.com/in/your-profile) | [GitHub](https://github.com/your-username)

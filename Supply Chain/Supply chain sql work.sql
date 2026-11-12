use supply_chain;

select * from dataco_clean;

#Q1: total number of orders
SELECT COUNT(*) AS total_orders, SUM(in_scope) AS in_scope_orders
FROM orders_delivery;

#Q2: total revenue (in scope)
SELECT ROUND(SUM(net_sales), 2) AS net_revenue,
       ROUND(SUM(sales), 2)     AS gross_sales
FROM orders_delivery
WHERE in_scope =1;

#Q3: average actual shipping time
SELECT round(avg(days_real),2) as avg_actual_days 
from orders_delivery where in_scope = 1;

#Q4: average scheduled shipping time
SELECT ROUND(AVG(days_sched), 2) AS avg_scheduled_days
FROM orders_delivery
WHERE in_scope = 1;

#Q5: percentage of shipments delivered late
SELECT COUNT(*) AS orders,
       SUM(is_late) AS late_orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
FROM orders_delivery
WHERE in_scope = 1;

#Q6: how many shipments were delivered on time?
SELECT COUNT(*) AS on_time_or_early_orders
FROM orders_delivery
WHERE in_scope = 1 AND is_late = 0;

SELECT delivery_status,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM orders_delivery
WHERE in_scope = 1
GROUP BY delivery_status
ORDER BY orders DESC;

#Q7: what are the different shipping methods?
SELECT DISTINCT shipping_mode
FROM orders_delivery
ORDER BY shipping_mode;

SELECT shipping_mode, COUNT(*) AS orders
FROM orders_delivery
GROUP BY shipping_mode
ORDER BY orders DESC;

#Q8: which region has the highest number of orders?
SELECT order_region, COUNT(*) AS orders
FROM orders_delivery
GROUP BY order_region
ORDER BY orders DESC
LIMIT 5;

#Q9: which shipping method has the highest late-delivery percentage?
SELECT shipping_mode,
       COUNT(*) AS orders,
       SUM(is_late) AS late_orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
FROM orders_delivery
WHERE in_scope = 1
GROUP BY shipping_mode
ORDER BY late_pct DESC;

#Q10: which regions experience the most delivery delays?
SELECT order_region,
       COUNT(*) AS orders,
       SUM(is_late) AS late_orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
FROM orders_delivery
WHERE in_scope = 1
GROUP BY order_region
ORDER BY late_orders DESC
LIMIT 5;

SELECT order_region,
       COUNT(*) AS orders,
       SUM(is_late) AS late_orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
FROM orders_delivery
WHERE in_scope = 1
GROUP BY order_region
HAVING COUNT(*) >= 1000
ORDER BY late_pct DESC
LIMIT 5;

#Q11: what is the average shipping time for each shipping method?
SELECT shipping_mode,
       ROUND(AVG(days_real), 2)  AS avg_actual_days,
       ROUND(AVG(days_sched), 2) AS avg_scheduled_days
FROM orders_delivery
WHERE in_scope = 1
GROUP BY shipping_mode
ORDER BY avg_actual_days DESC;

#Q12: which product categories experience the most delays?
SELECT category_name,
       COUNT(*) AS items,
       SUM(is_late) AS late_items,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_rate_pct
FROM dataco_clean
WHERE in_scope = 1
GROUP BY category_name
ORDER BY late_items DESC
LIMIT 5;

SELECT category_name,
       COUNT(*) AS items,
       SUM(is_late) AS late_items,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_rate_pct
FROM dataco_clean
WHERE in_scope = 1
GROUP BY category_name
HAVING COUNT(*) >= 1000
ORDER BY late_rate_pct DESC
LIMIT 5;


#Q13: which month has the highest number of delayed deliveries?
SELECT order_month,
       COUNT(*) AS orders,
       SUM(is_late) AS late_orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
FROM orders_delivery
WHERE in_scope = 1
GROUP BY order_month
ORDER BY late_orders DESC
LIMIT 5;

SELECT order_month,
       COUNT(*) AS orders,
       SUM(is_late) AS late_orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
FROM orders_delivery
WHERE in_scope = 1
GROUP BY order_month
ORDER BY late_pct DESC
LIMIT 5;

#Q14: which customer segment generates the most revenue?
SELECT customer_segment,
       COUNT(*) AS orders,
       ROUND(SUM(net_sales), 2) AS net_revenue,
       ROUND(100.0 * SUM(net_sales) / SUM(SUM(net_sales)) OVER (), 1) AS pct_of_revenue
FROM orders_delivery
WHERE in_scope = 1
GROUP BY customer_segment
ORDER BY net_revenue DESC;

#Q15: is there a relationship between shipping duration and delivery delays?
SELECT days_real,
       COUNT(*) AS orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct,
       ROUND(AVG(delay_days), 2) AS avg_delay_days
FROM orders_delivery
WHERE in_scope = 1
GROUP BY days_real
ORDER BY days_real;

SELECT shipping_mode, days_sched, days_real,
       COUNT(*) AS orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
FROM orders_delivery
WHERE in_scope = 1
GROUP BY shipping_mode, days_sched, days_real
ORDER BY shipping_mode, days_real;

#Q16: top 10 regions with the highest late-delivery rates
SELECT order_region,
       COUNT(*) AS orders,
       SUM(is_late) AS late_orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
FROM orders_delivery
WHERE in_scope = 1
GROUP BY order_region
ORDER BY late_pct DESC
LIMIT 10;

#Q17: shipping methods whose actual delivery time exceeds the scheduled time
SELECT shipping_mode,
       ROUND(AVG(days_real), 2)  AS avg_actual_days,
       ROUND(AVG(days_sched), 2) AS avg_scheduled_days,
       ROUND(AVG(days_real) - AVG(days_sched), 2) AS avg_gap_days
FROM orders_delivery
WHERE in_scope = 1
GROUP BY shipping_mode
HAVING AVG(days_real) > AVG(days_sched)
ORDER BY avg_gap_days DESC;

#Q18: average delivery-time difference by region
SELECT order_region,
       COUNT(*) AS orders,
       ROUND(AVG(days_real), 2)  AS avg_actual_days,
       ROUND(AVG(days_sched), 2) AS avg_scheduled_days,
       ROUND(AVG(delay_days), 2) AS avg_diff_days
FROM orders_delivery
WHERE in_scope = 1
GROUP BY order_region
ORDER BY avg_diff_days DESC;

#Q19: regions where revenue is high but delivery performance is poor
WITH region_stats AS (
    SELECT order_region,
           COUNT(*) AS orders,
           ROUND(SUM(net_sales), 2) AS net_revenue,
           ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
    FROM orders_delivery
    WHERE in_scope = 1
    GROUP BY order_region
)
SELECT order_region, orders, net_revenue, late_pct,
       CASE WHEN net_revenue > (SELECT AVG(net_revenue) FROM region_stats)
             AND late_pct > (SELECT ROUND(100.0 * SUM(is_late) / COUNT(*), 2)
                             FROM orders_delivery WHERE in_scope = 1)
            THEN 'High revenue, poor delivery' ELSE '' END AS flag
FROM region_stats
ORDER BY net_revenue DESC;

#Q20: top five product categories with the highest delivery risk
SELECT category_name,
       COUNT(*) AS items,
       SUM(is_late) AS late_items,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_rate_pct
FROM dataco_clean
WHERE in_scope = 1
GROUP BY category_name
HAVING COUNT(*) >= 1000
ORDER BY late_rate_pct DESC
LIMIT 5;

#Q21: monthly delivery performance and seasonal patterns
#Monthly
SELECT order_month,
       COUNT(*) AS orders,
       SUM(is_late) AS late_orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
FROM orders_delivery
WHERE in_scope = 1
GROUP BY order_month
ORDER BY order_month;

#By calendar month across all years
SELECT MONTH(order_month) AS calendar_month,
       COUNT(*) AS orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
FROM orders_delivery
WHERE in_scope = 1
GROUP BY MONTH(order_month)
ORDER BY calendar_month;

#By year:
SELECT YEAR(order_month) AS order_year,
       COUNT(*) AS orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
FROM orders_delivery
WHERE in_scope = 1
GROUP BY YEAR(order_month)
ORDER BY order_year;

#Q22: the biggest operational contributors to late deliveries
WITH mode_stats AS (
    SELECT shipping_mode,
           COUNT(*) AS orders,
           SUM(is_late) AS late_orders
    FROM orders_delivery
    WHERE in_scope = 1
    GROUP BY shipping_mode
)
SELECT shipping_mode, orders, late_orders,
       ROUND(100.0 * orders / SUM(orders) OVER (), 1)           AS pct_of_orders,
       ROUND(100.0 * late_orders / SUM(late_orders) OVER (), 1) AS pct_of_late_orders,
       ROUND(100.0 * late_orders / orders, 2)                   AS late_pct
FROM mode_stats
ORDER BY late_orders DESC;

#Q23: compare shipping performance across regions and shipping methods
SELECT order_region,
       ROUND(100 * AVG(CASE WHEN shipping_mode = 'First Class'    THEN is_late END), 1) AS first_class,
       ROUND(100 * AVG(CASE WHEN shipping_mode = 'Second Class'   THEN is_late END), 1) AS second_class,
       ROUND(100 * AVG(CASE WHEN shipping_mode = 'Same Day'       THEN is_late END), 1) AS same_day,
       ROUND(100 * AVG(CASE WHEN shipping_mode = 'Standard Class' THEN is_late END), 1) AS standard_class
FROM orders_delivery
WHERE in_scope = 1
GROUP BY order_region
ORDER BY order_region;

#Q24: do certain shipping methods consistently underperform?
SELECT shipping_mode,
       ROUND(100 * AVG(CASE WHEN YEAR(order_month) = 2015 THEN is_late END), 1) AS y2015,
       ROUND(100 * AVG(CASE WHEN YEAR(order_month) = 2016 THEN is_late END), 1) AS y2016,
       ROUND(100 * AVG(CASE WHEN YEAR(order_month) = 2017 THEN is_late END), 1) AS y2017,
       ROUND(100 * AVG(CASE WHEN YEAR(order_month) = 2018 THEN is_late END), 1) AS y2018
FROM orders_delivery
WHERE in_scope = 1
GROUP BY shipping_mode
ORDER BY shipping_mode;

#check by region, ranking the four methods within each region
WITH r AS (
    SELECT order_region, shipping_mode, 100.0 * AVG(is_late) AS late_pct
    FROM orders_delivery
    WHERE in_scope = 1
    GROUP BY order_region, shipping_mode
),
ranked AS (
    SELECT order_region, shipping_mode, late_pct,
           RANK() OVER (PARTITION BY order_region ORDER BY late_pct DESC) AS rnk
    FROM r
)
SELECT shipping_mode,
       SUM(rnk = 1) AS regions_where_worst,
       SUM(rnk = 4) AS regions_where_best,
       COUNT(*)     AS regions
FROM ranked
GROUP BY shipping_mode
ORDER BY regions_where_worst DESC;

#Q25 a)what-if on delivery promises|
#Scenario 1: First Class promise 1 → 2 days, and Second Class promise 2 → 4 days.
SELECT shipping_mode,
       COUNT(*) AS orders,
       SUM(is_late) AS late_now,
       SUM(CASE WHEN days_real > CASE shipping_mode
                WHEN 'First Class' THEN 2
                WHEN 'Second Class' THEN 4
                ELSE days_sched END THEN 1 ELSE 0 END) AS late_scenario_1,
       SUM(CASE WHEN days_real > CASE shipping_mode
                WHEN 'First Class' THEN 2
                WHEN 'Second Class' THEN 5
                WHEN 'Standard Class' THEN 5
                WHEN 'Same Day' THEN 1 END THEN 1 ELSE 0 END) AS late_scenario_2
FROM orders_delivery
WHERE in_scope = 1
GROUP BY shipping_mode
ORDER BY shipping_mode;

# Scenario 2: First Class 2, Second Class 5, Standard Class 5 and Same Day 1.

SELECT COUNT(*) AS orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct_now,
       ROUND(100.0 * SUM(CASE WHEN days_real > CASE shipping_mode
                WHEN 'First Class' THEN 2
                WHEN 'Second Class' THEN 4
                ELSE days_sched END THEN 1 ELSE 0 END) / COUNT(*), 2) AS scenario_1_pct,
       ROUND(100.0 * SUM(CASE WHEN days_real > CASE shipping_mode
                WHEN 'First Class' THEN 2
                WHEN 'Second Class' THEN 5
                WHEN 'Standard Class' THEN 5
                WHEN 'Same Day' THEN 1 END THEN 1 ELSE 0 END) / COUNT(*), 2) AS scenario_2_pct
FROM orders_delivery
WHERE in_scope = 1;

#Q25 b)how many orders take 5 to 6 days?
SELECT shipping_mode,
       COUNT(*) AS orders,
       SUM(CASE WHEN days_real >= 5 THEN 1 ELSE 0 END) AS orders_5_to_6_days,
       ROUND(100.0 * SUM(CASE WHEN days_real >= 5 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_5_to_6_days
FROM orders_delivery
WHERE in_scope = 1
GROUP BY shipping_mode
ORDER BY shipping_mode;

#Q25 c) cancellations and fraud
SELECT ROUND(100.0 * COUNT(DISTINCT CASE WHEN is_canceled = 1 THEN order_id END) / COUNT(DISTINCT order_id), 2) AS cancel_pct,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN is_suspected_fraud = 1 THEN order_id END) / COUNT(DISTINCT order_id), 2) AS fraud_pct,
       ROUND(SUM(CASE WHEN in_scope = 0 THEN order_item_total END), 2) AS lost_revenue
FROM dataco_clean;
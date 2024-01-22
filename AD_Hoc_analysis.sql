SELECT distinct(market)
FROM dim_customer
WHERE customer="Atliq Exclusive" AND region ='APAC';

 WITH 2020_ AS (SELECT COUNT(distinct(product_CODE)) AS UNIQUE_PRODUCT_2020
FROM fact_sales_monthly
WHERE fiscal_year=2020),
2021_ AS (SELECT COUNT(distinct(product_CODE)) AS UNIQUE_PRODUCT_2021
FROM fact_sales_monthly
WHERE fiscal_year=2021)

select UNIQUE_PRODUCT_2020,UNIQUE_PRODUCT_2021,
round(((UNIQUE_PRODUCT_2021-UNIQUE_PRODUCT_2020)*100/UNIQUE_PRODUCT_2020),1) as percentage_Change
from 2020_ , 2021_;

SELECT segment ,count(distinct(product_code)) as product_count
FROM dim_product
group by segment 
order by product_count desc;


with fy20 as (SELECT segment,count(distinct(p.product_code)) as product_count_2020
FROM dim_product p
join fact_sales_monthly f
on p.product_code=f.product_code
where fiscal_year=2020
group by p.segment),
fy21 as (SELECT segment,count(distinct(p.product_code)) as product_count_2021
FROM dim_product p
join fact_sales_monthly f
on p.product_code=f.product_code
where fiscal_year=2021
group by p.segment)

 SELECT F.segment,F.PRODUCT_COUNT_2020,U.PRODUCT_COUNT_2021,U.PRODUCT_COUNT_2021-F.PRODUCT_COUNT_2020 AS DIFFERENCE
FROM FY20 F
JOIN FY21 U
ON F.segment=U.segment
ORDER BY DIFFERENCE desc;



SELECT c.customer_code,c.customer,f.pre_invoice_discount_pct*100
FROM dim_customer c
JOIN fact_pre_invoice_deductions f
on c.customer_code=f.customer_code
where fiscal_year=2021 and c.market='India'
order by pre_invoice_discount_pct desc
limit 5;

WITH sales AS (SELECT date, fm.customer_code, fp.fiscal_year, gross_price * sold_quantity AS gross_sales
 FROM fact_gross_price fp
JOIN fact_sales_monthly fm
ON fm.product_code = fp.product_code
AND fm.fiscal_year = fp.fiscal_year),
customer AS (SELECT date, c.customer_code, gross_sales 
FROM sales s
JOIN dim_customer c
ON s.customer_code = c.customer_code
WHERE customer = "Atliq Exclusive")
        
SELECT MONTH(date) AS Month, YEAR(date) AS Year, ROUND(SUM(gross_sales) / 1000000, 2) AS Gross_sales_Amount_mln 
FROM customer
GROUP BY Month, Year
order by year,Month;


WITH quarter AS (
    SELECT sold_quantity,
        CASE
            WHEN MONTH(date) BETWEEN 09 AND 11 THEN "Q1"
            WHEN MONTH(date) IN (12, 01, 02) THEN "Q2"
            WHEN MONTH(date) BETWEEN 03 AND 05 THEN "Q3"
            WHEN MONTH(date) BETWEEN 06 AND 08 THEN "Q4"
        END as Quarter
    FROM fact_sales_monthly
        WHERE fiscal_year = 2020)

SELECT Quarter, SUM(sold_quantity) AS total_sold_quantity FROM quarter
    GROUP BY Quarter
    ORDER BY total_sold_quantity DESC;
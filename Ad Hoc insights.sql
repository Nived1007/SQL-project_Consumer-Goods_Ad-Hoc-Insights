

#Task 1
select distinct(market) from dim_customer where region = "APAC" and  customer= "Atliq Exclusive";


#Task 2
WITH cte1 AS (
    SELECT COUNT(DISTINCT product_code) AS unique_products_2020
    FROM fact_sales_monthly s
    JOIN dim_product p USING(product_code)
    WHERE fiscal_year = 2020
),
cte2 AS (
    SELECT COUNT(DISTINCT product_code) AS unique_products_2021
    FROM fact_sales_monthly s
    JOIN dim_product p USING(product_code)
    WHERE fiscal_year = 2021
)

SELECT *, ((unique_products_2021-unique_products_2020)/unique_products_2020 * 100) as percentage_change
FROM cte1, cte2;


#Task 3
SELECT segment,count(distinct(product_code)) as prodcut_count FROM dim_product group by segment;


#Task 4
with cte3 as
(SELECT segment , COUNT(DISTINCT product_code) AS products_2021
FROM fact_sales_monthly s
JOIN dim_product p USING(product_code) 
WHERE fiscal_year = 2021
group by segment ),

cte4 as
(SELECT segment , COUNT(DISTINCT product_code) AS products_2020
FROM fact_sales_monthly s
JOIN dim_product p USING(product_code) 
WHERE fiscal_year = 2020
group by segment )

select segment,products_2020,products_2021 , 
(products_2021 - products_2020 ) as difference
from cte3 join cte4 using(segment);


#Task 5
SELECT
    product_code,
    product,
    manufacturing_cost AS manufacturing_cost
FROM
    fact_manufacturing_cost
    JOIN dim_product USING (product_code)
WHERE
    manufacturing_cost = (SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost)
UNION
SELECT
    product_code,
    product,
    manufacturing_cost AS min_manufacturing_cost
FROM
    fact_manufacturing_cost
    JOIN dim_product USING (product_code)
WHERE
    manufacturing_cost = (SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost);


#Task 6
with cte as
(SELECT customer_code,avg(pre_invoice_discount_pct) as avgpct
FROM fact_pre_invoice_deductions where fiscal_year =2021 
group by customer_code)

select customer,customer_code,round(avgpct*100,2) as pre_invoice_discount_pct
from  cte join dim_customer using (customer_code) where market = "India"
order by avgpct desc limit 5; 


#Task 7
with cte as
(SELECT `month`(date) as month,fiscal_year as year ,sold_quantity*gross_price as gross_sales FROM 
fact_sales_monthly s join fact_gross_price 
using (product_code,fiscal_year)
join dim_customer
using(customer_code)
where customer = 'Atliq Exclusive' )

select month,year,concat(round(sum(gross_sales)/1000000,2)," M") as gross_sales
from cte
group by year,month;


#Task 8
with cte as
(SELECT fiscal_year,`get_fiscal_quarter`(date) as quarter,sold_quantity FROM gdb023.fact_sales_monthly)
select quarter,concat(round(sum(sold_quantity)/1000000,2)," M")  as total_sold_quantity from cte where fiscal_year=2021
group by quarter;


#Task 9
with cte as
(select channel,sold_quantity*gross_price as gross_sales FROM 
fact_sales_monthly s join fact_gross_price 
using (product_code,fiscal_year)
join dim_customer
using(customer_code)
where fiscal_year=2021),
cte1 as
(select channel,sum(gross_sales) as gross_sales from cte group by channel)
select channel,gross_sales,(gross_sales*100/sum(gross_sales)over()) as percentage from cte1;


#Task 10
with cte as
(SELECT product_code,sum(sold_quantity) as total_qty FROM fact_sales_monthly 
join dim_product using(product_code) group by product_code),
cte1 as
(select product_code,product,division, total_qty,
DENSE_RANK() OVER (PARTITION BY division ORDER BY total_qty DESC) AS DenseRank 
 from cte join dim_product using(product_code) )
 select * from cte1 where DenseRank <=3;


 
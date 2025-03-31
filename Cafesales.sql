Use Coffee_Data;
select *
from shop
order by 1,2;

-- transactions per day
SELECT
    DAYNAME(transaction_date) AS day_of_week,HOUR(transaction_time) AS hour,
    SUM(CASE WHEN store_location = 'Lower Manhattan' THEN transaction_qty ELSE 0 END) AS 'Lower Manhattan',
    SUM(CASE WHEN store_location = "Hell's Kitchen" THEN transaction_qty ELSE 0 END) AS "Hell's Kitchen",
    SUM(CASE WHEN store_location = 'Astoria' THEN transaction_qty ELSE 0 END) AS "Astoria"
FROM shop
GROUP BY day_of_week, hour
ORDER BY day_of_week asc;

-- transactions per month
SELECT 
    MONTH(transaction_date) AS Month, 
    COUNT(*) AS Transactions,
        round((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM shop),2) AS transaction_percentage,
    Sum(unit_price) AS Profit,
            round((SUM(unit_price) * 100.0) / (SELECT sum(unit_price) FROM shop), 2) AS profit_percentage

FROM shop
GROUP BY Month
ORDER BY Month;


-- transactions per hour
SELECT 
    HOUR(transaction_time) AS hour, 
    COUNT(*) AS Transactions, 
    round((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM shop),2) AS transaction_percentage,
    round(SUM(unit_price),2) as Profit,
    round((SUM(unit_price) * 100.0) / (SELECT sum(unit_price) FROM shop), 2) AS profit_percentage
FROM shop
GROUP BY HOUR(transaction_time)
ORDER BY hour;




-- self join - profit per product per store
select p1.product_category, SUM(p1.unit_price * p1.transaction_qty) AS Lower_Manhattan,
    SUM(p2.unit_price * p2.transaction_qty) AS Hell_Location,
    SUM(p3.unit_price * p3.transaction_qty) AS Astoria
    from shop as p1
    left join shop as p2 on p1.product_category = p2.product_category 
    and p1.store_location = "Lower Manhattan"
    left join shop as p3 on p2.product_category = p3.product_category
and p2.store_location = 'Hell\'s Kitchen'
    where p3.store_location = "Astoria"
    group by p1.product_category;
    


-- Product popularity
select store_location, product_detail, round(SUM(unit_price),2) as Profit,   sum(transaction_qty) as Amount_sold, unit_price
from shop
group by store_location, product_detail, unit_price
order by Amount_sold desc
Limit 10;

select store_location, product_detail, round(SUM(unit_price),2) as Profit,  sum(transaction_qty) as Amount_sold, unit_price
from shop
group by store_location, product_detail, unit_price
order by Amount_sold asc
Limit 10;


-- customer loyalty
SELECT 
    product_detail, 
    store_location, 
    product_category, 
    transaction_qty
FROM shop
GROUP BY transaction_qty, product_detail, store_location, product_category
ORDER BY transaction_qty DESC
LIMIT 10;

-- correlation equation
    SELECT 
    (SUM(transaction_qty * unit_price) - SUM(transaction_qty) * SUM(unit_price) / COUNT(*)) /
    (SQRT(SUM(transaction_qty * transaction_qty) - SUM(transaction_qty) * SUM(transaction_qty) / COUNT(*)) * 
     SQRT(SUM(unit_price * unit_price) - SUM(unit_price) * SUM(unit_price) / COUNT(*))) 
    AS correlation
FROM shop;

-- Windows
SELECT distinct
    store_location,
    transaction_date,
    SUM(transaction_qty * unit_price) OVER (
        PARTITION BY store_location 
        
    ) AS running_total_revenue
FROM shop
    order by running_total_revenue 
;

-- product analysis
SELECT 
    product_detail, 
    SUM(transaction_qty) AS total_sold, 
    AVG(unit_price) OVER () AS avg_unit_price
FROM shop
GROUP BY product_detail
ORDER BY total_sold DESC
LIMIT 10;

-- correlation between amount sold and unit_price
select product_detail, unit_price, sum(transaction_qty) as Amount_sold
from shop
group by product_detail, unit_price;

select product_category, Sum(unit_price) AS Profit, EXTRACT(Month FROM transaction_date) as month
from shop
group by month, product_category
order by month desc;

#1. Import the dataset and do usual exploratory analysis steps like checking the structure & characteristics of the dataset:  
 #1.1
select * from `Target_Ecommerce_SQL.customers`
limit 8;

select * from `Target_Ecommerce_SQL.geolocation`
limit 3;

  #1.2. Get the time range between which the orders were placed.

select min(order_purchase_timestamp) as start_time,max(order_purchase_timestamp) as end_time
from `Target_Ecommerce_SQL.orders`;

  #1.3. Display the Cities & States of customers who ordered during the given period (year 2018 and month between 1 and 3 )

select distinct c.customer_state,c.customer_city
from `Target_Ecommerce_SQL.orders` as o
join `Target_Ecommerce_SQL.customers` as c
on c.customer_id=o.customer_id
where extract(year from o.order_purchase_timestamp)=2018 and extract(month from o.order_purchase_timestamp) between 1 and 3
order by c.customer_state;
---------------------------------------------------------------------------------------------------------------------------------------------------

#2. In-depth Exploration: 

#2.1 Is there a growing trend in the no. of orders placed over the past years? 

select extract(year from order_purchase_timestamp) as year,count(order_id) as total_orders from `Target_Ecommerce_SQL.orders`
group by extract(year from order_purchase_timestamp)
order by year desc;

#2.2 Can we see some kind of monthly seasonality in terms of the no. of orders being placed? 
select extract(month from order_purchase_timestamp) as month,count(order_id) as total_orders from `Target_Ecommerce_SQL.orders`
group by extract(month from order_purchase_timestamp)
order by total_orders desc;

#2.3 During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night) 1) 0-6 hrs : Dawn, 2) 7-12 hrs : Mornings, 3) 13-18 hrs : Afternoon, 4) 19-23 hrs : Night 

select case 
         when extract(hour from o.order_purchase_timestamp) between 0 and 6 then "Dawn"
         when extract(hour from o.order_purchase_timestamp) between 7 and 12 then "Mornings"
         when extract(hour from o.order_purchase_timestamp) between 13 and 18 then "Afternoon"
         else "Night"
         end as time_of_the_day, count(o.order_id) as total_orders
from `Target_Ecommerce_SQL.orders` as o
group by time_of_the_day
order by total_orders desc;
-------------------------------------------------------------------------------------------------------------------------------------------------------------

#3 Evolution of E-commerce orders in the Brazil region: 
   #3.1 Get the month on month no. of orders placed in each state. 
select c.customer_state as state,extract(month from o.order_purchase_timestamp) as month, count(o.order_id) as total_orders from `Target_Ecommerce_SQL.orders` as o
join `Target_Ecommerce_SQL.customers` as c
on o.customer_id=c.customer_id
group by month,state
order by state,month;

  #3.2. How are the customers distributed across all the states? 

select customer_state as state, count(distinct customer_id) as total_customers from `Target_Ecommerce_SQL.customers`
group by state
order by total_customers desc;
--------------------------------------------------------------------------------------------------------------------------------------------

#4. Impact on Economy: Analyze the money movement by e-commerce by looking at order prices, freight and others. 

  #4.1 Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only). You can use the "payment_value" column in the   payments table to get the cost of orders. 

#step 1: Calculating total payments per year 

With yearly_totals as ( select extract (year from o.order_purchase_timestamp)as year, sum(p.payment_value) as total_payment from `Target_Ecommerce_SQL.payments` as p 
join `Target_Ecommerce_SQL.orders` as o 
on p.order_id= o.order_id 
where extract (year from o.order_purchase_timestamp) in (2017,2018) and extract (month from o.order_purchase_timestamp) between 1 and 8 
group by extract (year from o.order_purchase_timestamp) ),
 
#step 2: using LEAD window function to compare each year's payments with the previous year
 
yearly_comparisons as ( select year, total_payment,

lead(total_payment) over (order by year desc) as prev_year_payment

from yearly_totals )

#STEP 3: Calculate % increase

select round(((total_payment -prev_year_payment) / prev_year_payment)*100,2) from yearly_comparisons ;


  #4.2. Calculate the Total & Average value of order price, frieght value for each state.
  select c.customer_state as state,round(sum(order_items.price)) as total_price,round(avg(order_items.price)) as avg_price,round(sum(order_items.freight_value)) as total_freight,round(avg(order_items.freight_value)) as avg_freight from `Target_Ecommerce_SQL.customers` as c  
left join `Target_Ecommerce_SQL.orders` as order_db
on order_db.customer_id=c.customer_id
left join `Target_Ecommerce_SQL.order_items` as order_items
on order_items.order_id=order_db.order_id
group by c.customer_state
order by total_price;

------------------------------------------------------------------------------------------------------------------------------------------------------------
#5. Analysis based on sales, freight and delivery time. 

  # 5.1. Find the no. of days taken to deliver each order from the order’s purchase date as delivery time. Also, calculate the difference (in days) between the estimated & actual delivery date of an order. Do this in a single query. You can calculate the delivery time and the difference between the estimated & actual delivery date using the given formula: time_to_deliver = order_delivered_customer_date - order_purchase_timestamp,  diff_estimated_delivery = order_delivered_customer_date - order_estimated_delivery_date 

select order_id,order_status,date_diff(order_delivered_customer_date, order_purchase_timestamp, day) as time_to_deliver, date_diff(order_delivered_customer_date, order_estimated_delivery_date, day) as diff_estimated_delivery from `Target_Ecommerce_SQL.orders`
order by order_id;


  #5.2. Find out the top 5 states with the highest & lowest average freight value.

  #top 5 heighest
select customer_state as state, round(avg(order_items.freight_value)) as avg_freight from `Target_Ecommerce_SQL.customers` as c 
left join `Target_Ecommerce_SQL.orders` as order_db
on order_db.customer_id=c.customer_id
left join `Target_Ecommerce_SQL.order_items` as order_items
on order_items.order_id=order_db.order_id
group by state
order by avg_freight desc
limit 5;

  #top 5 lowest

select customer_state as state, round(avg(order_items.freight_value)) as avg_freight from `Target_Ecommerce_SQL.customers` as c 
left join `Target_Ecommerce_SQL.orders` as order_db
on order_db.customer_id=c.customer_id
left join `Target_Ecommerce_SQL.order_items` as order_items
on order_items.order_id=order_db.order_id
group by state
order by avg_freight asc
limit 5;



  #5.3 Find out the top 5 states with the highest & lowest average delivery time. 

  #Top 5 heighest avg delivery time
select customer_state as state, round(avg(date_diff(order_delivered_customer_date, order_purchase_timestamp, day))) as time_to_deliver from `Target_Ecommerce_SQL.customers` as c 
left join `Target_Ecommerce_SQL.orders` as order_db
on order_db.customer_id=c.customer_id
left join `Target_Ecommerce_SQL.order_items` as order_items
on order_items.order_id=order_db.order_id
group by state
order by time_to_deliver desc
limit 5;

  #Top 5 lowest avg delivery time
select customer_state as state, round(avg(date_diff(order_delivered_customer_date, order_purchase_timestamp, day))) as time_to_deliver from `Target_Ecommerce_SQL.customers` as c 
left join `Target_Ecommerce_SQL.orders` as order_db
on order_db.customer_id=c.customer_id
left join `Target_Ecommerce_SQL.order_items` as order_items
on order_items.order_id=order_db.order_id
group by state
order by time_to_deliver asc
limit 5;



  #5.4 Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery. You can use the difference between the averages of actual & estimated delivery date to figure out how fast the delivery was for each state. 

select customer_state as state,round(avg(date_diff(order_delivered_customer_date, order_estimated_delivery_date, day))) as diff_estimated_delivery from `Target_Ecommerce_SQL.customers` as c
left join `Target_Ecommerce_SQL.orders` as order_db
on order_db.customer_id=c.customer_id
group by state
order by diff_estimated_delivery asc
limit 5;
----------------------------------------------------------------------------------------------------------------------------------------------

#6. Analysis based on the payments: 
  #6.1. Find the month on month no. of orders placed using different payment types. 

select pay.payment_type, extract (year from order_db.order_purchase_timestamp) as Purchased_year,extract (month from order_db.order_purchase_timestamp) as Purchased_month, count(distinct order_db.order_id) as total_orders from `Target_Ecommerce_SQL.orders` as order_db
left join `Target_Ecommerce_SQL.payments` as pay
on order_db.order_id=pay.order_id
group by payment_type,Purchased_year,purchased_month
order by payment_type,Purchased_year,purchased_month;

#6.2. Find the no. of orders placed on the basis of the payment installments that have been paid. 

select payment_installments ,count(distinct order_id) as total_orders from `Target_Ecommerce_SQL.payments`
group by payment_installments
order by payment_installments;

-------------------------------------------------------------------------------------------------------

#7. Identify cities with demand (Customers) but no local supply (Sellers).
#Use Case:we can Target these cities for seller acquisition to lower freight costs.

select customer_city, customer_state 
from `Target_Ecommerce_SQL.customers`
except distinct
select seller_city, seller_state 
from `Target_Ecommerce_SQL.sellers`
order by customer_state, customer_city;


#8. Identify "Golden Cities" where both customers and sellers are present.
select customer_city, customer_state 
from `Target_Ecommerce_SQL.customers`
intersect distinct
select seller_city, seller_state 
from `Target_Ecommerce_SQL.sellers`
order by customer_state, customer_city;




-------------------------------------------------------------------------------------------------------------

#9. Products popular in SP but NOT in RJ.
  #List A: Products sold in São Paulo

select `product category`
from `Target_Ecommerce_SQL.orders` o
join `Target_Ecommerce_SQL.customers` c on o.customer_id = c.customer_id
join `Target_Ecommerce_SQL.order_items` oi on o.order_id = oi.order_id
join `Target_Ecommerce_SQL.products` p on oi.product_id = p.product_id
where c.customer_state = 'SP'

except distinct

 #List B: Products sold in Rio de Janeiro
select `product category`
from `Target_Ecommerce_SQL.orders` o
join `Target_Ecommerce_SQL.customers` c on o.customer_id = c.customer_id
join `Target_Ecommerce_SQL.order_items` oi on o.order_id = oi.order_id
join `Target_Ecommerce_SQL.products` p on oi.product_id = p.product_id
where c.customer_state = 'RJ';


--------------------------------------------------------------------------------------------------------
#10. Find customers who bought BOTH 'Furniture' AND 'Bed & Bath' products.

select c.customer_unique_id
from `Target_Ecommerce_SQL.orders` o
join `Target_Ecommerce_SQL.customers` c on o.customer_id = c.customer_id
join `Target_Ecommerce_SQL.order_items` oi on o.order_id = oi.order_id
join `Target_Ecommerce_SQL.products` p on oi.product_id = p.product_id
where lower(p.`product category`) = 'furniture decoration'

intersect distinct  

select c.customer_unique_id
from `Target_Ecommerce_SQL.orders` o
join `Target_Ecommerce_SQL.customers` c on o.customer_id = c.customer_id
join `Target_Ecommerce_SQL.order_items` oi on o.order_id = oi.order_id
join `Target_Ecommerce_SQL.products` p on oi.product_id = p.product_id
where lower(p.`product category`) = 'bed table bath';

-------------------------------------------------------------------------------------------------------------

#11. Identify cities suitable for "Same-Day Delivery" (High Supply & Demand).

select customer_city, customer_state 
from `Target_Ecommerce_SQL.customers`

intersect distinct

select seller_city, seller_state 
from `Target_Ecommerce_SQL.sellers`
order by customer_state, customer_city;

#11.1 count(cities) with customer and seller demand
 
with demand_cities as (select customer_city, customer_state 
from `Target_Ecommerce_SQL.customers`

intersect distinct

select seller_city, seller_state 
from `Target_Ecommerce_SQL.sellers`
order by customer_state, customer_city)

select count(*) as total_demand_cities from demand_cities;

-------------------------------------------------------------------------------------------------------------

#12. Identify cities with Demand (Customers) but No Supply (Sellers).

select customer_city, customer_state 
from `Target_Ecommerce_SQL.customers`

except distinct

select seller_city, seller_state 
from `Target_Ecommerce_SQL.sellers`
order by customer_state, customer_city;

#12.1 supply gap (cities count)

with supply_gap as (select customer_city, customer_state 
from `Target_Ecommerce_SQL.customers`

except distinct

select seller_city, seller_state 
from `Target_Ecommerce_SQL.sellers`
order by customer_state, customer_city)

select count(*) from supply_gap;
----------------------------------------------------------------------------------------------------------------------
#13. Create a unified "VIP List" of the top 20 Spenders and top 20 Earners.
 # Top 20 Customers by Spend
(SELECT 
    c.customer_unique_id AS user_id,
    'VIP Customer' AS user_type,
    ROUND(SUM(p.payment_value), 2) AS total_value,
    c.customer_state AS location
FROM `Target_Ecommerce_SQL.customers` c
JOIN `Target_Ecommerce_SQL.orders` o ON c.customer_id = o.customer_id
JOIN `Target_Ecommerce_SQL.payments` p ON o.order_id = p.order_id
GROUP BY user_id, location
ORDER BY total_value DESC
LIMIT 20)

UNION ALL  

 # Top 20 Sellers by Sales
(SELECT 
    s.seller_id AS user_id,
    'Top Seller' AS user_type,
    ROUND(SUM(oi.price), 2) AS total_value,
    s.seller_state AS location
FROM `Target_Ecommerce_SQL.sellers` s
JOIN `Target_Ecommerce_SQL.order_items` oi ON s.seller_id = oi.seller_id
GROUP BY user_id, location
ORDER BY total_value DESC
LIMIT 20);





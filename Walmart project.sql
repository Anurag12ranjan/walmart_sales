select * from walmart;

--
select count(*) from walmart;

select 
 payment_method,
 count(*)
from walmart
group by payment_method;

select
  count(distinct branch)
from walmart;

select 
max(quantity)
from walmart;

-- Business Problems
-- Q1. Find different payment method and number of transactions and number qty sold
select
  payment_method,
  count(*) as no_of_transactions,
  sum(quantity) as no_qty_sold
from walmart
group by payment_method;

-- Q2. Identify the highest rated category in each branch displaying the branch, category
-- Avg Rating
select *
from(
select 
  branch,
  category,
  avg(rating) as avg_rating,
  rank()over(partition by branch order by avg(rating) desc) as rank
from walmart
group by 1, 2
)
where rank = 1;

--Q3. Identify the busiest day for each branch based on the number of transactions
select *
from(
select 
  branch,
  to_char(to_date(date, 'DD/MM/YY'), 'Day') as day_name,
  count(*) as no_of_transactions,
  rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by 1, 2
)
where rank = 1;

-- Q4. Calculate the total 	quantity of item sold per payment method. list payment_method and toatl quantity
select 
 payment_method,
 sum(quantity) as total_quantity
from walmart
group by payment_method;

-- Q5. Determine the average, minimum, and maxium rating of products for each city
-- list the city, average_rating, min_rating, and max_rating
select 
  city,
  category,
  avg(rating) as avg_rating,
  max(rating) as max_rating,
  min(rating) as min_rating
from walmart
group by 1, 2;

-- Q6. Calculate the total profit for each category by considering total_profit as 
-- (unit_price * quantity * profit_margin). list category and total_profit, ordered from highest to lowest profit
select 
  category,
  sum(total) as revenue,
  sum(total * profit_margin) as profit
from walmart
group by 1
order by 2 desc;

-- Q7. Determine the most common payment method for each branch. display, branch and the preferrred_payment_method
with cte
as(
select 
  branch,
  payment_method,
  count(*) as total_trans,
  rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by 1, 2
)
select * from cte
where rank = 1;

-- Q8. categorize sales into three groups morning, evening, afternoon
-- find out which of the shift and number of invoices
select 
    branch,
case 
     when extract(hour from (time::time)) < 12 then 'Morning'
	 when extract(hour from (time::time)) between 12 and 17 then 'Afternoon'
	 else 'Evening'
  end day_name,
  count(*) as total_invoices
from walmart
group by 1, 2
order by 1, 3;

-- Q9. identify the 5 branches with highest decrese ratio in revenue compare to the last
-- year (current year 2023 and last year 2022)
with revenue_2022
as
(
    select
	    branch,
		sum(total) as revenue
	from walmart
	where extract(year from to_date(date, 'DD/MM/YY')) = 2022
	group by 1
),
revenue_2023
as
 (select
	    branch,
		sum(total) as revenue
	from walmart
	where extract(year from to_date(date, 'DD/MM/YY')) = 2023
	group by 1
)
select 
    ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	round(
         (ls.revenue - cs.revenue)::numeric/
		 ls.revenue::numeric * 100, 2) as rev_dec_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch = cs.branch
where 
    ls.revenue > cs.revenue
order by 4 desc
limit 5;
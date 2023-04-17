-- create database case2;
use case2;

select * from regions;
select * from customer_nodes limit 10;
select * from customer_transactions limit 10;


-- How many different nodes make up the Data Bank network?

select count(distinct node_id) from customer_nodes;


-- How many nodes are there in each region?

select region_id,count(node_id) from customer_nodes group by region_id;


-- How many customers are divided among the regions?

select region_id,count(distinct customer_id) from customer_nodes group by region_id;

-- Determine the total amount of transactions for each region name.

select cn.region_id,sum(ct.txn_amount) from customer_transactions ct
join customer_nodes cn
on ct.customer_id = cn.customer_id
group by cn.region_id;

-- How long does it take on an average to move clients to a new node?

-- select 

-- What is the unique count and total amount for each transaction type?

select txn_type,count(distinct txn_amount), sum(txn_amount) from customer_transactions
group by txn_type;

-- What is the average number and size of past deposits across all customers?
select round(count(customer_id)/(select count(distinct customer_id) from customer_transactions),2) as avg_count from customer_transactions
where txn_type = 'deposit' ;


-- For each month - how many Data Bank customers make more than 1 deposit and at least either 1 purchase or 1 withdrawal in a single month?


with temp_cte as (
 select customer_id, month(txn_date) month_of_txn ,
sum(case when txn_type = "deposit" then 1 else 0 end) as count_deposit,
sum(case when txn_type = "withdrawal" then 1 else 0 end) as count_withdrawal,
sum(case when txn_type = "purchase" then 1 else 0 end) as count_purchase
from customer_transactions
)

select month_of_txn, count(*) from temp_cte
where count_deposite>1 and (count_purchase>1 or count_withdrawal>1)
group by month_of_txn;

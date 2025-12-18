

 create database financial_risk_db;
 use  financial_risk_db;
 
 CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    age INT,
    gender enum('Male','Female','others'),
    region VARCHAR(50),
    customer_segment VARCHAR(50)
);
 INSERT INTO customers VALUES
(1, 'Ravi Kumar', 35, 'Male', 'South', 'Retail'),
(2, 'Ananya Sharma', 29, 'Female', 'North', 'Retail'),
(3, 'Suresh Patel', 45, 'Male', 'West', 'Corporate'),
(4, 'Meena Iyer', 40, 'Female', 'South', 'Retail'),
(5, 'Arjun Singh', 50, 'Male', 'East', 'Corporate');

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(50),
    balance DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO accounts VALUES
(101, 1, 'Savings', 150000),
(102, 2, 'Savings', 80000),
(103, 3, 'Current', 500000),
(104, 4, 'Savings', 120000),
(105, 5, 'Current', 900000);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_date DATE,
    transaction_type VARCHAR(50),
    amount DECIMAL(12,2),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

INSERT INTO transactions VALUES
(1001, 101, '2024-01-05', 'Credit', 50000),
(1002, 101, '2024-01-15', 'Debit', 20000),
(1003, 102, '2024-01-10', 'Debit', 30000),
(1004, 103, '2024-01-12', 'Credit', 200000),
(1005, 104, '2024-01-20', 'Debit', 60000),
(1006, 105, '2024-01-25', 'Credit', 300000),
(1007, 105, '2024-02-05', 'Debit', 150000),
(1008, 103, '2024-02-10', 'Debit', 100000);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_amount DECIMAL(12,2),
    loan_status VARCHAR(50),
    overdue_days INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO loans VALUES
(201, 1, 300000, 'Active', 0),
(202, 2, 200000, 'Overdue', 45),
(203, 3, 1000000, 'Active', 10),
(204, 4, 250000, 'Closed', 0),
(205, 5, 1500000, 'Overdue', 60);

#1. Credit Risk & Portfolio Monitoring

---#1Which customers currently have overdue loans-Identifies immediate credit risk.

select c.customer_name,c.customer_id,max(l.overdue_days)as max_overdue from customers c
join loans l on
c.customer_id=l.customer_id
where overdue_days>0
group by c.customer_name,c.customer_id
order by max_overdue desc
;

---#2️⃣ Who are the top overdue customers by balance?-Prioritize collections on high-value risk.

select 
c.customer_name,
c.customer_id,
a.balance,
max(l.overdue_days) as max_overdue_days 
from customers c
join accounts a on
c.customer_id=a.customer_id
join loans l on
a.customer_id=l.customer_id
where l.overdue_days>30
group by
c.customer_name,
c.customer_id,
a.balance 
order by
a.balance desc,
max_overdue_days desc limit 2;



---#3️⃣ What is the total overdue loan exposure-(loan amount)Understand risk size.
select c.customer_name,sum(l.loan_amount) as overdue_amount from customers c
join loans  l on
c.customer_id=l.customer_id
where l.loan_status= 'overdue'
group  by c.customer_name;


---#4️⃣ Which customer segments have more overdue loans-Segment-level risk strategy.
select c.customer_segment, count(*) as overdue_segment from customers c
join loans l on
c.customer_id=l.customer_id
where l.overdue_days>0
group by c.customer_segment
order by overdue_segment desc ;


---#Customer Value & Relationship Management

---#5Who are the top customers by account balance-Identify premium customers.
select c.customer_name,c.customer_id,sum(a.balance) as top_customers
from customers c 
join accounts a on
c.customer_id=a.customer_id
group by c.customer_name,c.customer_id
order by top_customers desc ;


---#6️⃣ Which customers generate high transaction value despite low balances-Liquidity & retention risk.

select c.customer_name,
c.customer_id,
count(t.transaction_id) as high_transaction,
sum(a.balance) as total_balance
from customers c
join accounts a on
c.customer_id=a.customer_id 
join transactions t on
a.account_id=t.account_id
group by c.customer_name,c.customer_id
order by high_transaction desc, total_balance asc
limit 3;
 
 
---#7️⃣ What is the average balance by customer segment-Segment performance comparison.
select c.customer_segment,round(avg(a.balance)) as avg_balance from customers c
join accounts a on
c.customer_id=a.customer_id 
group by c.customer_segment;



---# Customer Behavior & Engagement

---#8️⃣ Which customers are most active based on transaction count?
select c.customer_name,
c.customer_id,count(t.transaction_id) as Most_active 
from customers c
join accounts a on
c.customer_id=a.customer_id 
join transactions t on
a.account_id=t.account_id
group by c.customer_name,c.customer_id
order by Most_active desc limit 1;


---#9️⃣ What is the average transaction value per customer-Spending behavior.
select 
c.customer_name,
c.customer_id,
round(avg(t.amount)) as avg_transaction 
from customers c
join accounts a on
c.customer_id=a.customer_id 
join transactions t on
a.account_id=t.account_id
group by c.customer_name,c.customer_id;


---#🔟 Are customers more credit-heavy or debit-heavy- Cash-flow behavior analysis.

SELECT 
    c.customer_id,
    SUM(CASE WHEN t.transaction_type = 'Credit' THEN round(t.amount) ELSE 0 END) AS total_credit,
    SUM(CASE WHEN t.transaction_type = 'Debit' THEN round(t.amount) ELSE 0 END) AS total_debit,
    IF(SUM(CASE WHEN t.transaction_type = 'Credit' THEN round(t.amount) ELSE 0 END) >
       SUM(CASE WHEN t.transaction_type = 'Debit' THEN round(t.amount) ELSE 0 END),
       'credit-heavy',
       IF(SUM(CASE WHEN t.transaction_type = 'Credit' THEN round(t.amount) ELSE 0 END) <
          SUM(CASE WHEN t.transaction_type = 'Debit' THEN round(t.amount) ELSE 0 END),
          'debit-heavy',
          'balanced'
       )
    ) AS cash_flow_behavior
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.customer_id;


 ---#4. Regional & Business Performance

---#1️⃣1️⃣ Which regions hold the highest total account balance-Regional business strength.

select c.region,round(sum(a.balance)) as highest_balance from customers c
join accounts a on
c.customer_id = a.customer_id
group by c.region
order by highest_balance desc limit 1;

---#1️⃣2️⃣ Which regions have high balances but also higher loan risk-Risk-adjusted performance.
select c.region,sum(a.balance) as high_balance,sum(l.loan_amount) as loan_risk
from customers c 
join accounts a on
c.customer_id = a.customer_id
join loans l on
c.customer_id = l.customer_id
group by c.region
order by high_balance desc,
loan_risk desc limit 1;


---#5. Operational & Executive Reporting


---#1️⃣3️⃣ What is the overall loan status breakdown (Active, Closed, Overdue)- Portfolio health snapshot.
select loan_status,count(*) from loans 
group by loan_status;

---#1️⃣4️⃣ What percentage of customers have both loans and accounts- Product penetration.

select 
round(count(distinct c.customer_id)*100.0/(select count(*) from customers),0) 
as percentage_penetration
from customers c 
inner join accounts a on
c.customer_id = a.customer_id
inner join loans l on
c.customer_id = l.customer_id;


---#1️⃣5️⃣ What are the top 5 customers the bank should focus on today(based on balance + loan risk-Actionable decision list.
select c.customer_id,c.customer_name,round(sum(a.balance)) as total_balance,
round(sum(l.loan_amount)) as high_loan 
from  customers c 
join accounts a on
c.customer_id = a.customer_id
join loans l on
c.customer_id = l.customer_id
group by c.customer_id,c.customer_name
order by total_balance desc,
high_loan desc limit 5;









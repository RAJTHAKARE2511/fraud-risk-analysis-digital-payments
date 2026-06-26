USE fraud_analysis;
-- data --
SELECT * FROM transactions;

-- KPI --
-- Total Transactions Processed--
SELECT COUNT(*) FROM transactions;

-- Fraudulent Transactions--
SELECT count(*) as fraud_transaction
from transactions
where isFraud = 1;


-- fraud % -- 
select count(case when isfraud = 1 then 1 end ) as total_fraud_transactions,
count(*) as total_transactions,
ROUND(count(case when isfraud = 1 then 1 end ) * 100 /COUNT(*),2) as fraud_percentage
from transactions;

-- total fraud amount -- 
SELECT SUM(amount) as fraud_loss
from transactions
where isFraud = 1;


select 
type as Transaction_Type ,count(*) as total_transactions
from transactions
where isFraud =1 
group by type
order by total_transactions desc ;


select 
type as Transaction_Type ,SUM(amount) as fraud_loss
from transactions
where isFraud =1 
group by type
order by fraud_loss desc ;

-- What is the fraud rate across different transaction types?
select 
type as Transaction_type,
count(*) as total_transactions,
count(case when isfraud = 1 then 1 end ) as total_fraud_transactions,
ROUND(count(case when isfraud = 1 then 1 end ) * 100 /COUNT(*),2) as fraud_percentage,
SUM(case when isfraud = 1 then amount end ) as fraud_loss
from transactions
group by type
order by fraud_percentage desc ;

-- How does fraud activity change over time?
select (step%24) as hour_step,
Count(*) as fraud_count,
avg(amount) as fraud_loss_per_hour
from transactions
where isfraud =1
group by (step%24)
order by hour_step asc;

-- How effective is the current fraud detection system?  using cte
with fraud_metrics as (
select
COUNT(case when isFraud =1 then 1 end ) as actual_fraud_count,
SUM(case when isFraud= 1 then amount  end) as actual_fraud_loss, 
COUNT(case when isFlaggedFraud = 1 then 1 end ) as system_flagged_count,
COUNT( case when isFraud =1 AND isFlaggedFraud =1 then 1 end ) as caught_fraud_count,
SUM( case when isFraud =1 AND isFlaggedFraud = 1 then amount end ) as caught_fraud_loss

from transactions
)
select 
actual_fraud_count,
system_flagged_count,
caught_fraud_count,
actual_fraud_loss,
caught_fraud_loss,
ROUND(caught_fraud_count * 100.00/ NULLIF(actual_fraud_count,0),2) as detection_rate
from fraud_metrics ;

-- What characteristics are common among fraudulent transactions?
 -- AMOUNT 
 
 select isfraud,
 COUNT(*) as total_transactions,
 ROUND(AVG(amount),2) as average_amount,
 MIN(amount) as min_amount,
MAX(amount) as max_amount
 from transactions
 group by isfraud;
 
 
-- receipent behaviour
SELECT 
    isFraud,
    AVG(oldbalanceDest) AS avg_old_balance_dest,
    AVG(newbalanceDest) AS avg_new_balance_dest
FROM transactions
GROUP BY isFraud;

-- sender behaviour
 
 SELECT 
    isFraud,
    AVG(oldbalanceOrg - newbalanceOrig) AS avg_balance_change
FROM transactions
GROUP BY isFraud;

-- behaviour -- 
SELECT
isFraud,
count(*) as total_transactions,
SUM(CASE WHEN newbalanceOrig = 0 then 1 end) as zero_balance,
ROUND(SUM(CASE WHEN newbalanceOrig = 0 then 1 end)*100.00 / count(*),2) as zero_balance_rate
from transactions
group by isFraud;

-- type vs fraud % --- 
select type as transaction_type ,
count(*) as total_transactions,
count(case when isfraud = 1 then 1 end ) as total_fraud_transactions,
ROUND(count(case when isfraud = 1 then 1 end ) * 100 /COUNT(*),2) as fraud_percentage
from transactions
group by transaction_type
order by fraud_percentage desc;
 
-- AMOUNT BUCKET
SELECT 
    CASE 
        WHEN amount < 10000 THEN 'Low'
        WHEN amount BETWEEN 10000 AND 100000 THEN 'Medium'
        ELSE 'High'
    END AS amount_bucket,
    isFraud,
    COUNT(*) AS txn_count
FROM transactions
GROUP BY amount_bucket, isFraud
ORDER BY amount_bucket, isFraud;



-- Section C — Views (POWER BI LAYER) ⭐


CREATE VIEW vw_fraud_summary AS
SELECT
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN isFraud = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND(SUM(CASE WHEN isFraud = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate,
    SUM(CASE WHEN isFraud = 1 THEN amount ELSE 0 END) AS fraud_loss
FROM transactions;

drop view vw_fraud_by_type;
CREATE VIEW vw_fraud_by_type AS
select 
type as Transaction_type,
count(*) as total_transactions,
count(case when isfraud = 1 then 1 end ) as total_fraud_transactions,
ROUND(count(case when isfraud = 1 then 1 end ) * 100 /COUNT(*),2) as fraud_percentage,
SUM(case when isfraud = 1 then amount else 0 end ) as fraud_loss
from transactions
group by type;

CREATE VIEW vw_fraud_trend AS
select (step%24) as hour_step,
Count(*) as fraud_count,
avg(amount) as fraud_loss_per_hour
from transactions
where isfraud =1
group by (step%24)
order by hour_step asc;


CREATE VIEW vw_fraud_detection AS
with fraud_metrics as (
select
COUNT(case when isFraud =1 then 1 end ) as actual_fraud_count,
SUM(case when isFraud= 1 then amount  end) as actual_fraud_loss, 
COUNT(case when isFlaggedFraud = 1 then 1 end ) as system_flagged_count,
COUNT( case when isFraud =1 AND isFlaggedFraud =1 then 1 end ) as caught_fraud_count,
SUM( case when isFraud =1 AND isFlaggedFraud = 1 then amount end ) as caught_fraud_loss

from transactions
)
select 
actual_fraud_count,
system_flagged_count,
caught_fraud_count,
actual_fraud_loss,
caught_fraud_loss,
ROUND(caught_fraud_count * 100.00/ NULLIF(actual_fraud_count,0),2) as detection_rate
from fraud_metrics ;

CREATE VIEW vw_fraud_behavior AS
SELECT
    isFraud,
    COUNT(*) AS total_transactions,
    AVG(amount) AS avg_amount,
    MIN(amount) AS min_amount,
    MAX(amount) AS max_amount,
    AVG(oldbalanceOrg - newbalanceOrig) AS avg_balance_drop_org,
    SUM(CASE WHEN newbalanceOrig = 0 THEN 1 ELSE 0 END) AS zero_balance_cases,
    ROUND(SUM(CASE WHEN newbalanceOrig = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS zero_balance_rate
FROM transactions
GROUP BY isFraud;

CREATE VIEW vw_amount_bucket AS 
SELECT 
    CASE 
        WHEN amount < 10000 THEN 'Low'
        WHEN amount BETWEEN 10000 AND 100000 THEN 'Medium'
        ELSE 'High'
    END AS amount_bucket,
    isFraud,
    COUNT(*) AS txn_count
FROM transactions
GROUP BY amount_bucket, isFraud
ORDER BY amount_bucket, isFraud;

SELECT * FROM vw_fraud_summary;
SELECT * FROM vw_fraud_by_type;
SELECT * FROM vw_fraud_trend;
SELECT * FROM vw_fraud_detection;
SELECT * FROM vw_fraud_behavior;
SELECT * FROM vw_amount_bucket;



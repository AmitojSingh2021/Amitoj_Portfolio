
/***Set Time Zone***/

Set time_zone='-4:00';

/***Preliminary Data Collection***/

SELECT 
    *
FROM
    ba710case.ba710_prod
LIMIT 5;

SELECT 
    *
FROM
    ba710case.ba710_sales
LIMIT 5;

SELECT 
    *
FROM
    ba710case.ba710_emails
LIMIT 5;

/*** Investigate Sales ***/

/***Create a product sales table. 
	This has to be done to preserve the original sales table ***/

drop table if exists work.case_prod_sales;

CREATE TABLE work.case_prod_sales AS SELECT * FROM
    ba710case.ba710_sales;

SELECT 
    *
FROM
    work.case_prod_sales;

/***Create a new table having product id 
	and model name of scooters only ***/

drop table if exists work.case_scooter_name;

CREATE TABLE work.case_scooter_name AS SELECT product_id, model FROM
    ba710case.ba710_prod
WHERE
    product_type = 'scooter'
LIMIT 7;

SELECT 
    *
FROM
    work.case_scooter_name;

/*** Use a join to combine the table above that contains
	model name to the sales information ***/

drop table if exists work.case_scooter_sales;

CREATE TABLE work.case_scooter_sales AS SELECT a.model, b.* FROM
    work.case_scooter_name a
        INNER JOIN
    work.case_prod_sales b ON a.product_id = b.product_id;
    
SELECT 
    *
FROM
    work.case_scooter_sales;

/***Investigate Bat sales.Select Bat models from your table.
Count the number of Bat sales from your table.***/

SELECT 
    COUNT(*)
FROM
    work.case_scooter_sales
WHERE
    model LIKE 'bat';

/***When was last (most recent) Bat sale?***/

SELECT 
    MAX(sales_transaction_date)
FROM
    work.case_scooter_sales
WHERE
    model LIKE 'bat';

/***Take a look at daily sales.
Store Bat sales data in a new table; store the sales date as a date, and not a datetime***/

drop table if exists work.case_bat_sales;

CREATE TABLE work.case_bat_sales AS SELECT *, DATE(sales_transaction_date) AS date FROM
    work.case_scooter_sales
WHERE
    model = 'Bat';

SELECT 
    *
FROM
    work.case_bat_sales;

/***Create a table of daily sales.
Summary of count of sales by date (one record for each date).***/

drop table if exists work.case_daily_sales;

CREATE TABLE work.case_daily_sales AS SELECT date, COUNT(date) AS sales_count FROM
    work.case_bat_sales
GROUP BY date
ORDER BY date DESC;
    
SELECT 
    *
FROM
    work.case_daily_sales;

/***Quantify the sales drop***/
/***Compute a cumulative sum of sales with one row per date***/

drop table if exists work.case_bat_cum_sales;

Create table work.case_bat_cum_sales as 
	Select *, sum(sales_count) Over (order by date) as cumulative_sum 
    from work.case_daily_sales;

SELECT 
    *
FROM
    work.case_bat_cum_sales;

/***Compute a 7 day lag of cumulative sum of sales***/

drop table if exists work.case_bat_lag_cum_sales;

Create table work.case_bat_lag_Cum_sales as 
	Select * , lag(cumulative_sum,7) OVER (order by date) as PreviousSales 
	From work.case_bat_cum_sales;

SELECT 
    *
FROM
    work.case_bat_lag_Cum_sales;

/***Calculate a running sales growth as a percentage by comparing the
	current sales to sales from 1 week prior***/

drop table if exists work.case_bat_weekly_running_sales;

Create table work.case_bat_weekly_running_sales as 
	select *, concat(100 * (cumulative_sum - lag(cumulative_sum,7) 
    Over (order by date))/ lag(cumulative_sum, 7) Over (order by date), '%')
	as weekly_percentage_growth 
    from work.case_bat_lag_cum_sales;
    
SELECT 
    *
FROM
    work.case_bat_weekly_running_sales;

/***Is the launch timing (October) a potential cause for the drop?
Replicate the Bat sales volume analysis (this whole project)
or the Bat Limited Edition***/

SELECT 
    COUNT(sales_transaction_date)
FROM
    work.case_scooter_sales
WHERE
    model LIKE 'Bat Limited Edition';

/***5803 Bat limited edition sales were recorded***/

SELECT 
    MAX(sales_transaction_date)
FROM
    work.case_scooter_sales
WHERE
    model LIKE 'Bat Limited Edition';

/***On 2019-05-31, last Bat Limited Edition sales were recorded ***/

/***Take a look at daily sales.
Store Bat Limited Edition sales data in a new table; store the sales date as a date, and not a datetime***/

drop table if exists work.case_bat_LE_sales;

CREATE TABLE work.case_bat_LE_sales AS SELECT model,
    customer_id,
    product_id,
    sales_amount,
    channel,
    dealership_id,
    DATE(sales_transaction_date) AS date FROM
    work.case_scooter_sales
WHERE
    model = 'Bat Limited Edition';

SELECT 
    *
FROM
    work.case_bat_LE_sales;

/***Create a table of daily sales.
Summary of count of sales by date (one record for each date).***/

drop table if exists work.case_Bat_LE_daily_sales;

CREATE TABLE work.case_Bat_LE_daily_sales AS SELECT date, COUNT(date) AS sales_count FROM
    work.case_bat_LE_sales
GROUP BY date
ORDER BY date DESC;

SELECT 
    *
FROM
    work.case_Bat_LE_daily_sales;

/***Quantify the sales drop***/
/***Compute a cumulative sum of sales with one row per date***/

drop table if exists work.case_bat_LE_cum_sales;

Create table work.case_bat_LE_cum_sales as 
	Select *, sum(sales_count) Over (order by date) as cumulative_sum 
    from work.case_bat_LE_daily_sales;

SELECT 
    *
FROM
    work.case_bat_LE_cum_sales;

/***Compute a 7 day lag of cumulative sum of sales***/

drop table if exists work.case_bat_LE_lag_cum_sales;

Create table work.case_bat_LE_lag_Cum_sales as 
	Select * , lag(cumulative_sum,7) OVER (order by date) as Week_Prior_Sales 
	From work.case_bat_LE_cum_sales;

SELECT 
    *
FROM
    work.case_bat_LE_lag_cum_sales;

/***Calculate a running sales growth as a percentage by comparing the
current sales to sales from 1 week prior***/

drop table if exists work.case_bat_LE_weekly_running_sales;

create table work.case_bat_LE_weekly_running_sales as 
	select *, concat(100*(cumulative_sum - lag(cumulative_sum, 7) 
	over (order by date))/lag(cumulative_sum, 7) 
	over (order by date), '%') as weekly_perentage_growth 
from work.case_bat_LE_lag_cum_sales;

SELECT 
    *
FROM
    work.case_bat_LE_weekly_running_sales;

/***Show the first 22 rows of the table***/

SELECT 
    *
FROM
    work.case_bat_LE_weekly_running_sales
LIMIT 22;

SELECT 
    COUNT(sales_transaction_date)
FROM
    work.case_scooter_sales
WHERE
    model = 'Lemon' AND product_id = 3;

/***16558 Lemon scooter sales were recorded ***/

SELECT 
    MAX(sales_transaction_date)
FROM
    work.case_scooter_sales
WHERE
    model LIKE 'Lemon' AND product_id = 3;

/***On 2018-12-27, last lemon scooter sale were recorded*/

/***Take a look at daily sales.
Store lemon sales data in a new table; store the sales date as a date, and not a datetime***/

drop table if exists work.case_lemon_sales;
CREATE TABLE work.case_lemon_sales AS SELECT *, DATE(sales_transaction_date) date FROM
    work.case_scooter_sales
WHERE
    model = 'Lemon' AND product_id = 3;

SELECT 
    *
FROM
    work.case_lemon_sales;

/***Create a table of daily sales.
Summary of count of sales by date (one record for each date).***/

drop table if exists work.case_lemon_daily_sales;

CREATE TABLE work.case_lemon_daily_sales AS SELECT date, COUNT(date) AS sales_count FROM
    work.case_lemon_sales
GROUP BY date
ORDER BY date DESC;

/***Quantify the sales drop***/
/***Compute a cumulative sum of sales with one row per date***/

drop table if exists work.case_lemon_cum_sales;

Create table work.case_lemon_cum_sales as 
	Select *, sum(sales_count) Over (order by date) as cumulative_sum 
    from work.case_lemon_daily_sales;

/***Compute a 7 day lag of cumulative sum of sales***/

drop table if exists work.case_lemon_lag_cum_sales;

Create table work.case_lemon_lag_Cum_sales as 
	Select * , lag(cumulative_sum,7) OVER (order by date) as PreviousSales 
	From work.case_lemon_cum_sales;

/***Calculate a running sales growth as a percentage by comparing the
current sales to sales from 1 week prior***/

drop table if exists work.case_lemon_weekly_running_sales;

Create table work.case_lemon_weekly_running_sales as 
	select *, concat(100 * (cumulative_sum - lag(cumulative_sum,7) 
    Over (order by date))/ lag(cumulative_sum, 7) Over (order by date), '%')
	as weekly_percentage_growth 
    from work.case_lemon_lag_cum_sales;

/***Show the first 22 rows of the table***/

SELECT 
    *
FROM
    work.case_lemon_weekly_running_sales
LIMIT 22;

  
/***Marketing analysis to include:
Was the email opened?
Who was the customer that opened the email?
Did the customer purchase a scooter?
***/

/*** Join email and sales tables to get sales_transaction_date, customer_id, email opened status, email sent_date, email_opened_date, email_subject***/

drop table if exists work.case_emails;

CREATE TABLE work.case_emails AS SELECT a.sales_transaction_date,
    a.customer_id,
    b.opened,
    b.sent_date,
    b.opened_date,
    b.email_subject FROM
    work.case_bat_sales a
        INNER JOIN
    ba710case.ba710_emails b ON a.customer_id = b.customer_id
ORDER BY date;

SELECT 
    *
FROM
    work.case_emails;

/***Remove emails sent more than 6 months prior to production of the Bat scooter***/

DELETE FROM work.case_emails 
WHERE
    sent_date < '2016-04-10';

/***Remove emails sent after the purchase date***/

DELETE FROM work.case_emails 
WHERE
    sent_date > sales_transaction_date;

set time_zone='-4:00';

/***Remove emails sent more than 30 days prior to purchase***/

DELETE FROM work.case_emails 
WHERE
    DATEDIFF(sales_transaction_date, sent_date) > '30';

/***There appear to be a number of general promotional emails not 
specifically related to the Bat scooter.  Select the email subject
from the bat_emails table

Remove:
Black Friday
25% off all EVs
It's a Christmas Miracle!
A New Year, And Some New EVs***/

DELETE FROM work.case_emails 
WHERE
    POSITION('Black Friday' IN email_subject) > 0;

DELETE FROM work.case_emails 
WHERE
    POSITION('25% off all EVs' IN email_subject) > 0;

DELETE FROM work.case_emails 
WHERE
    POSITION('A New Year, And Some New EVs' IN email_subject) > 0;

/***Query how many rows are left***/

SELECT 
    COUNT(*)
FROM
    work.case_emails;

/***407 rows were left***/

SELECT 
    COUNT(DISTINCT (customer_id))
FROM
    work.case_emails;

/***402 customers received an email***/

SELECT 
    COUNT(opened)
FROM
    work.case_emails
WHERE
    opened = 't';

/***100 emails were opened***/

SELECT 
    COUNT(DISTINCT (customer_id))
FROM
    work.case_emails
WHERE
    opened = 't';

/***100 customers were made a purchase after opening an email***/

SELECT CONCAT(100 * (100 / 402), '%') AS Email_Purchase_Rate;

/***Out of 402 customers who received an email, only 24.8756% of customer made a purchase after opening the email***/

SELECT 
    COUNT(DISTINCT (customer_id))
FROM
    work.case_bat_sales;
    
/***Total number of BAT scooter customer were 6659***/

SELECT CONCAT(100 * (402 / 6659), '%') AS Comparision;

/***Out of total BAT sales 6.0369% comes from the people who received an email***/

SELECT CONCAT(100 * (100 / 6659), '%') AS Comparision;

/***Out of total BAT sales, only 1.5017% sales comes from email campaign where customer opened the email***/

SELECT CONCAT(100 * (100 / 402), '%') AS Email_opened_Rate;

/***Yes, only 24.8756% emails are opened by the customer***/
  
/***Investigate the rates for the first three weeks
where we saw a reduction in sales.(Sales prior to November 1, 2016)***/

/***Create a table of emails where the date is prior to November 1, 2016***/

drop table if exists work.case_initial_sales;
CREATE TABLE work.case_initial_sales AS SELECT * FROM
    work.case_emails
WHERE
    sales_transaction_date < '2016-11-01';

/***Query the number of emails sent during this period***/

SELECT 
    COUNT(sent_date)
FROM
    work.case_initial_sales;

/***82 emails were sent in first three week***/

SELECT 
    COUNT(DISTINCT (customer_id))
FROM
    work.case_initial_sales;

/***82 customers received an email in first three week***/

SELECT 
    COUNT(opened)
FROM
    work.case_initial_sales
WHERE
    opened = 't';

/***15 emails were opened***/

SELECT 
    COUNT(DISTINCT (customer_id))
FROM
    work.case_initial_sales
WHERE
    opened = 't';

/***15 customers were made a purchase after opened an email***/

SELECT CONCAT(100 * (15 / 82), '%') AS Email_Purchase_Rate;
/***18.2927%
Yes, overall we have less than 25% of the customers who opened an email and subsequently made a purchase***/

SELECT 
    COUNT(DISTINCT (customer_id))
FROM
    work.case_bat_sales
WHERE
    sales_transaction_date < '2016-11-01';

/***160 customers made purchase before 2016-11-01***/

SELECT CONCAT(100 * (82 / 160), '%') AS comparision;

/***Out of 160 customers 82 customers were made a purchase after receiving an email which is 51.25%***/

SELECT CONCAT(100 * (15 / 160), '%') AS comparision;

/***Out of 160 customers, only 9.3750% customers were made a purchase after opening an email***/

################
/*Summary of BAT sales
From the above analysis, we can predict that 51.25% of the total customers received an email in the first three weeks before making a purchase. 
It is significantly higher than the entire period where approximately 6% of total customers received an email before making a purchase. 
Similarly, 9.3750% of total customers made a purchase after opening the received email in the first three weeks compared to 1.5017% in the entire period. 
This data reflects the number of sales generated from the email marketing campaign. 
Furthermore, in the case of the BAT scooter, out of total emails sent, 24.8756% were opened and converted into sales compared to 18.2927% in the first three weeks.*/ 
#################

/***Compare to the successful 2013 Lemon scooter.***/

set time_zone='-4:00';

drop table if exists work.case_lemon_emails;
CREATE TABLE work.case_lemon_emails AS SELECT b.sales_transaction_date,
    a.customer_id,
    a.opened,
    a.sent_date,
    a.opened_date,
    a.email_subject FROM
    ba710case.ba710_emails a
        INNER JOIN
    work.case_lemon_sales b ON a.customer_id = b.customer_id
ORDER BY date;

/***Remove emails sent more than 6 months prior to production of the lemon scooter***/

DELETE FROM work.case_lemon_emails 
WHERE
    sent_date < '2012-11-01';

/***Remove emails sent after the purchase date***/

DELETE FROM work.case_lemon_emails 
WHERE
    sent_date > sales_transaction_date;

/***Remove emails sent more than 30 days prior to purchase***/


DELETE FROM work.case_lemon_emails 
WHERE
    DATEDIFF(sales_transaction_date, sent_date) > '30';

/***Run the same analysis for the Lemon scooter.
Irrelevant/general subjects are:
25% off all EVs
Like a Bat out of Heaven
Save the Planet
An Electric Car
We cut you a deal
Black Friday. Green Cars.
Zoom***/

DELETE FROM work.case_lemon_emails 
WHERE 
	POSITION('Like a Bat out of Heaven' in email_subject)>0;

DELETE FROM work.case_lemon_emails 
WHERE
    POSITION('25% off all EVs' IN email_subject) > 0;

DELETE FROM work.case_lemon_emails 
WHERE
    POSITION('Save the Planet' IN email_subject) > 0;

DELETE FROM work.case_lemon_emails 
WHERE
    POSITION('An Electric Car' IN email_subject) > 0;

DELETE FROM work.case_lemon_emails 
WHERE
    POSITION('We cut you a deal' IN email_subject) > 0;

DELETE FROM work.case_lemon_emails 
WHERE
    POSITION('Black Friday. Green Cars.' IN email_subject) > 0;

DELETE FROM work.case_lemon_emails 
WHERE
    POSITION('Zoom' IN email_subject) > 0;

/***Query how many rows are left***/

SELECT 
    COUNT(*)
FROM
    work.case_lemon_emails;

/***514 were left***/

SELECT 
    COUNT(sent_date)
FROM
    work.case_lemon_emails;

/***514 emails were sent***/

SELECT 
    COUNT(opened)
FROM
    work.case_lemon_emails
WHERE
    opened = 't';

/***129 emails were opened***/

SELECT 
    COUNT(sales_transaction_date)
FROM
    work.case_lemon_emails
WHERE
    opened = 't';

/***All 129 emails were converted into the sales***/

SELECT 
    COUNT(DISTINCT (customer_id))
FROM
    work.case_lemon_emails;

/***510 Customer made a purchase after receiving an email***/

SELECT 
    COUNT(DISTINCT (customer_id))
FROM
    work.case_lemon_emails
WHERE
    opened = 't';

/***127 customers make a purchase after opened an email***/

SELECT CONCAT(100 * (127 / 510), '%') AS Email_Purchase_Rate;

/*** Out of 510 Customer, 24.9020% of customer make a purchase after opening an email***/

SELECT 
    COUNT(DISTINCT (customer_id))
FROM
    work.case_lemon_sales;

/***13854 purchases were made***/

SELECT CONCAT(100 * (127 / 13854), '%') AS Comparision;
/***Out of total Lemon sales 0.9167% comes from the email campaign***/

SELECT CONCAT(100 * (510 / 13854), '%') AS Comparision;
/***Out of total Lemon sales 3.68% generated after receiving an email***/

SELECT CONCAT(100 * (129 / 514), '%') AS Comparision;
/**Yes, out of 514 email sent, only 129 were opened which is equal to 25.0973%***/

/***Let's investigate the rates for the first three weeks
where we saw a reduction in sales.(Sales prior to May 22, 2013)***/

/***Create a table of emails where the date is prior to May 22, 2013***/

drop table if exists work.case_initial_lemon_sales;

CREATE TABLE work.case_initial_lemon_sales AS SELECT * FROM
    work.case_lemon_emails
WHERE
    sales_transaction_date < '2013-05-22';

/***Query the number of emails sent during this period***/

SELECT 
    COUNT(sent_date)
FROM
    work.case_initial_lemon_sales;
/***0 emails has been sent***/

SELECT 
    COUNT(sent_date)
FROM
    work.case_lemon_emails
WHERE
    sales_transaction_date < '2013-05-22';
/***0 email was sent***/

SELECT 
    COUNT(sent_date)
FROM
    work.case_emails
WHERE
    sales_transaction_date < '2016-10-25';
/***82 emails were sent***/





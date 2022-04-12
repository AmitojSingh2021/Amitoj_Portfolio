
/*Set Time Zone*/

set time_zone='-4:00';

/*Preliminary Data Collection
select * to investigate your tables.*/
Select * from ba710case.ba710_prod limit 5;
Select * from ba710case.ba710_sales limit 5;
Select * from ba710case.ba710_emails limit 5;

/**********************
Investigate Sales
Create a scooter sales table*/

drop table if exists work.case_prod_sales;
create table work.case_prod_sales as select * from ba710case.ba710_sales;

/*Create a new table in WORK with product id and model name for just scooters
Result should have 7 records.*/

drop table if exists work.case_scooter_name;
Create table work.case_scooter_name as select product_id, model from ba710case.ba710_prod where product_type='scooter' limit 7;

/*Use a join to combine the table above that contains model name 
to the sales information*/

drop table if exists work.case_scooter_sales;
Create table work.case_scooter_sales as select a.model, b.* from work.case_scooter_name a inner join ba710case.ba710_sales b on a.product_id=b.product_id; 

/*Investigate Bat sales.  
Select Bat models from your table.
Count the number of Bat sales from your table.*/

Select count(sales_transaction_date) from work.case_scooter_sales where model like 'bat';

/*When was last (most recent) Bat sale?*/

select max(sales_transaction_date) from work.case_scooter_sales where model like 'bat';

/*Take a look at daily sales.
Store Bat sales data in a new table; store the sales date as a date, and not a datetime*/

drop table if exists work.case_bat_sales;
Create table work.case_bat_sales as select *, date(sales_transaction_date) date From work.case_scooter_sales where model= 'Bat';

/*Create a table of daily sales.
Summary of count of sales by date (one record for each date).*/

drop table if exists work.case_daily_sales;
Create table work.case_daily_sales as select date, count(date) as sales_count from work.case_bat_sales group by date order by date desc;

/*Quantify the sales drop*/
/*Compute a cumulative sum of sales with one row per date
Hint: Window Functions, Over*/

drop table if exists work.case_bat_cum_sales;
Create table work.case_bat_cum_sales as Select *, sum(sales_count) Over (order by date) as cumulative_sum from work.case_daily_sales;

/*Compute a 7 day lag of cumulative sum of sales*/

drop table if exists work.case_bat_lag_cum_sales;
Create table work.case_bat_lag_Cum_sales as Select * , lag(cumulative_sum,7) OVER (order by date) as PreviousSales 
 From work.case_bat_cum_sales;

/*Calculate a running sales growth as a percentage by comparing the
current sales to sales from 1 week prior*/

drop table if exists work.case_bat_weekly_running_sales;
Create table work.case_bat_weekly_running_sales as 
select *, concat(100 * (cumulative_sum - lag(cumulative_sum,7) Over (order by date))/ lag(cumulative_sum, 7) Over (order by date), '%')
as weekly_percentage_growth from work.case_bat_lag_cum_sales;

/*Show the first 22 rows of the table*/

Select * from work.case_bat_weekly_running_sales limit 22;

/*SHOW THE RESULTS IN WORD*/

/*Is the launch timing (October) a potential cause for the drop?
Replicate the Bat sales volume analysis (this whole project)
or the Bat Limited Edition*/
/* Number of Bat Limited Edition sales*/

Select count(sales_transaction_date) from work.case_scooter_sales where model like 'Bat Limited Edition';
/*5803*/

/*When was last (most recent) Bat Limited Edition sale?*/

select max(sales_transaction_date) from work.case_scooter_sales where model like 'Bat Limited Edition';
/* 2019-05-31*/

/*Take a look at daily sales.
Store Bat Limited Edition sales data in a new table; store the sales date as a date, and not a datetime*/

drop table if exists work.case_bat_LE_sales;
Create table work.case_bat_LE_sales as select *, date(sales_transaction_date) date From work.case_scooter_sales where model= 'Bat Limited Edition';

/*Create a table of daily sales.
Summary of count of sales by date (one record for each date).*/

drop table if exists work.case_Bat_LE_daily_sales;
Create table work.case_Bat_LE_daily_sales as select date, count(date) as sales_count from work.case_bat_LE_sales group by date order by date desc;

/*Quantify the sales drop*/
/*Compute a cumulative sum of sales with one row per date
Hint: Window Functions, Over*/

drop table if exists work.case_bat_LE_cum_sales;
Create table work.case_bat_LE_cum_sales as Select *, sum(sales_count) Over (order by date) as cumulative_sum from work.case_bat_LE_daily_sales;

/*Compute a 7 day lag of cumulative sum of sales*/

drop table if exists work.case_bat_LE_lag_cum_sales;
Create table work.case_bat_LE_lag_Cum_sales as Select * , lag(cumulative_sum,7) OVER (order by date) as PreviousSales 
 From work.case_bat_LE_cum_sales;

/*Calculate a running sales growth as a percentage by comparing the
current sales to sales from 1 week prior*/

drop table if exists work.case_bat_LE_weekly_running_sales;
Create table work.case_bat_LE_weekly_running_sales as 
select *, concat(100 * (cumulative_sum - lag(cumulative_sum,7) Over (order by date))/ lag(cumulative_sum, 7) Over (order by date), '%')
as weekly_percentage_growth from work.case_bat_LE_lag_cum_sales;

/*Show the first 22 rows of the table*/

Select * from work.case_bat_LE_weekly_running_sales limit 22;

##############
/* From Bat Limited Edition, It is evident that October (Launch time) is not potential cause for drop in sales 
as Company sell 160 Bat scooter compared to only 96 Bat limited edition scooter (launched in February)*/ 
##############

/*However, the Bat Limited was at a higher price point.
Let's take a look at the 2013 Lemon model.  
Complete the sales delay and volumen analysis as we did above:*/

/* Number of Lemon sales*/

Select count(sales_transaction_date) from work.case_scooter_sales where model = 'Lemon' and product_id=3;
/*Lemon sales is 16558 */

/*When was last (most recent) lemon sale?*/

select max(sales_transaction_date) from work.case_scooter_sales where model like 'Lemon' and product_id=3;
/*2018-12-27*/

/*Take a look at daily sales.
Store lemon sales data in a new table; store the sales date as a date, and not a datetime*/

drop table if exists work.case_lemon_sales;
Create table work.case_lemon_sales as select *, date(sales_transaction_date) date From work.case_scooter_sales where model= 'Lemon' and product_id=3;

/*Create a table of daily sales.
Summary of count of sales by date (one record for each date).*/

drop table if exists work.case_lemon_daily_sales;
Create table work.case_lemon_daily_sales as select date, count(date) as sales_count from work.case_lemon_sales group by date order by date desc;

/*Quantify the sales drop*/
/*Compute a cumulative sum of sales with one row per date
Hint: Window Functions, Over*/

drop table if exists work.case_lemon_cum_sales;
Create table work.case_lemon_cum_sales as Select *, sum(sales_count) Over (order by date) as cumulative_sum from work.case_lemon_daily_sales;

/*Compute a 7 day lag of cumulative sum of sales*/

drop table if exists work.case_lemon_lag_cum_sales;
Create table work.case_lemon_lag_Cum_sales as Select * , lag(cumulative_sum,7) OVER (order by date) as PreviousSales 
 From work.case_lemon_cum_sales;

/*Calculate a running sales growth as a percentage by comparing the
current sales to sales from 1 week prior*/

drop table if exists work.case_lemon_weekly_running_sales;
Create table work.case_lemon_weekly_running_sales as 
select *, concat(100 * (cumulative_sum - lag(cumulative_sum,7) Over (order by date))/ lag(cumulative_sum, 7) Over (order by date), '%')
as weekly_percentage_growth from work.case_lemon_lag_cum_sales;

/*Show the first 22 rows of the table*/

Select * from work.case_lemon_weekly_running_sales limit 22;

  
/*Marketing analysis to include:
Was the email opened?
Who was the customer that opened the email?
Did the customer purchase a scooter?

To determine the hypothesis, we need to collect the customer_id column from both 
the emails table and the bat_sales table for the Bat Scooter, the opened, sent_date, 
opened_date, and email_subject columns from emails table, as well as the 
sales_transaction_date column from the bat_sales table. As we only want the email 
records of customers who purchased a Bat Scooter, we will join the customer_id 
column in both tables.
*/

drop table if exists work.case_emails;
Create table work.case_emails as 
select a.sales_transaction_date, a.customer_id, b.opened, b.sent_date, b.opened_date, b.email_subject from work.case_bat_sales a 
Inner Join  ba710case.ba710_emails b ON a.customer_id = b.customer_id 
order by date;

/*Remove emails sent more than 6 months prior to production of the Bat scooter*/

Delete from work.case_emails where sent_date < '2016-04-10';

/*Remove emails sent after the purchase date*/

Delete from work.case_emails where sent_date > sales_transaction_date;

set time_zone='-4:00';

/*Remove emails sent more than 30 days prior to purchase*/

Delete from work.case_emails where datediff(sales_transaction_date, sent_date) > '30';

/*There appear to be a number of general promotional emails not 
specifically related to the Bat scooter.  Select the email subject
from the bat_emails table

Remove:
Black Friday
25% off all EVs
It's a Christmas Miracle!
A New Year, And Some New EVs*/

Delete from work.case_emails where position('Black Friday' in email_subject)>0;
Delete from work.case_emails where position('25% off all EVs' in email_subject)>0;
Delete from work.case_emails where position("A New Year, And Some New EVs" in email_subject)>0;

/*Query how many rows are left.
How many?*/

Select count(*) from work.case_emails;
/*407*/

/* How many customer received an email */

Select count(distinct(customer_id)) from work.case_emails;
/*402 customers received an email */

/*Query how many emails were opened (opened='t').
How many?*/

Select count(opened) from work.case_emails where opened = 't';
/*100 emails are opened*/

/* How many customer made a purchase after opening an email*/

Select count(distinct(customer_id)) from work.case_emails where opened = 't';
/*100 customers were made a purchase after opening an email*/

/* /*Use SQL to query the percentage of people who opened an email 
and subsequently made a purchase
What's the percentage?*/

select concat(100*(100/402), '%') as Email_Purchase_Rate;
/*Out of 402 customers who received an email, only 24.8756% of customer make a purchase after opening the email*/

/* How many total customer purchased BAT scooter */

Select count(distinct(customer_id)) from work.case_bat_sales;
/*Total number of BAT scooter customer is 6659*/

/*Use a SQL query to calculate the percentage of people that made a 
purchase after receiving an email
How many?*/

select concat(100*(402/6659), '%') as Comparision;
/*Out of total BAT sales 6.0369% comes from the people who received an email*/

/*Use a SQL query to calculate the percentage of people that made a 
purchase after opening an email
How many?*/

select concat(100*(100/6659), '%') as Comparision;
/*Out of total BAT sales, only 1.5017% sales comes from email campaign where customer opened the email*/

/*Is there a difference between those that receive the email and those
that open the email?*/

select concat(100*(100/402), '%') as Email_opened_Rate;
/* Yes, only 24.8756% emails are opened by the customer*/
  
/*Let's investigate the rates for the first three weeks
where we saw a reduction in sales.  (Sales prior to November 1, 2016)*/

/*Create a table of emails where the date is prior to November 1, 2016*/

drop table if exists work.case_initial_sales;
create table work.case_initial_sales as select * from work.case_emails where sales_transaction_date < '2016-11-01';

/*Query the number of emails sent during this period
/*How many?*/

Select count(sent_date) from work.case_initial_sales;
/*82 emails were sent in first three week*/

/*Calculate how many customers received an email*/

select count(distinct(customer_id)) from work.case_initial_sales; 
/*82 customers received an email in first three week*/

/*Query the number of emails opened
/*How many?*/

Select count(opened) from work.case_initial_sales where opened ='t';
/*15 emails were opened*/

/*Query how many customers made a purchase after opened an email
How many?*/

Select count(distinct(customer_id)) from work.case_initial_sales where opened ='t';
/*15 customers were made a purchase after opened an email*/

/*Use SQL to query the percentage of people who opened an email 
and subsequently made a purchase
What's the percentage?
Does there appear to be a significant difference between the first three weeks and overall?*/

select concat(100*(15/82), '%') as Email_Purchase_Rate;
/*18.2927%
Yes, overall we have 25% of the customers who opened an email and subsequently made a purchase*/

/*Query how many customers in total did we have during the first three weeks
How many?*/

Select count(distinct(customer_id)) from work.case_bat_sales where sales_transaction_date < '2016-11-01';
/*160 customers*/

/*Use SQL to calculate the percentage of purchases where they received an email
What is the percentage?*/

select concat(100*(82/160), '%') as comparision;
/*Out of 160 customers 82 customers were made a purchase after receiving an email which is 51.25%*/

/*Use SQL to calculate the percentage of purchases where they opened an email
What is the percentage?*/

select concat(100*(15/160), '%') as comparision;
/*Out of 160 customers, only 9.3750% customers were made a purchase after opening an email*/

/*Is there a difference between those that receive the email and those that open the email?*/

Select concat(100*(15/82), '%') as comparison;
/*Yes, only 18.2927% emails were opened*/

################
/*Summary of BAT sales
From the above analysis, we can predict that 51.25% of the total customers received an email in the first three weeks before making a purchase. 
It is significantly higher than the entire period where approximately 6% of total customers received an email before making a purchase. 
Similarly, 9.3750% of total customers made a purchase after opening the received email in the first three weeks compared to 1.5017% in the entire period. 
This data reflects the number of sales generated from the email marketing campaign. 
Furthermore, in the case of the BAT scooter, out of total emails sent, 24.8756% were opened and converted into sales compared to 18.2927% in the first three weeks.*/ 
#################

/*Compare to the successful 2013 Lemon scooter.*/

set time_zone='-4:00';

drop table if exists work.case_lemon_emails;
Create table work.case_lemon_emails as 
select b.sales_transaction_date, a.customer_id, a.opened, a.sent_date, a.opened_date, a.email_subject from ba710case.ba710_emails a 
Inner Join work.case_lemon_sales b ON a.customer_id = b.customer_id 
order by date;

/*Remove emails sent more than 6 months prior to production of the lemon scooter*/

Delete from work.case_lemon_emails where sent_date < '2012-11-01';

/*Remove emails sent after the purchase date*/

Delete from work.case_lemon_emails where sent_date > sales_transaction_date;

/*Remove emails sent more than 30 days prior to purchase*/


Delete from work.case_lemon_emails where datediff(sales_transaction_date, sent_date) > '30';

/*/*Run the same analysis for the Lemon scooter.
Irrelevant/general subjects are:
25% off all EVs
Like a Bat out of Heaven
Save the Planet
An Electric Car
We cut you a deal
Black Friday. Green Cars.
Zoom*/

Delete from work.case_lemon_emails where position('Like a Bat out of Heaven' in email_subject)>0;
Delete from work.case_lemon_emails where position('25% off all EVs' in email_subject)>0;
Delete from work.case_lemon_emails where position('Save the Planet' in email_subject)>0;
Delete from work.case_lemon_emails where position('An Electric Car' in email_subject)>0;
Delete from work.case_lemon_emails where position('We cut you a deal' in email_subject) > 0;
Delete from work.case_lemon_emails where position('Black Friday. Green Cars.' in email_subject)>0;
Delete from work.case_lemon_emails where position('Zoom' in email_subject)>0;

/*Query how many rows are left.
How many?*/

Select count(*) from work.case_lemon_emails;
/*514*/

 /* How many emails were sent*/
 Select count(sent_date) from work.case_lemon_emails;
 /*514 emails were sent*/

/*Query how many emails were opened (opened='t').
How many?*/

Select count(opened) from work.case_lemon_emails where opened = 't';
/*129 emails are opened*/

/*How emails were opened and convert into sales */

Select count(sales_transaction_date) from work.case_lemon_emails where opened = 't';
/*All 129 emails were converted into the sales*/

/*How many customer made a purchase after receing an email*/

Select count(distinct(customer_id)) from work.case_lemon_emails;
/*510 Customer made a purchase after receiving an email*/

/* How many customer made a purchase after opening an email */

Select count(distinct(customer_id)) from work.case_lemon_emails where opened = 't';
/*127 customers make a purchase after opened an email*/

/* Query: what percentage of customer opened the email and subsequently made a purchase */

select concat(100*(127/510), '%') as Email_Purchase_Rate;
/* Out of 510 Customer, 24.9020% of customer make a purchase after opening an email*/

/* How many customers purchased a Lemon scooter*/

Select count(distinct(customer_id)) from work.case_lemon_sales;
/*13854 purchases were made*/

/*Use a SQL query to calculate the percentage of people that made a 
purchase after opening an email
How many?*/

select concat(100*(127/13854), '%') as Comparision;
/*Out of total Lemon sales 0.9167% comes from the email campaign*/

/*Use a SQL query to calculate the percentage of people that made a 
purchase after receiving an email
How many?*/

select concat(100*(510/13854), '%') as Comparision;
/*Out of total Lemon sales 3.68% generated after receiving an email*/

/* Is there a difference between those that receive the email and those
that open the email?*/

select concat(100*(129/514), '%') as Comparision;
# Yes, out of 514 email sent, only 129 were opened which is equal to 25.0973%

/*Let's investigate the rates for the first three weeks
where we saw a reduction in sales.  (Sales prior to May 22, 2013)*/

/*Create a table of emails where the date is prior to May 22, 2013*/

drop table if exists work.case_initial_lemon_sales;
create table work.case_initial_lemon_sales as select * from work.case_lemon_emails where sales_transaction_date < '2013-05-22';

/*Query the number of emails sent during this period
/*How many?*/

Select count(sent_date) from work.case_initial_lemon_sales;
/*0 emails has been sent*/

################
/*Summary of Lemon Scooter sales
From the above analysis, we can predict that some evry useful insight. 
In case of Lemon scooter 3.68% of total customers received an email before making a purchase,whereas in first three weeks no email were sent. */ 
#################

#################
/* Comparision of BAT scooter with Lemon Scooter */

/* From the above comparison, it is evident that the marketing campaign for BAT scooter was more successful than the Lemon scooter 
because, in the case of BAT scooter, 9.3750% of customers purchased after opening the received email, 
whereas, in the case of Lemon scooter, no such email campaign was in operation. 
Furthermore, in the case of BAT, out of 18.2927% of sent emails were converted into sales which precisely explicit the conversion rate of emails. 
Moreover, out of total sent emails, 51.25% of them were opened in BAT scooter. This comparison somehow supports the email marketing campaign.*/   
####################

/*Number of email sent in first two week in case of Lemon*/

select count(sent_date) from work.case_lemon_emails where sales_transaction_date < '2013-05-22';
/* 0 email was sent */

/*Number of email sent in first two week in case of BAT*/

select count(sent_date) from work.case_emails where sales_transaction_date < '2016-10-25';
/*82 emails were sent*/





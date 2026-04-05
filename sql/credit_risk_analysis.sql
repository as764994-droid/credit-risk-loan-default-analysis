create database credit_risk_db;
use credit_risk_db;

use credit_risk_db;

create table credit_risk (
    person_age int,
    person_income bigint,
    person_home_ownership varchar(20),
    person_emp_length float,
    loan_intent varchar(30),
    loan_grade varchar(5),
    loan_amnt int,
    loan_int_rate float,
    loan_status int,
    loan_percent_income float,
    cb_person_default_on_file varchar(5),
    cb_person_cred_hist_length int,
    income_outlier_flag int,
    loan_status_label varchar(20),
    risk_category varchar(20)
);

select * 
from credit_risk
limit 10;

--  Query 1: What is the overall default rate? (Business Question: "Out of all loan applicants, what % have defaulted?")
select 
    count(*) as total_applicants,
    sum(loan_status) as total_defaulters,
    round(sum(loan_status) * 100.0 / count(*), 2) as default_rate_percent
from credit_risk;

--  Query 2: Default rate by Loan Grade (Business Question: "Which loan grades have the highest default rates?"
select 
    loan_grade,
    count(*) as total_loans,
    sum(loan_status) as defaults,
    round(sum(loan_status) * 100.0 / count(*), 2) as default_rate_percent
from credit_risk
group by loan_grade
order by loan_grade;

-- Query 3: Default rate by Home Ownership (Business Question: "Do renters default more than homeowners?")
select 
	person_home_ownership,
    count(*) as total_applicants,
    sum(loan_status) as defaults,
    round(sum(loan_status) * 100.0 / count(*), 2) as default_rate_percent
from credit_risk
group by person_home_ownership
order by default_rate_percent desc;

-- Query 4: Default rate by Loan Intent (Business Question: "Why are people taking loans — and which purpose leads to most defaults?")
select 	
	loan_intent,
    count(*) as total_loans,
    sum(loan_status) as defaults,
    round(sum(loan_status) * 100.0 / count(*)  , 2) as default_rate_percent
from credit_risk
group by loan_intent
order by default_rate_percent desc;

-- Query 5: Average loan amount: Defaulters vs Non-Defaulters (Business Question: "Do defaulters borrow more money than non-defaulters?")
select	
	loan_status_label,
    round(avg(loan_amnt),2) as avg_loan_amount,
    round(avg(loan_int_rate),2) as avg_interest_rate,
    round(avg(person_income),2) as avg_income,
    round(avg(loan_percent_income),2) as avg_loan_to_income_ratio
from credit_risk
group by loan_status_label;

select 
    case 
        when person_age between 20 and 25 then '20-25'
        when person_age between 26 and 30 then '26-30'
        when person_age between 31 and 40 then '31-40'
        when person_age between 41 and 55 then '41-55'
        else '55+'
    end as age_group,
    count(*) as total,
    sum(loan_status) as defaults,
    round(sum(loan_status) * 100.0 / count(*), 2) as default_rate_percent
from credit_risk
group by age_group
order by default_rate_percent desc;

-- Query 7: Previous Defaulters: Are they risky again? (Business Question: "If someone has defaulted before, are they more likely to default again?")
select 	
	cb_person_default_on_file as previous_default,
    count(*) as total_loans,
    sum(loan_status) as defaults,
    round(sum(loan_status) * 100.0 / count(*)  , 2) as default_rate_percent
from credit_risk
group by cb_person_default_on_file;

-- Query 8 — Risk Category Summary (Business Question: "How are loans distributed across Low, Medium and High risk?")
select 
    risk_category,
    count(*) as total_loans,
    round(count(*) * 100.0 / (select count(*) from credit_risk), 2) as percentage_of_portfolio,
    sum(loan_status) as defaults,
    round(sum(loan_status) * 100.0 / count(*), 2) as default_rate_percent,
    round(avg(loan_int_rate), 2) as avg_interest_rate
from credit_risk
group by risk_category
order by default_rate_percent desc;

-- Query 9 — High Risk Applicant Profile (Window Function) (Business Question: "What does a typical high-risk defaulter look like?")
select 
    person_age,
    person_income,
    loan_amnt,
    loan_int_rate,
    loan_intent,
    loan_grade,
    risk_category,
    round(avg(person_income) over (partition by risk_category), 2) as avg_income_by_risk,
    round(avg(loan_int_rate) over (partition by risk_category), 2) as avg_int_rate_by_risk,
    round(avg(loan_amnt) over (partition by risk_category), 2) as avg_loan_amnt_by_risk
from credit_risk
where risk_category = 'High Risk' and loan_status = 1
order by loan_int_rate desc;

-- Query 10 — Running Default Rate by Credit History Length (Business Question: "Does having a longer credit history reduce default risk?")
select
    cb_person_cred_hist_length,
    count(*) as total,
    sum(loan_status) as defaults,
    round(sum(loan_status) * 100.0 / count(*), 2) as default_rate_percent,
    round(avg(sum(loan_status) * 100.0 / count(*)) over (order by cb_person_cred_hist_length), 2) as running_avg_default_rate
from credit_risk
group by cb_person_cred_hist_length
order by cb_person_cred_hist_length;










































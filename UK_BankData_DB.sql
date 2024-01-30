-- specify database to use
use uk_bank

--- modify datatype age-int and balance as float
-- tiny int reduces space

ALTER TABLE [dbo].[tb_bank]
alter column age int

ALTER TABLE [dbo].[tb_bank]
alter column balance float

---select statement
select * from tb_bank

---select name,balance from tb_bank
select name,balance from tb_bank

---select balance,name from tb_bank
select balance,name from tb_bank

---select BALANCE,name from tb_bank
select BALANCE,name from tb_bank

--- first 5 customer
select top 5 * from tb_bank

--first 5 age, name 
select top 5 age,Name from tb_bank

select count(*) from tb_bank
--4014 rows

--- on selecting top more than existing data rows still it executes
select top 5000 age,Name from tb_bank

-- sorting data depending on balance 
select [customer id],balance from tb_bank order by balance desc

---Sort region by region and balance 
select * from tb_bank 
order by region,balance 

---Sort region by region and balance 
select * from tb_bank 
order by region desc,balance desc

-- fetch top 5 cutomer maintaining balnace in bank
select top 5 * from tb_bank order by balance desc

--select distinct region
select distinct region from tb_bank

--select distinct region and gender
select distinct region,gender from tb_bank

select distinct region,gender from tb_bank order by gender

--select all male customer
select * from tb_bank where gender = 'male'
--select all customer with age greater than 30
select * from tb_bank where age>30
--select all customer with age between 30 and 40
select * from tb_bank where age between 30 and 40

--like operator 
--- % - any number of character
--- _ - 1 single character

---select customer having names starting with A
select * from tb_bank where Name like 'A%'
--ending with A
select * from tb_bank where Name like '%A'
--start and end with A
select * from tb_bank where Name like '%A%'
--start and end with A with 1 character in between
select * from tb_bank where Name like 'A_A'
--start and end with A with 2 character in between
select * from tb_bank where Name like 'A__A'

-- select * from bank with atleast 5 char in name 5 underscore and %
select * from tb_bank where Name like '_____%'

--- select * from bank data where age is more than 30 and gender is male
select * from tb_bank where age>30 and gender = 'male'

--- fetch customer from england and wales
select * from tb_bank where region = 'England' or region ='Wales'
select * from tb_bank where region in ('England','Wales')

--- fetch customer not from england and wales
select * from tb_bank where region not in ('England','Wales')

-- add new column in query 
select * , 'Latest Data' as Type from tb_bank

-- add new calculated column to compute interest as 10% of balance
select * , 0.1*Balance as Interest from tb_bank

--compute interest as 10% of balance
select * , 0.1*Balance as Interest from tb_bank where Interest>5000 order by interest desc  
-- above query throws error -
select * , 0.1*Balance as Interest from tb_bank where 0.1*Balance>5000 order by interest desc 

---DML commands
--DELETE,INSERT,UPDATE
--DELETE - WIll delete value schema remains with no data
---delete works on row level 
delete * from tb_bank where [customer id] = '100000001'
--- when to delete table whole delete will take more time
---DDL command -Truncate - no where clause needed - to make table empty 
----step of execution
----1.saves metadata
----2.drop table
--------3.create the table
----faster execution
-- we cannot get the data back once truncated

----remove full table use DROP TABLE it drops the table and schema

begin tran
delete from tb_bank

select * from tb_bank

rollback

select * from tb_bank

---UPDATE command
--update region as England customer with customerid =400000002 
update tb_bank
set region = 'England'
where [customer id] = '400000002'


-- ADD new computed column Interest = 10% * Balance to table 
ALTER TABLE [dbo].[tb_bank]
ADD Interest float

update tb_bank
set Interest = 0.1*Balance

select * from tb_bank

select *,case 
		when balance>10000 then 0.1*balance
		when balance>5000 then 0.08*balance
		else 0.06*balance
		end as Interest2
from tb_bank

select *,case region
		when 'England' then 0.1*balance
		when 'Wales' then 0.08*balance
		when 'Scotland' then 0.06*balance
		else 0.05*balance
		end as Interest3
from tb_bank

select *,case 
		when balance>10000 then 0.1*balance
		when balance>5000 then 0.08*balance
		else 0.06*balance
		end as Interest2,
		case region
		when 'England' then 0.1*balance
		when 'Wales' then 0.08*balance
		when 'Scotland' then 0.06*balance
		else 0.05*balance
		end as Interest3
from tb_bank


select *,case 
		when balance>10000 and region = 'England' then 0.1*balance
		when balance>5000 and region =  'Wales' then 0.08*balance
		when balance<5000 and region =  'Scotland' then 0.06*balance
		else 0.05*balance
		end as InterestNew
from tb_bank

----Custom sorting
Select * from tb_bank
order by (
	case region 
		when 'England' then 2
		when 'Wales' then 1
		when 'Scotland' then 4
		else 3
	end
)


---Aggregation --- above we worked on row level 
--SUM,MIN,MAX,COUNT,avg - quickly to aggregate 
--count -counts not null value
select sum(balance)AS SUMvalue,max(Balance) AS maxvalue,min(Balance) As minvalue,count(Balance) AS totalcount,Avg(Balance) AS avgvalue from tb_bank
-- count distinct region
select count(distinct region) from tb_bank
-- count of data in overall database
select count(*) from tb_bank
---select avg age of male
select avg(age) from tb_bank where gender = 'male'
---select avg age of male and female
select avg(age),gender from tb_bank group by gender 
-- region wise average age
select avg(age),region from tb_bank group by region
-- both region nad gender
select avg(age),region,gender from tb_bank group by region,gender
--multiple aggregation is possible
select avg(age),avg(balance),region,gender from tb_bank group by region,gender
--above query gives aggregated data
---flitering aggregated data -- is done using having
select avg(age),avg(balance),region,gender from tb_bank group by region,gender having avg(age)>35

-- gets overall average age and balance wrt region and gender
select avg(age),avg(balance),region,gender 
from tb_bank 
group by region,gender with rollup
---flitering rollup 
select avg(age),avg(balance),region,gender 
from tb_bank 
group by region,gender with rollup
having avg(age)>35
--- can be used only with group by but cannot be used simply below code will throw error
select avg(age),avg(balance)
from tb_bank 
with rollup
having avg(age)>35
-- gets overall average age and balance wrt region and gender
select avg(age),avg(balance),region,gender,[Job Classification]
from tb_bank 
group by region,gender,[Job Classification] 
with rollup
---Controlled rollup
select region,gender,[Job Classification],
avg(age),avg(balance)
from tb_bank 
group by region,gender,rollup([Job Classification])


select region,[Job Classification],gender,
avg(age),avg(balance)
from tb_bank 
group by region,[Job Classification],rollup(gender)

--fetch total customer in region having balance>50000 
select count([customer id]),region
from tb_bank
where balance>50000
group by region

select count([customer id]),region
from tb_bank
where balance>50000
group by region with rollup 

select count([customer id]) as CustCount,region
from tb_bank
where balance>5000
group by region with rollup 
order by CustCount desc


select count([customer id]) as CustCount,region
from tb_bank
where balance>5000
group by region with rollup 
order by CustCount desc, (
	case region 
		when 'England' then 2
		when 'Wales' then 1
		when 'Scotland' then 4
		else 3
	end
)

select count(distinct [customer id]) as CustCount,region
from tb_bank
where balance>5000
group by region with rollup 
order by CustCount desc, (
	case region 
		when 'England' then 2
		when 'Wales' then 1
		when 'Scotland' then 4
		else 3
	end
)

----Grouping sets
select region,avg(age) AS Average
from tb_bank
group by GROUPING SETS
(
region,()
)


select region,gender,avg(age) AS Average
from tb_bank
group by GROUPING SETS
(
(region,gender),region,()
)


select region,gender,avg(age) AS Average
from tb_bank
group by GROUPING SETS
(
(region,gender),region
)

select region,[Job Classification],gender,
avg(age) AS AvgAge ,avg(balance) As AvgBalance
from tb_bank 
group by GROUPING SETS
(
(region,[Job Classification],gender),region
)

select region,[Job Classification],gender,
avg(age) AS AvgAge ,avg(balance) As AvgBalance
from tb_bank 
group by GROUPING SETS
(
(region,[Job Classification],gender),region,()
)

---below query will give group on individual column and rest column becomes null
select region,[Job Classification],gender,
avg(age) AS AvgAge ,avg(balance) As AvgBalance
from tb_bank 
group by GROUPING SETS
(
region,[Job Classification],gender
)

--correct way would be ensure ()
select region,[Job Classification],gender,
avg(age) AS AvgAge ,avg(balance) As AvgBalance
from tb_bank 
group by GROUPING SETS
(
(region,[Job Classification],gender)
)

select region,[Job Classification],gender,
avg(age) AS AvgAge ,avg(balance) As AvgBalance
from tb_bank 
group by GROUPING SETS
(
(region,[Job Classification],gender)
)
order by region























































































































































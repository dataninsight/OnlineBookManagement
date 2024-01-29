USE ey_jan

CREATE TABLE tb_employees
(EMPID int,
EmpName char(10),
DOJ date,
Salary float)

INSERT INTO tb_employees
values
(1,'Sam','2014-09-25',100.5),
(2,'John','2015-03-03',100.7)

DROP TABLE tb_employees

CREATE TABLE tb_employees
(EMPID int primary key,
EmpName char(10) not null,
DOJ date,
Salary float check(Salary>100))


INSERT INTO tb_employees
values
(1,'Sam','2014-09-25',100.5),
(2,'John','2015-03-03',100.7)

INSERT INTO tb_employees
values
(3,'Sammy','2014-09-25',100.5),
(4,'Leo','2014-09-25',190)

CREATE TABLE tb_dep
(Empid INT references tb_employees(EMPID),
department varchar(20))

INSERT INTO tb_dep
values(1,'HR')


ALTER TABLE [dbo].[tb_dep] WITH CHECK ADD FOREIGN KEY ([Empid]) 
REFERENCES [dbo].[tb_employees] ([EMPID]) ON DELETE cascade 
GO


USE ey_jan

--ALTER TABLE
-- Adding new column
---delete column
---modify column

ALTER TABLE [dbo].[tb_dep]
ADD Building varchar(20)

ALTER TABLE [dbo].[tb_dep]
drop column Building

ALTER TABLE [dbo].[tb_dep]
alter column department char(20)


















































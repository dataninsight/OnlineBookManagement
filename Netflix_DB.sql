CREATE DATABASE netflix_db

USE netflix_db

DROP TABLE tb_actors

CREATE TABLE tb_customers
(CUSTID int primary key,CustName char(20) not null ,activeplan char(10),activelocation char(20))

CREATE TABLE tb_actors
(ActorID int primary key,ActorName char(20) not null)

CREATE TABLE tb_directors
(DirectorID int primary key,DirectorName char(20) not null)

CREATE TABLE tb_orders
(DirectorID INT references tb_directors(DirectorID),
ActorID INT references tb_actors(ActorID),
CUSTID INT references tb_customers(CUSTID),
OrderID int primary key,FilmName char(20) not null)

ALTER TABLE [dbo].[tb_orders] WITH CHECK ADD FOREIGN KEY ([DirectorID]) 
REFERENCES [dbo].[tb_directors] ([DirectorID]) ON DELETE cascade 
GO

ALTER TABLE [dbo].[tb_orders] WITH CHECK ADD FOREIGN KEY ([ActorID]) 
REFERENCES [dbo].[tb_actors] ([ActorID]) ON DELETE cascade 
GO

ALTER TABLE [dbo].[tb_orders] WITH CHECK ADD FOREIGN KEY ([CUSTID]) 
REFERENCES [dbo].[tb_customers] ([CustID]) ON DELETE cascade 
GO

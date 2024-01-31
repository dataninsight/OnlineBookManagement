--create new database to store bookstore database
CREATE DATABASE bookstore_db

-- use bookstore database
use bookstore_db
-----------------------------------------------------------------
--- uploaded flatfile datasource

---view data
select * from booksdataset

---Count of rows in data
select count(*) from booksdataset
--103063

-- understand schema of table
EXEC sp_columns booksdataset

SELECT COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'booksdataset'

--- null count columnwise
SELECT 
	SUM(CASE WHEN Title IS NULL THEN 1 ELSE 0 END) AS titlenullcount,
	SUM(CASE WHEN Authors IS NULL THEN 1 ELSE 0 END) AS authornullcount,
	SUM(CASE WHEN Description IS NULL THEN 1 ELSE 0 END) AS descnullcount,
	SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS catnullcount,
	SUM(CASE WHEN Publisher IS NULL THEN 1 ELSE 0 END) AS publishernullcount,
	SUM(CASE WHEN Price_Starting_With IS NULL THEN 1 ELSE 0 END) AS pricenullcount,
	SUM(CASE WHEN Publish_Date_Month IS NULL THEN 1 ELSE 0 END) AS monthnullcount,
	SUM(CASE WHEN Publish_Date_Year IS NULL THEN 1 ELSE 0 END) AS yearnullcount
FROM booksdataset

--replace null with "" and trim 
UPDATE booksdataset
SET 
	Title = COALESCE(TRIM(Title), ''),
	Authors = COALESCE(TRIM(Authors), ''),
	Description = COALESCE(TRIM(Description), ''),
	Category = COALESCE(TRIM(Category), ''),
	Publisher = COALESCE(TRIM(Publisher), ''),
	Publish_Date_Month = COALESCE(TRIM(Publish_Date_Month), '')

Select count(distinct title)
from booksdataset
--97109

select count(distinct authors)
from booksdataset
--63570

select count(distinct publisher)
from booksdataset
--12822

select count(*) as rwcount,title,authors,publisher
from booksdataset
group by title,authors,publisher
having count(*)>1
order by rwcount desc
---many duplicates

--- we notice there are mutiple rows with author starting with "By " followed by Author Name
---remove By before autorname
UPDATE booksdataset
SET AUTHORS = REPLACE(AUTHORS, 'By ','')
WHERE AUTHORS LIKE 'By %'
--- there are multiple authors like this in same cell Abbott, Tony and Steadman, Broeck (ILT) - only extract first author
UPDATE booksdataset
SET AUTHORS = SUBSTRING(AUTHORS,1,CASE WHEN CHARINDEX(',',AUTHORS) > 0 
									THEN CHARINDEX(',',AUTHORS) - 1
									ELSE LEN(AUTHORS) END)
WHERE CHARINDEX(',',AUTHORS) > 0 

--there are multiple rows in database with numerical value in AUTHORS COLUMN - this needs to be deleted 
DELETE 
FROM BOOKSDATASET
WHERE AUTHORS NOT LIKE '%[^0-9]%'
--there are multiple rows in database with and,& in AUTHORS COLUMN - Zondervan Publishing House and Yancey if found like this select first 
UPDATE booksdataset
SET AUTHORS = CASE WHEN CHARINDEX('&',AUTHORS) > 0 
					THEN LEFT(AUTHORS,CHARINDEX('&',AUTHORS) - 1)
				   WHEN CHARINDEX('AND',UPPER(AUTHORS)) > 0 
					THEN LEFT(AUTHORS,CHARINDEX('AND',UPPER(AUTHORS)) - 1)
				  ELSE AUTHORS
			  END
--there are multiple special characters in Authors column in database if . replace with " "
UPDATE booksdataset
SET AUTHORS = REPLACE(AUTHORS,'.',' ')
-- replace special character with space in Authors Column
UPDATE Booksdataset 
SET AUTHORS = REGEXP_REPLACE(TRANSLATE(AUTHORS,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
												'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'),
												'[^a-zA-Z0-9\s]',' ')
SELECT DISTINCT AUTHORS FROM BOOKSDATASET
---above query didnt work REGEXP_REPLACE DOESNT EXIST 
DECLARE @count INT = 1;
WHILE @count > 0
BEGIN
	UPDATE BooksDataset
	SET [Authors] = REPLACE([Authors], SUBSTRING([Authors], PATINDEX('%[^a-zA-Z0-9\s]%',[Authors]),1),' ');
	SET @count = (SELECT PATINDEX('%[^a-zA-Z0-9\s]%', [Authors]));
END;

UPDATE booksdataset
SET AUTHORS = REPLACE(AUTHORS,'-',' ')

UPDATE booksdataset
SET AUTHORS = REPLACE(AUTHORS,'(',' ')

UPDATE booksdataset
SET AUTHORS = REPLACE(AUTHORS,')',' ')

UPDATE booksdataset
SET AUTHORS = REPLACE(AUTHORS,'_',' ')

UPDATE booksdataset
SET AUTHORS = REPLACE(AUTHORS,'-',' ')

UPDATE booksdataset
SET AUTHORS = REPLACE(AUTHORS,'~',' ')

UPDATE booksdataset
SET [AUTHORS] = LTRIM(RTRIM([AUTHORS]))

UPDATE booksdataset
SET [AUTHORS] = 
	CASE 
		WHEN CHARINDEX(' ',[AUTHORS]) > 0 
			AND LEN(SUBSTRING([AUTHORS],CHARINDEX(' ',[AUTHORS])+1, LEN([AUTHORS])))>1
		THEN SUBSTRING ([AUTHORS],1,CHARINDEX(' ',[AUTHORS],CHARINDEX(' ',[AUTHORS])+1))
		WHEN CHARINDEX(' ',[AUTHORS]) > 0 
			AND LEN(SUBSTRING([AUTHORS],CHARINDEX(' ',[AUTHORS])+1, LEN([AUTHORS])))<=1
			AND CHARINDEX(' ',[AUTHORS], CHARINDEX(' ',[AUTHORS])+1)>0
		THEN SUBSTRING ([AUTHORS],1,CHARINDEX(' ',[AUTHORS],CHARINDEX(' ',[AUTHORS],CHARINDEX(' ',[AUTHORS])+1)))
		ELSE [AUTHORS]
	END;

UPDATE booksdataset
SET [AUTHORS] = UPPER([AUTHORS])

SELECT 
DISTINCT AUTHORS
FROM BOOKSDATASET
ORDER BY AUTHORS DESC

SELECT COUNT(DISTINCT AUTHORS) 
FROM BOOKSDATASET
--22641

SELECT count(*) 
FROM BOOKSDATASET
WHERE AUTHORS = ''
--7327

SELECT * 
FROM BOOKSDATASET 
WHERE AUTHORS = ''
--noticed not proper values are defined for other rows aswell hence drop these rows from data set
DELETE 
FROM BOOKSDATASET 
WHERE AUTHORS = ''
--DROP COLUMN DESCRIPTION as it is of not much significance for analysis
ALTER TABLE [dbo].[booksdataset]
drop column Description

SELECT * 
FROM BOOKSDATASET

--CATEGORY Cleaning
SELECT COUNT(DISTINCT category) 
FROM Booksdataset
--3079

--- there are multiple category like this in same cell Self-help , Personal Growth , Self-Esteem - only extract first category
UPDATE booksdataset
SET category = SUBSTRING(category,1,CASE WHEN CHARINDEX(',',category) > 0 
									THEN CHARINDEX(',',category) - 1
									ELSE LEN(category) END)
WHERE CHARINDEX(',',category) > 0 

SELECT COUNT(DISTINCT category) 
FROM Booksdataset
--58

SELECT DISTINCT CATEGORY 
FROM Booksdataset
ORDER BY CATEGORY

SELECT * FROM
BOOKSDATASET
WHERE CATEGORY = ''
--21288 records
-- without category we cannot define relationship well hence deleting these records 

DELETE 
FROM BOOKSDATASET
WHERE CATEGORY = ''

SELECT COUNT(*)
FROM BOOKSDATASET
--74445

UPDATE booksdataset
SET CATEGORY = REPLACE(CATEGORY,'&','and')
UPDATE booksdataset
SET CATEGORY = REPLACE(CATEGORY,'-','')
UPDATE booksdataset
SET CATEGORY = REPLACE(CATEGORY,':','')
UPDATE booksdataset
SET [CATEGORY] = UPPER([CATEGORY])
--Convert to this category --- from this
---ART -----------------------PERFORMING ARTS,CRAFTS AND HOBBIES 
--NONFICTION -----JUVENILE NONFICTION,YOUNG ADULT NONFICTION
--EDUCATION ------------------STUDY AIDS,REFERENCE
--FICTION --------------------YOUNG ADULT FICTION,JUVENILE FICTION 
--GAMES ----------------------GAMES AND ACTIVITIES
--RELIGION -------------------BIBLES
--TECHNOLOGY AND ENGINEERING ---COMPUTERS 
UPDATE booksdataset
SET CATEGORY = 
	CASE WHEN CATEGORY = 'PERFORMING ARTS' THEN 'ART'
		WHEN CATEGORY = 'CRAFTS AND HOBBIES' THEN 'ART'
		WHEN CATEGORY = 'JUVENILE NONFICTION' THEN 'NONFICTION'
		WHEN CATEGORY = 'YOUNG ADULT NONFICTION' THEN 'NONFICTION'
		WHEN CATEGORY = 'REFERENCE' THEN 'EDUCTAION'
		WHEN CATEGORY = 'STUDY AIDS' THEN 'EDUCTAION'
		WHEN CATEGORY = 'YOUNG ADULT FICTION' THEN 'FICTION'
		WHEN CATEGORY = 'JUVENILE FICTION' THEN 'FICTION'
		WHEN CATEGORY = 'GAMES AND ACTIVITIES' THEN 'GAMES'
		WHEN CATEGORY = 'BIBLES' THEN 'RELIGION'
		WHEN CATEGORY = 'COMPUTERS' THEN 'TECHNOLOGY AND ENGINEERING'
	ELSE CATEGORY
	END

SELECT COUNT(DISTINCT CATEGORY)
FROM BOOKSDATASET
--48
SELECT DISTINCT CATEGORY
FROM BOOKSDATASET

SELECT * FROM BOOKSDATASET	

SELECT COUNT(DISTINCT PUBLISHER)
FROM BOOKSDATASET
--6679
SELECT DISTINCT PUBLISHER
FROM BOOKSDATASET
ORDER BY PUBLISHER 

UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,'&','and')

--there are multiple rows in database with numerical value in PUBLISHER COLUMN - this needs to be deleted 
DELETE 
FROM BOOKSDATASET
WHERE PUBLISHER NOT LIKE '%[^0-9]%'

--there are multiple special characters in Authors column in database if . replace with " "
UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,'.',' ')
-- replace special character with space in Authors Column
UPDATE Booksdataset 
SET PUBLISHER = REGEXP_REPLACE(TRANSLATE(PUBLISHER,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
												'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'),
												'[^a-zA-Z0-9\s]',' ')
SELECT DISTINCT PUBLISHER FROM BOOKSDATASET
---above query didnt work REGEXP_REPLACE DOESNT EXIST 
DECLARE @count INT = 1;
WHILE @count > 0
BEGIN
	UPDATE BooksDataset
	SET [PUBLISHER] = REPLACE([PUBLISHER], SUBSTRING([PUBLISHER], PATINDEX('%[^a-zA-Z0-9\s]%',[PUBLISHER]),1),' ');
	SET @count = (SELECT PATINDEX('%[^a-zA-Z0-9\s]%', [PUBLISHER]));
END;
UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,'"','')
UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,'*','')
UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,'[','')
UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,']','')
UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,'(','')
UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,')','')
UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,'/','')
UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,':','')
UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,';','')
UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,'-','')
UPDATE booksdataset
SET PUBLISHER = REPLACE(PUBLISHER,',',' ')
UPDATE booksdataset
SET [PUBLISHER] = LTRIM(RTRIM([PUBLISHER]))
UPDATE booksdataset
SET [PUBLISHER] = 
	CASE 
		WHEN CHARINDEX(' ',[PUBLISHER]) > 0 
			AND LEN(SUBSTRING([PUBLISHER],CHARINDEX(' ',[PUBLISHER])+1, LEN([PUBLISHER])))>1
		THEN SUBSTRING ([PUBLISHER],1,CHARINDEX(' ',[PUBLISHER],CHARINDEX(' ',[PUBLISHER])+1))
		WHEN CHARINDEX(' ',[PUBLISHER]) > 0 
			AND LEN(SUBSTRING([PUBLISHER],CHARINDEX(' ',[PUBLISHER])+1, LEN([PUBLISHER])))<=1
			AND CHARINDEX(' ',[PUBLISHER], CHARINDEX(' ',[PUBLISHER])+1)>0
		THEN SUBSTRING ([PUBLISHER],1,CHARINDEX(' ',[PUBLISHER],CHARINDEX(' ',[PUBLISHER],CHARINDEX(' ',[PUBLISHER])+1)))
		ELSE [PUBLISHER]
	END;
UPDATE booksdataset
SET [PUBLISHER] = UPPER([PUBLISHER])
SELECT DISTINCT PUBLISHER FROM BOOKSDATASET

SELECT COUNT(*) 
FROM BOOKSDATASET
WHERE PUBLISHER LIKE '_'
--579

SELECT COUNT(*) 
FROM BOOKSDATASET
WHERE AUTHORS LIKE '_'
--469

--DELETE THESE SINGLE CHARACTER AUTHORS AND PUBLISHER RECORDS

DELETE 
FROM BOOKSDATASET
WHERE 
PUBLISHER LIKE '_' OR 
AUTHORS LIKE '_'
--1034 records dropped 

SELECT COUNT(*)
FROM BOOKSDATASET
--73409

SELECT COUNT(DISTINCT AUTHORS)
FROM BOOKSDATASET
--17705

SELECT COUNT(DISTINCT PUBLISHER)
FROM BOOKSDATASET
--3253

SELECT COUNT(DISTINCT CATEGORY)
FROM BOOKSDATASET
--48

SELECT COUNT(DISTINCT PUBLISH_DATE_MONTH)
FROM BOOKSDATASET
--12

SELECT DISTINCT TITLE 
FROM BOOKSDATASET

UPDATE booksdataset
SET TITLE = REPLACE(TITLE,'&','and')
UPDATE booksdataset
SET TITLE = REPLACE(TITLE,'''','')
UPDATE booksdataset
SET TITLE = REPLACE(TITLE,'`','')
UPDATE booksdataset
SET TITLE = REPLACE(TITLE,'.','')
UPDATE booksdataset
SET TITLE = REPLACE(TITLE,'!','')
UPDATE booksdataset
SET [TITLE] = LTRIM(RTRIM([TITLE]))
--there are multiple rows in database with numerical value in PUBLISHER COLUMN - this needs to be deleted 
DELETE 
FROM BOOKSDATASET
WHERE TITLE NOT LIKE '%[^0-9]%'
UPDATE booksdataset
SET [TITLE] = 
	CASE 
		WHEN LEN(TITLE) - LEN(REPLACE([TITLE],' ','')) + 1 <= 5 THEN TITLE
		ELSE SUBSTRING([TITLE],1,CHARINDEX(' ',[TITLE]+' ',6)-1)
	END;
DELETE 
FROM BOOKSDATASET
WHERE TITLE LIKE '[0-9]%'
--844 
DELETE 
FROM BOOKSDATASET
WHERE TITLE LIKE '[^a-zA-Z]%'
--7
SELECT DISTINCT TITLE
FROM BOOKSDATASET
ORDER BY TITLE
--51620

DELETE 
FROM BOOKSDATASET
WHERE PUBLISHER LIKE ''
--26622

SELECT COUNT(DISTINCT TITLE)
FROM BOOKSDATASET
--34558

SELECT COUNT(DISTINCT AUTHORS)
FROM BOOKSDATASET
--13150

SELECT COUNT(DISTINCT CATEGORY)
FROM BOOKSDATASET
--46

SELECT COUNT(DISTINCT PUBLISHER)
FROM BOOKSDATASET
--3227

Select count(*) as rwcnt,title,category,authors,publisher
from booksdataset
group by title,category,authors,publisher
having count(*)>1
ORDER BY rwcnt DESC
--- looks like same book has multiple copies now need to devise logic to pick latest book 

ALTER TABLE booksdataset
ADD published_yearmonth INT;

UPDATE BOOKSDATASET
SET published_yearmonth = ([Publish_Date_Year] * 100) +
				CASE
				WHEN [Publish_Date_Month] = 'January' THEN 1
				WHEN [Publish_Date_Month] = 'February' THEN 2
				WHEN [Publish_Date_Month] = 'March' THEN 3
				WHEN [Publish_Date_Month] = 'April' THEN 4
				WHEN [Publish_Date_Month] = 'May' THEN 5
				WHEN [Publish_Date_Month] = 'June' THEN 6
				WHEN [Publish_Date_Month] = 'July' THEN 7
				WHEN [Publish_Date_Month] = 'August' THEN 8
				WHEN [Publish_Date_Month] = 'September' THEN 9
				WHEN [Publish_Date_Month] = 'October' THEN 10
				WHEN [Publish_Date_Month] = 'November' THEN 11
				WHEN [Publish_Date_Month] = 'December' THEN 12
				END


EXEC sp_rename 'booksdataset.Publish_Date_Year','PublishYear','COLUMN';

EXEC sp_rename 'booksdataset.Publish_Date_Month','PublishMonth','COLUMN';

EXEC sp_rename 'booksdataset.published_yearmonth','PublishYearMonth','COLUMN';


SELECT * 
FROM BOOKSDATASET
-----Only keep latest publication of books ----
Select count(*) as rwcnt,title,category,authors,publisher
from booksdataset
group by title,category,authors,publisher
having count(*)>1
ORDER BY rwcnt DESC

WITH LatestBooks AS(
	SELECT authors,title,publisher,category,
	MAX(publishyearmonth) AS latestpublishyearmonth
	FROM BooksDataset
	GROUP BY authors,title,publisher,category
	)
DELETE FROM b
FROM booksdataset b
JOIN LatestBooks lb ON b.authors = lb.authors
AND b.title = lb.title
AND b.publisher = lb.publisher
AND b.category = lb.category
AND b.publishyearmonth < lb.latestpublishyearmonth
--Dropped 1725 records 

Select count(*) as rwcnt,title,category,authors,publisher
from booksdataset
group by title,category,authors,publisher
having count(*)>1
ORDER BY rwcnt DESC

Select * 
from booksdataset
where title = 'Harcourt School'
--noticed there is multiple records on Price_Starting_With column 
--need to write logic to pick book with lowest price available


WITH LatestBooks AS(
	SELECT authors,title,publisher,category,
	MIN([Price_Starting_With]) AS minprice
	FROM BooksDataset
	GROUP BY authors,title,publisher,category
	)
DELETE FROM b
FROM booksdataset b
JOIN LatestBooks lb ON b.authors = lb.authors
AND b.title = lb.title
AND b.publisher = lb.publisher
AND b.category = lb.category
AND b.[Price_Starting_With] > lb.minprice
-- 82 rows dropped

UPDATE BOOKSDATASET
SET [Price_Starting_With] = ROUND([Price_Starting_With] * 83,2)

Select count(*) as rwcnt,title,category,authors,publisher,publishmonth,publishyearmonth,publishyear
from booksdataset
group by title,category,authors,publisher,publishmonth,publishyearmonth,publishyear
having count(*)>1
ORDER BY rwcnt DESC

USE bookstore_db

CREATE TABLE tb_books(
Title VARCHAR(255) NOT NULL,
Author VARCHAR(255) NOT NULL,
Category VARCHAR(255) NOT NULL,
Publisher VARCHAR(255) NOT NULL,
Price DECIMAL NOT NULL ,
PublishMonth  VARCHAR(10) NOT NULL,
PublishYear Smallint NOT NULL, 
PublishYearMonth Int NOT NULL)

WITH CTE AS(
SELECT *,ROW_NUMBER() OVER 
(PARTITION BY title,category,authors,publisher,[Price_Starting_With],publishmonth,publishyear,publishyearmonth ORDER BY (SELECT 0))AS RwNum
FROM BOOKSDATASET
)
INSERT INTO tb_books(Title,Author,Category,Publisher,Price,PublishMonth,PublishYear,PublishYearMonth)
SELECT title,category,authors,publisher,[Price_Starting_With],publishmonth,publishyear,publishyearmonth 
FROM CTE
WHERE RwNum = 1

select * from tb_books

Select count(*) as rwcnt,Title,Author,Category,Publisher,Price,PublishMonth,PublishYear,PublishYearMonth
from tb_books
group by Title,Author,Category,Publisher,Price,PublishMonth,PublishYear,PublishYearMonth
having count(*)>1
ORDER BY rwcnt DESC
--- No duplicates--

select count(*) from tb_books
--44067
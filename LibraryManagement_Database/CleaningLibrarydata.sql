-- create librarymgmt database 
CREATE DATABASE librarymgmt_db

-- use librarymgmt database 
USE librarymgmt_db

--Imported data to librarymgmt_db - Bookscleandataset -into table [dbo].[tb_rawbooks]
-- see contents of [dbo].[tb_rawbooks]
SELECT * 
FROM [dbo].[tb_rawbooks]

-- see total count  of [dbo].[tb_rawbooks]
SELECT count(*) 
FROM [dbo].[tb_rawbooks]

--display schema of table [dbo].[tb_rawbooks]
EXEC sp_columns tb_rawbooks

SELECT COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tb_rawbooks'

--We can drop description as its of no use
ALTER TABLE [dbo].[tb_rawbooks]
DROP COLUMN Description

--- null count columnwise
SELECT 
	SUM(CASE WHEN Title IS NULL THEN 1 ELSE 0 END) AS titlenullcount,
	SUM(CASE WHEN Authors IS NULL THEN 1 ELSE 0 END) AS authornullcount,
	SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS catnullcount,
	SUM(CASE WHEN Publisher IS NULL THEN 1 ELSE 0 END) AS publishernullcount,
	SUM(CASE WHEN Price_Starting_With IS NULL THEN 1 ELSE 0 END) AS pricenullcount,
	SUM(CASE WHEN Publish_Date_Month IS NULL THEN 1 ELSE 0 END) AS monthnullcount,
	SUM(CASE WHEN Publish_Date_Year IS NULL THEN 1 ELSE 0 END) AS yearnullcount
FROM [dbo].[tb_rawbooks]

--replace null with "" and trim 
UPDATE tb_rawbooks
SET 
	Title = COALESCE(TRIM(Title), ''),
	Authors = COALESCE(TRIM(Authors), ''),
	Category = COALESCE(TRIM(Category), ''),
	Publisher = COALESCE(TRIM(Publisher), ''),
	Publish_Date_Month = COALESCE(TRIM(Publish_Date_Month), '')

-- get distinct count of records in each column 
Select count(distinct title) AS TotalCount, 'Title' AS ColumnName from tb_rawbooks
UNION
Select count(distinct authors) AS TotalCount, 'Authors' AS ColumnName from tb_rawbooks
UNION
select count(distinct publisher) AS TotalCount, 'Publisher' AS ColumnName from tb_rawbooks
UNION
Select count(distinct Category) AS TotalCount, 'Category' AS ColumnName from tb_rawbooks

--------------------------------------------------------------------------------------------------------------------------------
--CLEANING AUTHORS COLUMN

/*we notice there are mutiple rows with author 
starting with "By " followed by Author Name
remove By before autorname
*/

UPDATE tb_rawbooks
SET AUTHORS = REPLACE(AUTHORS, 'By ','')
WHERE AUTHORS LIKE 'By %'

/*there are multiple authors like this in same cell 
Abbott, Tony and Steadman, Broeck (ILT) 
- only extract first author
*/

UPDATE tb_rawbooks
SET AUTHORS = SUBSTRING(AUTHORS,1,CASE 
								WHEN CHARINDEX(',',AUTHORS) > 0 
								THEN CHARINDEX(',',AUTHORS) - 1
								ELSE LEN(AUTHORS) 
								END)

/* there are multiple rows in database 
starting with numerical value in AUTHORS COLUMN 
- this needs to be deleted 
for our analysis we only consider if authors name start with alphabet
*/

DELETE 
FROM tb_rawbooks
WHERE AUTHORS NOT LIKE '[^0-9]%'

/* there are multiple rows in database with 
 and,& in AUTHORS COLUMN - 
 Zondervan Publishing House and Yancey 
 if found like this select first author name only
*/

UPDATE tb_rawbooks
SET AUTHORS = CASE WHEN CHARINDEX('&',AUTHORS) > 0 
				    THEN LEFT(AUTHORS,CHARINDEX('&',AUTHORS) - 1)
				   WHEN CHARINDEX('AND',UPPER(AUTHORS)) > 0 
					THEN LEFT(AUTHORS,CHARINDEX('AND',UPPER(AUTHORS)) - 1)
				  ELSE AUTHORS
			  END

/* there are multiple special characters 
  in Authors column in database replace them with ""
*/
UPDATE tb_rawbooks
SET AUTHORS = REPLACE(AUTHORS,'.',' ')
UPDATE tb_rawbooks
SET AUTHORS = REPLACE(AUTHORS,'-',' ')
UPDATE tb_rawbooks
SET AUTHORS = REPLACE(AUTHORS,'(',' ')
UPDATE tb_rawbooks
SET AUTHORS = REPLACE(AUTHORS,')',' ')
UPDATE tb_rawbooks
SET AUTHORS = REPLACE(AUTHORS,'_',' ')
UPDATE tb_rawbooks
SET AUTHORS = REPLACE(AUTHORS,'-',' ')
UPDATE tb_rawbooks
SET AUTHORS = REPLACE(AUTHORS,'~',' ')
UPDATE tb_rawbooks
SET AUTHORS = REPLACE(AUTHORS,'[',' ')
UPDATE tb_rawbooks
SET AUTHORS = REPLACE(AUTHORS,']',' ')
UPDATE tb_rawbooks
SET AUTHORS = REPLACE(AUTHORS,'"',' ')
UPDATE tb_rawbooks
SET [AUTHORS] = LTRIM(RTRIM([AUTHORS]))

/* 
 In Authors column in tb_rawbooks if Authors Name has more than 2 words
 if 2nd word has more than 1 letter length consider only 2 words
 else consider 3 words
*/

UPDATE tb_rawbooks
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

--check all authors
SELECT 
DISTINCT AUTHORS
FROM tb_rawbooks
ORDER BY AUTHORS DESC

-- Noticed #VALUE! coming in one entry of AUTHORS 
DELETE
FROM tb_rawbooks
WHERE AUTHORS = '#VALUE!'
-- 1 record dropped

-- DROP ALL single character Author 
DELETE
FROM tb_rawbooks
WHERE AUTHORS LIKE '_ _'
--326 records dropped

-- DROP ALL single character Author 
DELETE
FROM tb_rawbooks
WHERE AUTHORS LIKE '_'
-- 596 records dropped

/* DROP ALL empty records for Author 
 without Author we cannot define relationship well hence deleting these records
 */
DELETE
FROM tb_rawbooks
WHERE AUTHORS=' '
--7326 records dropped

SELECT COUNT(DISTINCT AUTHORS) 
FROM tb_rawbooks
--22552

---------------------------------------------------------------------------------------------------------------------------------
--CATEGORY Cleaning
SELECT COUNT(DISTINCT category) 
FROM tb_rawbooks
--3076

/* there are multiple category like this in same cell 
Self-help , Personal Growth , Self-Esteem 
- only extract first category
*/
UPDATE tb_rawbooks
SET category = SUBSTRING(category,1,CASE WHEN CHARINDEX(',',category) > 0 
									THEN CHARINDEX(',',category) - 1
									ELSE LEN(category) 
									END)

/* DROP ALL empty records for Category
 without Category we cannot define relationship well hence deleting these records
 */
DELETE 
FROM tb_rawbooks
WHERE CATEGORY = ''
-- 20838 records dropped

/* there are multiple special characters 
  in Category column in database replace them with ""
*/
UPDATE tb_rawbooks
SET CATEGORY = REPLACE(CATEGORY,'&','and')
UPDATE tb_rawbooks
SET CATEGORY = REPLACE(CATEGORY,'-','')
UPDATE tb_rawbooks
SET CATEGORY = REPLACE(CATEGORY,':','')
UPDATE tb_rawbooks
SET [CATEGORY] = UPPER([CATEGORY])

/*Convert following category to given category
IF - PERFORMING ARTS,CRAFTS AND HOBBIES         AS ART   
IF - JUVENILE NONFICTION,YOUNG ADULT NONFICTION AS NONFICTION 
IF - STUDY AIDS,REFERENCE                       AS EDUCATION 
IF - YOUNG ADULT FICTION,JUVENILE FICTION       AS FICTION 
IF - GAMES AND ACTIVITIES                       AS GAMES 
IF - BIBLES                                     AS RELIGION 
IF - COMPUTERS                                  AS TECHNOLOGY AND ENGINEERING
*/

UPDATE tb_rawbooks
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
FROM tb_rawbooks
--48
---------------------------------------------------------------------------------------------------------------------------------
--PUBLISHER Cleaning

SELECT COUNT(DISTINCT PUBLISHER)
FROM tb_rawbooks
--6654

SELECT DISTINCT PUBLISHER
FROM tb_rawbooks
ORDER BY PUBLISHER 

/* there are multiple special characters 
  in Publisher column in database replace them with ""
*/
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,'&','and')
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,'"','')

/* there are multiple rows in database 
starting with numerical value in PUBLISHER COLUMN 
- this needs to be deleted 
for our analysis we only consider if PUBLISHER name start with alphabet
*/
DELETE 
FROM tb_rawbooks
WHERE PUBLISHER NOT LIKE '[^0-9]%'
-- 34 records affected

/* there are multiple special characters 
  in Category column in database replace them with ""
*/
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,'.',' ')
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,'*','')
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,'[',' ')
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,']',' ')
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,'(','')
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,')','')
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,'/','')
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,':','')
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,';','')
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,'-','')
UPDATE tb_rawbooks
SET PUBLISHER = REPLACE(PUBLISHER,',',' ')
UPDATE tb_rawbooks
SET [PUBLISHER] = LTRIM(RTRIM([PUBLISHER]))

/* 
 In Publisher column in tb_rawbooks if Publisher Name has more than 2 words
 if 2nd word has more than 1 letter length consider only 2 words
 else consider 3 words
*/
UPDATE tb_rawbooks
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

SELECT DISTINCT PUBLISHER 
FROM tb_rawbooks
order by publisher desc

/* DROP ALL empty records for Publisher
 without Publisher we cannot define relationship well hence deleting these records
 */
DELETE 
FROM tb_rawbooks
WHERE publisher = ''
--26934 records dropped

---------------------------------------------------------------------------------------------------------------------------------
--Title Cleaning

SELECT COUNT(DISTINCT TITLE)
FROM tb_rawbooks
-45176

SELECT DISTINCT TITLE 
FROM tb_rawbooks

/* there are multiple special characters 
  in Category column in database replace them with ""
*/
UPDATE tb_rawbooks
SET TITLE = REPLACE(TITLE,'&','and')
UPDATE tb_rawbooks
SET TITLE = REPLACE(TITLE,'''','')
UPDATE tb_rawbooks
SET TITLE = REPLACE(TITLE,'`','')
UPDATE tb_rawbooks
SET TITLE = REPLACE(TITLE,'.','')
UPDATE tb_rawbooks
SET TITLE = REPLACE(TITLE,'!','')
UPDATE tb_rawbooks
SET [TITLE] = LTRIM(RTRIM([TITLE]))

/* 
 In Title column in tb_rawbooks if Title Name has 
 more than 10 words extract max 10 words
*/
UPDATE tb_rawbooks
SET [TITLE] = 
	CASE 
		WHEN LEN(TITLE) - LEN(REPLACE([TITLE],' ','')) + 1 <= 10 THEN TITLE
		ELSE SUBSTRING([TITLE],1,CHARINDEX(' ',[TITLE]+' ',11)-1)
	END;
------------------------------------------------------------------------------------------------------------------------------
/*
Create new column YearMonth 
to combine Publish Year+Publish Month
*/

--Add new coulmn published_yearmonth to table tb_rawbooks
ALTER TABLE tb_rawbooks
ADD published_yearmonth INT;

-- Update value to coulmn published_yearmonth
UPDATE tb_rawbooks
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

--Rename Coulmn Publish_Date_Year to PublishYear in table tb_rawbooks
EXEC sp_rename 'tb_rawbooks.Publish_Date_Year','PublishYear','COLUMN';

--Rename Coulmn Publish_Date_Month to PublishMonth in table tb_rawbooks
EXEC sp_rename 'tb_rawbooks.Publish_Date_Month','PublishMonth','COLUMN';

--Rename Coulmn published_yearmonth to PublishYearMonth in table tb_rawbooks
EXEC sp_rename 'tb_rawbooks.published_yearmonth','PublishYearMonth','COLUMN';

SELECT COUNT(*)
FROM tb_rawbooks
--47001
---------------------------------------------------------------------------------------------------------------------------------
--Only keep latest publication of books ----
/*Handling multiple publication records of same books 
- need to devise logic to pick latest book 
*/

Select count(*) as rwcnt,title,category,authors,publisher
from tb_rawbooks
group by title,category,authors,publisher
having count(*)>1
ORDER BY rwcnt DESC

--Safely begin deleting records--
BEGIN Transaction

WITH LatestBooks AS(
	SELECT authors,title,publisher,category,
	MAX(publishyearmonth) AS latestpublishyearmonth
	FROM tb_rawbooks
	GROUP BY authors,title,publisher,category
	)
DELETE FROM b
FROM tb_rawbooks b
JOIN LatestBooks lb ON b.authors = lb.authors
AND b.title = lb.title
AND b.publisher = lb.publisher
AND b.category = lb.category
AND b.publishyearmonth < lb.latestpublishyearmonth
--Dropped 990 records 

--cross check if it picked recent published book and see if any duplicate
Select count(*) as rwcnt,title,category,authors,publisher
from tb_rawbooks
group by title,category,authors,publisher
having count(*)>1
ORDER BY rwcnt DESC
--there are duplicates but not wrt recent publishyearmonth

--COMMIT/ROLLBACK 
COMMIT 
---------------------------------------------------------------------------------------------------------------------------------
--Only keep books with lesser price --
/* noticed there is multiple records on Price_Starting_With column 
need to write logic to pick book with lowest price available after discount 
*/
Select count(*) as rwcnt,title,category,authors,publisher
from tb_rawbooks
group by title,category,authors,publisher
having count(*)>1
ORDER BY rwcnt DESC

--Safely begin deleting records--
BEGIN Transaction

WITH LatestBooks AS(
	SELECT authors,title,publisher,category,
	MIN([Price_Starting_With]) AS minprice
	FROM tb_rawbooks
	GROUP BY authors,title,publisher,category
	)
DELETE FROM b
FROM tb_rawbooks b
JOIN LatestBooks lb ON b.authors = lb.authors
AND b.title = lb.title
AND b.publisher = lb.publisher
AND b.category = lb.category
AND b.[Price_Starting_With] > lb.minprice
-- 55 rows dropped

--cross check if it picked recent published book and see if any duplicate
Select count(*) as rwcnt,title,category,authors,publisher
from tb_rawbooks
group by title,category,authors,publisher
having count(*)>1
ORDER BY rwcnt DESC
--still there are duplicates but not respect to price 


--COMMIT/ROLLBACK 
COMMIT 
---------------------------------------------------------------------------------------------------------------------------------
--Convert dollars to indian rupees and round up to 2 decimal places
/* Price_Starting_With column has value in dollars 
need to write logic to convert price to indian rupees
and round to 2 decimal places
*/
UPDATE tb_rawbooks
SET [Price_Starting_With] = ROUND([Price_Starting_With] * 83,2)
---------------------------------------------------------------------------------------------------------------------------------
-- DROP EXACT DUPLICATES
/*
Noticed there are exact duplicates in tb_rawbooks
*/

Select count(*) as rwcnt,title,category,authors,publisher,publishmonth,publishyearmonth,publishyear
from tb_rawbooks
group by title,category,authors,publisher,publishmonth,publishyearmonth,publishyear
having count(*)>1
ORDER BY rwcnt DESC

/* 
 Method 1. Using CTE and ROW_NUMBER()
 step1. Compute RowNumber and assign different rownumber to duplicate records
 step2. Delete from CTE where RowNumber>1
 step3. These above step deletes duplicate from main table
*/
--Safely begin droping duplicates--
BEGIN Transaction

select count(*) 
from tb_rawbooks
--45956

WITH CTE AS(
	SELECT *,
		ROW_NUMBER() OVER 
		(PARTITION BY title,category,authors,publisher,[Price_Starting_With],publishmonth,publishyear,publishyearmonth 
		ORDER BY (SELECT 0)) AS RwNum
	FROM tb_rawbooks
)
DELETE 
FROM CTE 
WHERE RwNum>1
-- 31 rows dropped

select count(*) 
from tb_rawbooks
--45925

Select count(*) as rwcnt,title,category,authors,publisher,publishmonth,publishyearmonth,publishyear
from tb_rawbooks
group by title,category,authors,publisher,publishmonth,publishyearmonth,publishyear
having count(*)>1
ORDER BY rwcnt DESC
-- no duplicates - delete was success

--COMMIT/ROLLBACK
ROLLBACK


/* 
 Method 2. Using CTE and PHYSLOC
 step1. Compute RowNumber and assign different rownumber to duplicate records
 step2. Delete from CTE where RowNumber>1
 step3. These above step deletes duplicate from main table
*/
--Safely begin droping duplicates--
BEGIN Transaction

select count(*) 
from tb_rawbooks
--45956

WITH CTE1 AS(SELECT *,%%physloc%% as row_id1 from tb_rawbooks),
	 CTE2 AS(SELECT *,%%physloc%% as row_id2 from tb_rawbooks)
DELETE a
FROM CTE1 a, CTE2 b
WHERE a.Title=b.Title AND
a.Authors=b.Authors AND
a.Category=b.Category AND
a.Publisher=b.Publisher AND
a.[Price_Starting_With]=b.[Price_Starting_With] AND
a.[PublishMonth]=b.[PublishMonth] AND
a.[PublishYear]=b.[PublishYear] AND
a.[PublishYearMonth]=b.[PublishYearMonth] AND
a.row_id1>b.row_id2
-- 31 records dropped

select count(*) 
from tb_rawbooks
--45925

Select count(*) as rwcnt,title,category,authors,publisher,publishmonth,publishyearmonth,publishyear
from tb_rawbooks
group by title,category,authors,publisher,publishmonth,publishyearmonth,publishyear
having count(*)>1
ORDER BY rwcnt DESC
-- no duplicates - delete was success

--COMMIT/ROLLBACK
COMMIT
---------------------------------------------------------------------------------------------------------
-- get distinct count of records in each column
Select 'Title' AS ColumnName, 
	count(distinct title) AS DistinctCount, 
	count(title) AS TotalCount 
from tb_rawbooks
-- Title - 43161 - 45925
UNION
Select 'Authors' AS ColumnName, 
	count(distinct authors) AS DistinctCount, 
	count(authors) AS TotalCount 
from tb_rawbooks
-- Authors - 13331 - 45925
UNION
select 'Publisher' AS ColumnName, 
	count(distinct publisher) AS DistinctCount, 
	count(publisher) AS TotalCount 
from tb_rawbooks
-- Publisher - 3259 - 45925
UNION
Select 'Category' AS ColumnName,
	count(distinct Category) AS DistinctCount,
	count(category) AS TotalCount 
from tb_rawbooks
-- Category - 46 - 45925
-----------------------------------------------------------------------------
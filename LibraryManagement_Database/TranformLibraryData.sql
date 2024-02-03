--Creating tables from tb_rawbooks

-- use librarymgmt database 
USE librarymgmt_db
-----------------------------------------------------------------------------------------------------------------------------------
--create tb_books
CREATE TABLE tb_books (
    Book_id INT IDENTITY(10001, 1) PRIMARY KEY,
    Title VARCHAR(250) NOT NULL,
    Author VARCHAR(50) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Publisher VARCHAR(100) NOT NULL,
    Price DECIMAL NOT NULL,
    PublishMonth VARCHAR(10) NOT NULL,
    PublishYear SMALLINT NOT NULL,
    PublishYearMonth INT NOT NULL,
    Created_date DATE DEFAULT GETDATE(),
    Last_modified_date DATETIME2 DEFAULT CURRENT_TIMESTAMP
);

--insert into tb_books table from tb_rawbooks table
INSERT INTO 
	tb_books 
		(Title, Author, Category, Publisher, Price, PublishMonth, PublishYear, PublishYearMonth)
SELECT 
		title, authors, category, publisher, price_starting_with, publishmonth, PublishYear, PublishYearMonth
FROM tb_rawbooks;
--45295 records added

select * from tb_books

UPDATE tb_books
SET Last_modified_date = CURRENT_TIMESTAMP;
--------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE tb_category (
    Category_id INT IDENTITY(101, 1) PRIMARY KEY,
    Category VARCHAR(100) NOT NULL,
    Created_date DATE DEFAULT GETDATE(),
    Last_modified_date DATETIME2 DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO 
	tb_category
		(Category)
select 
distinct category 
from tb_books
order by category asc;

select * from tb_category
---------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE tb_publisher(
    Publisher_id INT IDENTITY(1001, 1) PRIMARY KEY,
    Publisher VARCHAR(100) NOT NULL,
    Created_date DATE DEFAULT GETDATE(),
    Last_modified_date DATETIME2 DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO 
	tb_publisher
		(publisher)
select 
distinct publisher 
from tb_books
order by publisher asc;

select * from tb_publisher
--------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE tb_author(
    Author_id INT IDENTITY(100001, 1) PRIMARY KEY,
    Author VARCHAR(100) NOT NULL,
    Created_date DATE DEFAULT GETDATE(),
    Last_modified_date DATETIME2 DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO 
	tb_author
		(Author)
select 
distinct Author
from tb_books
order by Author asc;

select * from tb_author
----------------------------------------------------------------------------------------------------------------------------
--Add Category_id and remove category, 
--Add references
-- Step 1: Add Category_id column to tb_books
ALTER TABLE tb_books
ADD Category_id INT;

-- Step 2: Update tb_books with Category_id from tb_category
UPDATE tb_books
SET tb_books.Category_id = tb_category.Category_id
FROM tb_books
INNER JOIN tb_category ON tb_books.Category = tb_category.Category;

-- Drop the Category column from tb_books
ALTER TABLE tb_books
DROP COLUMN Category;

-- Add foreign key constraint
ALTER TABLE tb_books
ADD CONSTRAINT FK_tb_books_tb_category
FOREIGN KEY (Category_id)
REFERENCES tb_category(Category_id);
-------------------------------------------------------------------------------------------------------------------------------
--Add Author_id and remove author, 
--Add references
-- Step 1: Add Author_id column to tb_books
ALTER TABLE tb_books
ADD Author_id INT;

-- Step 2: Update tb_books with author_id from tb_author
UPDATE tb_books
SET tb_books.Author_id = tb_author.Author_id
FROM tb_books
INNER JOIN tb_author ON tb_books.author = tb_author.author;

-- Drop the Author column from tb_books
ALTER TABLE tb_books
DROP COLUMN Author;

-- Add foreign key constraint
ALTER TABLE tb_books
ADD CONSTRAINT FK_tb_books_tb_author
FOREIGN KEY (Author_id)
REFERENCES tb_author(Author_id);
---------------------------------------------------------------------------------------------------------------------------------
--Add Publisher_id and remove Publisher, 
--Add references
-- Step 1: Add Publisher_id column to tb_books
ALTER TABLE tb_books
ADD Publisher_id INT;

-- Step 2: Update tb_books with author_id from tb_author
UPDATE tb_books
SET tb_books.Publisher_id = tb_publisher.Publisher_id
FROM tb_books
INNER JOIN tb_publisher ON tb_books.publisher = tb_publisher.publisher;

-- Drop the Author column from tb_books
ALTER TABLE tb_books
DROP COLUMN publisher;

-- Add foreign key constraint
ALTER TABLE tb_books
ADD CONSTRAINT FK_tb_books_tb_publisher
FOREIGN KEY (Publisher_id)
REFERENCES tb_publisher(Publisher_id);
---------------------------------------------------------------------------------------------------------------------------------
select * from tb_books





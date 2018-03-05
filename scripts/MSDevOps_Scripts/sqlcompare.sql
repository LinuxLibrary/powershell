/******create database for testing******/
CREATE DATABASE test
/******make it such that the script uses the database ******/
USE test
/******create main table temp ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp](
	[id] [int] NULL
) ON [PRIMARY]
GO
/****** create comparision table temp2 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp2](
	[id] [int] NULL,
	[name] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO

/****** compare the two tables for column differences ******/
DECLARE @c VARCHAR(30),@tab VARCHAR(30),@typ VARCHAR(30),@sql NVARCHAR(100)

/****** comparision  ******/
SELECT @c=c2.table_name,@tab=c2.COLUMN_NAME ,@typ=c2.data_type FROM [INFORMATION_SCHEMA].[COLUMNS] c2 
WHERE table_name='temp2' 
AND c2.COLUMN_NAME NOT IN 
( SELECT column_name FROM [INFORMATION_SCHEMA].[COLUMNS] where table_name='temp') 

/****** altering the table after comparison ******/
SET @sql='ALTER TABLE temp ADD ' + @tab +' '+ @typ;
EXECUTE sp_executesql @sql;

/****** display the final result ******/
SELECT * FROM temp
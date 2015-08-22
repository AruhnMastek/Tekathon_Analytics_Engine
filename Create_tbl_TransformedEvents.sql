IF OBJECT_ID(N'tbl_TransformedEvents',N'U') IS NOT NULL
	DROP TABLE tbl_TransformedEvents;
GO

CREATE TABLE tbl_TransformedEvents
( 
	 [CustomerID]			BIGINT
    ,[AccountID]			BIGINT
	,[accountType]			VARCHAR(50)
	,[eventDate]			DATETIME
	,[eventTime]			DATETIME
	,[Day]					TINYINT
	,[DayOfWeek]			VARCHAR(50) 
	,[DayOfYear]			INT 
	,[WeekOfYear]			TINYINT
	,[WeekOfMonth]			TINYINT 
	,[WeekOfMonthName]		VARCHAR(50) 
	,[Month_Num]			TINYINT 
	,[MonthName]			VARCHAR(50) 
	,[MonthLabel]			VARCHAR(50)  
	,[Year]					CHAR(4) 
	,[HourOfDay]			TINYINT
	,[HourSlice]			VARCHAR(50)
	,[eventType]			VARCHAR(50)
	,[Amount]				FLOAT
);

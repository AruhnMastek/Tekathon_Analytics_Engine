IF OBJECT_ID(N'tbl_Events',N'U') IS NOT NULL
	DROP TABLE tbl_Events;
GO

CREATE TABLE tbl_Events
( 
	 [CustomerID]			BIGINT
    ,[AccountID]			BIGINT
	,[accountType]			VARCHAR(50)
	,[eventDate]			DATETIME
	,[eventTime]			DATETIME 
	,[eventType]			VARCHAR(50)
	,[Amount]				FLOAT
);



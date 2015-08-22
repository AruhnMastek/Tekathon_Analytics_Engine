IF OBJECT_ID(N'tbl_FridaySpenders',N'U') IS NOT NULL
	DROP TABLE tbl_FridaySpenders;
GO

CREATE TABLE tbl_FridaySpenders ( 
                                  [CustomerID]	BIGINT 
							    );
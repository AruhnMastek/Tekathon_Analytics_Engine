IF OBJECT_ID(N'tbl_Week_1_Spenders',N'U') IS NOT NULL
	DROP TABLE tbl_Week_1_Spenders;
GO

CREATE TABLE tbl_Week_1_Spenders ( 
                                  [CustomerID]	BIGINT 
							     );

IF OBJECT_ID(N'usp_PopulateFridaySpenders',N'P') IS NOT NULL
	DROP PROCEDURE usp_PopulateFridaySpenders;
GO
CREATE PROCEDURE usp_PopulateFridaySpenders ( @DebugMode BIT )    
AS

BEGIN TRY  
         SET NOCOUNT ON;
         
         --DECLARATION   
         DECLARE @ErrorMsg NVARCHAR(2000);
         
         IF @DebugMode = 0
         BEGIN
				IF OBJECT_ID(N'Temp',N'U') IS NOT NULL
				DROP TABLE Temp;

				CREATE TABLE Temp ( Cust_ID BIGINT
				                   ,[DayOfWeek] VARCHAR(50)
								   ,AvgSpend FLOAT
								  );

				INSERT INTO Temp ( Cust_ID
				                  ,[DayOfWeek]
								  ,AvgSpend
								 )
				SELECT T.CustomerID
					  ,T.[DayOfWeek] + 'S' AS [DayOfWeek]
					  ,AVG(T.Amount) AS AvgSpend
				FROM tbl_TransformedEvents T
				WHERE T.eventType = 'WITHDRAWAL'
				AND T.accountType = 'CURRENT'
				AND Amount < (	
								SELECT (AVG(Amount)*2) 
								FROM  tbl_TransformedEvents 
								WHERE eventType = 'WITHDRAWAL' 
								AND accountType = 'CURRENT' 
								)
				GROUP BY T.[DayOfWeek]
						,T.CustomerID


				IF OBJECT_ID(N'FridayData',N'U') IS NOT NULL
				DROP TABLE FridayData;
				CREATE TABLE FridayData ( Cust_ID BIGINT
								         ,FridaySpend FLOAT
								        );

				INSERT INTO FridayData ( Cust_ID
				                        ,FridaySpend
									   )
				SELECT T.CustomerID
					  ,AVG(T.Amount) AS FridaySpend 
				FROM tbl_TransformedEvents T 
				WHERE T.eventType = 'WITHDRAWAL'
				AND T.accountType = 'CURRENT' 
				AND Amount < (	
							SELECT (AVG(Amount)*2) 
							FROM  tbl_TransformedEvents 
							WHERE eventType = 'WITHDRAWAL' 
							AND accountType = 'CURRENT' 
							) 
				AND T.[DayOfWeek] = 'FRIDAY' 
				GROUP BY T.CustomerID
						,T.[DayOfWeek] 



				IF OBJECT_ID(N'Customer_MaxSpend_By_Day',N'U') IS NOT NULL
				DROP TABLE Customer_MaxSpend_By_Day;
				CREATE TABLE Customer_MaxSpend_By_Day ( Cust_ID BIGINT
								                       ,AvgSpend_Max FLOAT
								                      );

				INSERT INTO Customer_MaxSpend_By_Day ( Cust_ID
				                                      ,AvgSpend_Max
									                 )
				SELECT Tm.Cust_ID
					  ,MAX(Tm.AvgSpend) AS AvgSpend_Max
				FROM Temp Tm
				GROUP BY Tm.Cust_ID 


				TRUNCATE TABLE tbl_FridaySpenders;

				INSERT INTO tbl_FridaySpenders (CustomerID)
				SELECT Customer_MaxSpend_By_Day.Cust_ID
				FROM Customer_MaxSpend_By_Day 
				INNER JOIN FridayData ON Customer_MaxSpend_By_Day.Cust_ID = FridayData.Cust_ID
				AND Customer_MaxSpend_By_Day.AvgSpend_Max = FridayData.FridaySpend 
         END
         
         IF @DebugMode = 1
         BEGIN
              PRINT 'Debug mode'
         END
         
END TRY  
BEGIN CATCH 
           SET @ErrorMsg = ' DBName        = ' + DB_NAME()				                                  + CHAR(10) +
                           ' Procedure     = ' + OBJECT_NAME(@@PROCID)                                    + CHAR(10) +
                           ' ErrorNumber   = ' + LTRIM(CONVERT(VARCHAR(9),Error_Number()))                + CHAR(10) +
                           ' ErrorState    = ' + LTRIM(CONVERT(VARCHAR(3),Error_State()))                 + CHAR(10) +
                           ' ErrorSeverity = ' + LTRIM(CONVERT(VARCHAR(3),Error_Severity()))              + CHAR(10) +
                           ' LineNumber    = ' + LTRIM(CONVERT(VARCHAR(9),Error_Line()))                  + CHAR(10) +
                           ' ErrorMessage  = ' + LTRIM(CONVERT(VARCHAR(2047),LEFT(Error_Message(),2044))) + CHAR(10) +
                           ' ErrorDT       = ' + CONVERT(VARCHAR(23),GETDATE(),121)                       + CHAR(10)
           RAISERROR(@ErrorMsg,16,1)
END CATCH;


/*
Sand:

EXEC usp_PopulateFridaySpenders 0

Sample Output:


*/

IF OBJECT_ID(N'usp_Week_1_Spenders',N'P') IS NOT NULL
	DROP PROCEDURE usp_Week_1_Spenders;
GO
CREATE PROCEDURE usp_Week_1_Spenders ( @DebugMode BIT )    
AS

BEGIN TRY  
         SET NOCOUNT ON;
         
         --DECLARATION   
         DECLARE @ErrorMsg NVARCHAR(2000);
         
         IF @DebugMode = 0
         BEGIN
				IF OBJECT_ID(N'Spend_By_Customer_Week',N'U') IS NOT NULL
				DROP TABLE Spend_By_Customer_Week;

				CREATE TABLE Spend_By_Customer_Week ( Cust_ID BIGINT
				                                     ,[WeekOfMonthName] VARCHAR(50)
								                     ,AvgSpend FLOAT
								                    );

				INSERT INTO Spend_By_Customer_Week ( Cust_ID
				                                    ,[WeekOfMonthName]
								                    ,AvgSpend
								                   )
				SELECT T.CustomerID
					  ,T.[WeekOfMonthName]
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
				GROUP BY T.[WeekOfMonthName]
						,T.CustomerID


				IF OBJECT_ID(N'Week_1_Data',N'U') IS NOT NULL
				DROP TABLE Week_1_Data;
				CREATE TABLE Week_1_Data ( Cust_ID BIGINT
								          ,Week_1_Spend FLOAT
								         );

				INSERT INTO Week_1_Data ( Cust_ID
				                         ,Week_1_Spend
									    )
				SELECT T.CustomerID
					  ,AVG(T.Amount) AS Week_1_Spend 
				FROM tbl_TransformedEvents T 
				WHERE T.eventType = 'WITHDRAWAL'
				AND T.accountType = 'CURRENT' 
				AND Amount < (	
							SELECT (AVG(Amount)*2) 
							FROM  tbl_TransformedEvents 
							WHERE eventType = 'WITHDRAWAL' 
							AND accountType = 'CURRENT' 
							) 
				AND T.[WeekOfMonthName] = 'WEEK-1' 
				GROUP BY T.CustomerID
						,T.[DayOfWeek] 



				IF OBJECT_ID(N'Customer_MaxSpend_By_Week',N'U') IS NOT NULL
				DROP TABLE Customer_MaxSpend_By_Week;
				CREATE TABLE Customer_MaxSpend_By_Week ( Cust_ID BIGINT
								                        ,AvgSpend_Max FLOAT
								                       );

				INSERT INTO Customer_MaxSpend_By_Week ( Cust_ID
				                                       ,AvgSpend_Max
									                  )
				SELECT Tw.Cust_ID
					  ,MAX(Tw.AvgSpend) AS AvgSpend_Max
				FROM Spend_By_Customer_Week Tw
				GROUP BY Tw.Cust_ID 


				TRUNCATE TABLE tbl_Week_1_Spenders;

				INSERT INTO tbl_Week_1_Spenders (CustomerID)
				SELECT Customer_MaxSpend_By_Week.Cust_ID
				FROM Customer_MaxSpend_By_Week 
				INNER JOIN Week_1_Data ON Customer_MaxSpend_By_Week.Cust_ID = Week_1_Data.Cust_ID
				AND Customer_MaxSpend_By_Week.AvgSpend_Max = Week_1_Data.Week_1_Spend 
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

EXEC usp_Week_1_Spenders 0

Sample Output:


*/
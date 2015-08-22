IF OBJECT_ID(N'usp_TransformEvents',N'P') IS NOT NULL
	DROP PROCEDURE usp_TransformEvents;
GO
CREATE PROCEDURE usp_TransformEvents ( @DebugMode BIT )    
AS

BEGIN TRY  
         SET NOCOUNT ON;
         
         --DECLARATION   
         DECLARE @ErrorMsg NVARCHAR(2000);
         
         IF @DebugMode = 0
         BEGIN
				TRUNCATE TABLE tbl_TransformedEvents;
				INSERT INTO tbl_TransformedEvents  ( 
													 CustomerID
													,AccountID
													,accountType
													,eventDate
													,eventTime
													,[Day]
													,[DayOfWeek]
													,[DayOfYear]
													,WeekOfYear
													,WeekOfMonth
													,WeekOfMonthName
													,Month_Num
													,[MonthName]
													,MonthLabel
													,[Year]
													,[HourOfDay]
													,[HourSlice]
													,eventType
													,Amount
												   )
				SELECT CustomerID AS CustomerID
					  ,AccountID AS AccountID
					  ,accountType AS [accountType]
					  ,eventDate AS eventDate
					  ,eventTime AS eventTime
					  ,DATEPART(DAY,eventDate) AS [Day]
					  ,CASE DATEPART(DW, eventDate)
							WHEN 1 THEN 'SUNDAY'
							WHEN 2 THEN 'MONDAY'
							WHEN 3 THEN 'TUESDAY'
							WHEN 4 THEN 'WEDNESDAY'
							WHEN 5 THEN 'THURSDAY'
							WHEN 6 THEN 'FRIDAY'
							WHEN 7 THEN 'SATURDAY'
					   END AS [DayOfWeek]
					  ,DATEPART(dy,eventDate) AS [DayOfYear]
					  ,DATEPART(ww,eventDate) AS [WeekOfYear]
					  ,DATEPART(ww,eventDate) + 1 - DATEPART(ww,CAST(DATEPART(mm,eventDate) AS VARCHAR) + '/1/' + CAST(DATEPART(yy,eventDate) AS VARCHAR)) AS [WeekOfMonth]
					  ,'WEEK-' + CAST(DATEPART(ww,eventDate) + 1 - DATEPART(ww,CAST(DATEPART(mm,eventDate) AS VARCHAR) + '/1/' + CAST(DATEPART(yy,eventDate) AS VARCHAR)) AS VARCHAR) AS [WeekOfMonthName]
					  ,DATEPART(MONTH,eventDate) AS [Month_Num]
					  ,UPPER(DATENAME(MONTH,eventDate)) AS [MonthName]
					  ,UPPER(SUBSTRING(DATENAME(MONTH,eventDate),1,3) + '-' + CAST(DATEPART(YEAR,eventDate) AS VARCHAR)) AS [MonthLabel]
					  ,DATEPART(YEAR,eventDate) AS [Year]
					  ,DATEPART(hh,eventTime) AS [HourOfDay]
					  ,CASE WHEN DATEPART(hh, eventTime) BETWEEN 6 AND 8 THEN 'EARLY MORNINGS'
							WHEN DATEPART(hh, eventTime) BETWEEN 9 AND 10 THEN 'MORNINGS'
							WHEN DATEPART(hh, eventTime) BETWEEN 11 AND 13 THEN 'NOON'
							WHEN DATEPART(hh, eventTime) BETWEEN 13 AND 17 THEN 'AFTER NOONS'
							WHEN DATEPART(hh, eventTime) BETWEEN 18 AND 22 THEN 'NIGHTS'
					   END AS [HourSlice]
					  ,[eventType] AS eventType		
					  ,[Amount]	AS Amount
				FROM tbl_Events;
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

EXEC usp_TransformEvents 0

Sample Output:


*/
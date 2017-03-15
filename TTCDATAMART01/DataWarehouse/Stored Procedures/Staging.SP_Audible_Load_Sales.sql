SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_Audible_Load_Sales]
as
Begin

/* Only Inserting Values*/

 insert into Archive.Audible_Sales ([Asin] , [Category] , [Course_ID], [Release_Date], [Report_Month], [Title], [Units], [Revenue])
 select [Asin] , [Category] , [Course_ID], cast([Release_Date] as date)[Release_Date], cast([Report_Month] as date)[Report_Month], [Title], [Units], [Revenue]
 from staging.Audible_ssis_Sales

End
GO

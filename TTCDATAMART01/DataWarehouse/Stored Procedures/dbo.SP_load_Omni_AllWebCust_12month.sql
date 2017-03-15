SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_load_Omni_AllWebCust_12month] @Date datetime = null
As
Begin
/**********************************************************************************************************************************
To Load Omniture Web Customer data for the last 12 month ex: visists,prod views and page views.
**********************************************************************************************************************************/

/* Set Date if not passed as a variable */
	If @Date is null
	Begin
	Set @Date = cast(getdate() as date)
	End

/*Start and End Dates*/
	select dateadd(year, -1, @Date) as StartDate ,@Date as EndDate

	Truncate table Marketing.Omni_AllWebCust_12month

	insert into Marketing.Omni_AllWebCust_12month
	select *  
	from Datawarehouse.Archive.Omni_AllWebCust 
	where VisitDate between dateadd(year, -1, @Date) and @Date

End

GO

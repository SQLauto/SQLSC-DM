SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[spMKT_CreateRFMMovement_New] /*'12/17/2000', '12/24/2000'*/
@PrevDate datetime, 
@EffDate datetime
AS
/*  This procedure is used to create RFM Movement information for the dates
    provided.  The 'out' information appears on the 'prevdate' records
    and the 'in' information on the effective date used
    Date Written: 05/23/2003 tom jones, xsynthesis
    Last Updated: 08/28/2003 tlj - Changed for additional criteria on mail flag, zip code, and state
	          02/27/2004 tlj - Changed join to use 'valid orders' table - recreate if 
				   necessary.
*/
declare @Orders table
(Customerid int,
 MadePurchase int)
Insert into @Orders
Select distinct customerid, 1
from Staging.vworders o
where DateOrdered between @PrevDate + 7 and dateadd(second,-1,@EffDate) + 7 
and netorderamount > 0
and statuscode IN (0, 1, 2, 3, 12, 13) 
/* 02/27/2004 Use new table created to get subset of customers that */
/*            are valid for the current parameters*/
/*            If the table is current (has been updated in the last day)*/
/*            we don't have to recreate*/
declare @AddCustomers int
select @AddCustomers = 0 /* don't  add customers*/
if not exists (select * from Mapping.RFMlkValidCustomers)
	select @AddCustomers = 1
if exists (select * from Mapping.RFMlkValidCustomers
where abs(datediff(day, datecreated, getdate()) ) > 1)
	select @AddCustomers = 1
/*select abs(datediff(day, '11/01/2004', getdate()) ) > 1*/
if @AddCustomers = 1
begin
/*	truncate table RFMlkValidCustomers*/
/*	insert into RFMlkValidCustomers*/

/*
	select c.customerid, DateCreated = getdate()
	from SuperStarDW.dbo.Customers c (nolock)
	join SuperStarDW.dbo.AcctAddress A
	ON C.CustomerID = A.CustomerID
	--inner join rfm.dbo.CustomerSubjectMatrix CSM
	--on C.CustomerID = CSM.CustomerID
	--left join TRITAN_KEEP.dbo.customerinstitution ci (nolock)
	--on c.customerid = ci.customerid
	
	where c.buyertype > 3 AND
		A.UseForBilling = 1 AND
		(A.PostalCode BETWEEN '00500' AND '99999') AND
		A.State IN (Select Region from RFMlkValidRegion) 
		--and isnull(ci.customertype,0) <> 1
		--and isnumeric(left(c.PostalCode,5)) = 1
		--and left(c.PostalCode,5) between '00500' and '99999'
		--and isnull(c.FlagNoMail,'F') in ('F','N')
		--and left(ltrim(rtrim(c.countrycode)),2) = 'US'
		--and c.State in (Select Region from RFMlkValidRegion)

*/

	EXECUTE Staging.spValidCustomers		
		
/*	select count(8) from Mapping.RFMlkValidCustomers	*/
end
		Select FirstRFM , Firsta12mf, LastRFM, Lasta12mf, 
		Purchase = case when MadePurchase = 0 then 0 else 1 end,
		MoveMentCount = count(*),
        FlagDRTV
		into #RFMInfo
		from (		
		Select h.customerid, 
		FirstRFM = max(case when EffectiveDate = @PrevDate then RFM else '' end),
		Firsta12mf = max(case when EffectiveDate = @PrevDate then a12mf else -1 end),
		LastRFM = max(case When EffectiveDate = @EffDate then RFM else '' end),
		Lasta12mf = max(case when EffectiveDate = @EffDate then a12mf else -1 end),
		MadePurchase = max(isnull(o.MadePurchase,0)),
        h.FlagDRTV
		from Archive.RFMHistory h (nolock)
		join Mapping.RFMlkValidCustomers c (nolock)
		/*join MarketingDM.dbo.DMValidCustomers c*/
		/*join rfm.dbo.DMValidCustomers1 c*/
		on h.customerid = c.customerid
--        join Marketing.DMCustomerStatic cs (nolock) on h.CustomerID = cs.CustomerID
		left join @Orders o
		on c.customerid = o.customerid
		where EffectiveDate in (@PrevDate, @EffDate)	
		group by h.customerid, h.FlagDRTV
		) rfminfo
		where FirstRFM <> LastRFM
		or (FirstRFM = LastRFM and Firsta12mf <> Lasta12mf)
	
		group by FirstRFM , Firsta12mf, LastRFM, Lasta12mf, 
		case when MadePurchase = 0 then 0 else 1 end, FlagDRTV
		order by FirstRFM, Firsta12mf, LastRFM, Lasta12mf
	
--if not exists(select * from sysobjects where name = 'rfm_movement_new'
--and type = 'U')
--begin
--	Create Table Staging.rfm_movement_new (
--	EffectiveDate datetime,
--	MovementCategory char(3), /* in or out*/
--	RFM char(7),
--	A12MF int,
--	MovementType varchar(50),
--	MovementCount int)
--end

--truncate table Staging.rfm_movement_new

/* Process the 'Outs'		*/
if exists(select * from Staging.rfm_movement_new where 
	EffectiveDate = @PrevDate and MovementCategory = 'Out')
begin

	delete from Staging.rfm_movement_new where 
	EffectiveDate = @PrevDate and MovementCategory = 'Out'
end


	
Insert into Staging.rfm_movement_new
Select
MovementDate = @PrevDate,
MovementCategory = 'Out',
MovementRFM = FirstRFM,
MovementA12MF = FirstA12MF,
MovementType = case when FirstRFM = '' then 'First Purchase'
	       when FirstRFM <> LastRFM and Purchase = 1 then 'RFM Out Move - Purchase'
	       when FirstRFM <> LastRFM and Purchase = 0 then 'RFM Out Move - Idle'
		/* Now we are equal in RFM - only change a12mf*/
		when Purchase = 0 then 'A12MF Out Move - Idle'
		when Purchase = 1 then 'A12MF Out Move - Purchase'
		else 'Case Not Handled' end,
Totalcount =  sum(MovementCount),
FlagDRTV = FlagDRTV
from #RFMInfo
where FirstRFM <> '' /* if first is blank, then it is a new purhase*/
group by FirstRFM, FirstA12MF, case when FirstRFM = '' then 'First Purchase'
	       when FirstRFM <> LastRFM and Purchase = 1 then 'RFM Out Move - Purchase'
	       when FirstRFM <> LastRFM and Purchase = 0 then 'RFM Out Move - Idle'
		/* Now we are equal in RFM - only change a12mf*/
		when Purchase = 0 then 'A12MF Out Move - Idle'
		when Purchase = 1 then 'A12MF Out Move - Purchase'
		else 'Case Not Handled' end,
        FlagDRTV
order by FirstRFM, FirstA12MF, case when FirstRFM = '' then 'First Purchase'
	       when FirstRFM <> LastRFM and Purchase = 1 then 'RFM Out Move - Purchase'
	       when FirstRFM <> LastRFM and Purchase = 0 then 'RFM Out Move - Idle'
		/* Now we are equal in RFM - only change a12mf*/
		when Purchase = 0 then 'A12MF Out Move - Idle'
		when Purchase = 1 then 'A12MF Out Move - Purchase'
		else 'Case Not Handled' end
/* Process the 'Ins'		*/
if exists(select * from Staging.rfm_movement_new where 
	EffectiveDate = @EffDate and MovementCategory = 'In')
begin
	delete from Staging.rfm_movement_new where 
	EffectiveDate = @EffDate and MovementCategory = 'In'
end
insert into Staging.rfm_movement_new
Select
MovementDate = @EffDate,
MovementCategory = 'In',
MovementRFM = LastRFM,
MovementA12MF = LastA12MF,
MovementType = case when FirstRFM = '' then 'First Purchase'
	       when FirstRFM <> LastRFM and Purchase = 1 then 'RFM In Move - Purchase'
	       when FirstRFM <> LastRFM and Purchase = 0 then 'RFM In Move - Idle'
		/* Now we are equal in RFM - only change a12mf*/
		when Purchase = 0 then 'A12MF In Move - Idle'
		when Purchase = 1 then 'A12MF In Move - Purchase'
		else 'Case Not Handled' end,
MovementCount = sum(MovementCount),
FlagDRTV = FlagDRTV
from #RFMInfo
group by LastRFM, LastA12MF, case when FirstRFM = '' then 'First Purchase'
	       when FirstRFM <> LastRFM and Purchase = 1 then 'RFM In Move - Purchase'
	       when FirstRFM <> LastRFM and Purchase = 0 then 'RFM In Move - Idle'
		/* Now we are equal in RFM - only change a12mf*/
		when Purchase = 0 then 'A12MF In Move - Idle'
		when Purchase = 1 then 'A12MF In Move - Purchase'
		else 'Case Not Handled' end,
        FlagDRTV
order by LastRFM, LastA12MF, case when FirstRFM = '' then 'First Purchase'
	       when FirstRFM <> LastRFM and Purchase = 1 then 'RFM In Move - Purchase'
	       when FirstRFM <> LastRFM and Purchase = 0 then 'RFM In Move - Idle'
		/* Now we are equal in RFM - only change a12mf*/
		when Purchase = 0 then 'A12MF In Move - Idle'
		when Purchase = 1 then 'A12MF In Move - Purchase'
		else 'Case Not Handled' end
/*drop table #rfmInfo*/
/*select * from #RFMInfo*/
GO

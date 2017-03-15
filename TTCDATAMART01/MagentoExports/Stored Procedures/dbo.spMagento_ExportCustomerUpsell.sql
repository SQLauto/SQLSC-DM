SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[spMagento_ExportCustomerUpsell]
AS
/* This routine is used to create the Customer-specific upsell table/file
   for any customers that have changed since the last run of this process
   Date Written: 2014-02-24 tom jones, TGC
   Last Updated: 2014-07-03 tlj correct the delete so that this will run incrementally
*/   
set rowcount 0
truncate table upsellCustomer

Insert into UpsellCustomer
select dw.CustomerID, dw.SegmentGroup
from [DataWarehouse].[Marketing].[Upsell_CustomerSegmentGroup] dw
left join Upsellcustomer_Archive uca
on dw.CustomerID = uca.customerid
where dw.SegmentGroup <> isnull(uca.SegmentGroup,'')

set rowcount 3000
declare @currentcount int = 1
while @currentcount > 0
begin
	delete from UpsellCustomer_Archive
	where customerid in (select dax_customer_id from upsellcustomer)
	set @currentcount = @@ROWCOUNT
end	

set rowcount 0

declare @today datetime

set @today = GETDATE()



if exists(select * from Upsellcustomer)
begin
	insert into UpsellCustomer_Archive
	select *, @today from Upsellcustomer
end
else
begin

	select @today = MAX(dateupdated) from UpsellCustomer_Archive
	
	insert into UpsellCustomer
	select customerid, segmentgroup from UpsellCustomer_Archive
	where DateUpdated = @today
end


declare @count int
select @count = COUNT(*) from UpsellCustomer

Insert into UpsellCustomer values('Expected Records',@count)


GO

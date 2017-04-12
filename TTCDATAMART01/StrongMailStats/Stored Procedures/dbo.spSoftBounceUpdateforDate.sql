SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Procedure [dbo].[spSoftBounceUpdateforDate]
@CurrentDate datetime
AS
/* This routine is used to update the soft bounce table on a given day.
   Date Written: 2009-06-18 tom jones, TTC
   Last Updated: 2009-06-19 tlj Set OutboundIP <> '' so that bounces (which are forwarded) 
			                    are not included.
				 2009-07-15 tlj Added 9999 'mailbox limit' to list since the 'sorry this user has reached
								their mailbox limit' comes in as a 9999
				2012-04-04 tlj Updated for change in column name.
   Taken from the routine is used to automatically update the soft bounce list - and is intended to be run for
   emails sent the day before.  
*/
declare @EmailDate char(12),
	    @Email varchar(100),
		@bounce varchar(1000),
		@bouncetype int,
		@Successdate datetime


	set @EmailDate = '%' + replace(convert(varchar(10),@currentdate,111),'/','-') + '%'
	declare cur_SoftBounce insensitive cursor for
	Select distinct email from sm_aggregate_log
	where logname like @emaildate
	and outboundip <> '' 
	and (logtype in (3001,3002)
		 or (logtype = 9999 and bounce like '%mailbox limit%'))
	open cur_SoftBounce
	fetch next from cur_SoftBounce into @email
	while @@fetch_status = 0
	begin
		if exists (select * from mktSoftBounces where Email = @email)
		begin
			begin
				update MktSoftBounces
				Set SoftBounces = case when @currentdate > LastSoftBounceDate then SoftBounces + 1 else SoftBounces end,
					FirstSoftBounceDate = case when SoftBounces = 0 then @currentdate else FirstSoftBounceDate end,
					LastSoftBounceDate = case when @currentdate > LastSoftBounceDate then @CurrentDate else LastSoftBounceDate end
				where email = @email
				and LastSuccessDate < @currentdate
			end
		end
		else
		begin	
			Select @Successdate = max(datestamp) from sm_success_log where email = @email
			set @SuccessDate = isnull(@SuccessDate,'1/1/1900')
			if @SuccessDate < @currentDate
			begin
				Insert into MktSoftBounces
				(Email, SoftBounces, FirstSoftBounceDate, LastSuccessDate, LastSoftBounceDate)
				values (@Email, 1, @currentdate, @SuccessDate, @currentdate)
			end
			
		end
		fetch next from cur_SoftBounce into @email
	end
	deallocate cur_SoftBounce		



GO
GRANT EXECUTE ON  [dbo].[spSoftBounceUpdateforDate] TO [TEACHCO\OLTP_DATA Group]
GO

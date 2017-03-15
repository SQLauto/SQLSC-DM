SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[sp_CreateAccountsToMerge_CA]
AS
/* This routine is used to create the output file to be used for batch merges in DAX.  
   Date Written: September, 2012 tom jones, TGC./
   Last Updated: 2013-01-09 tlj updated to do multiple passes until complete and update the temp table name.
   */

delete from Staging.tmp_MergeSource_CA where isnull([DoNotMerge],'') <> ''

select [DUPE SEQUENCE] 
into #SingleCustomers
from Staging.tmp_MergeSource_CA 
group by [DUPE SEQUENCE] having COUNT(*) = 1

delete from  Staging.tmp_MergeSource_CA where   [DUPE SEQUENCE] in (
select [DUPE SEQUENCE]from #SingleCustomers)
   

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'MergeList_CA')
	DROP TABLE Staging.MergeList_CA
   
select  [dupe sequence], 
	AcctTo = MIN(convert(int,[account number])), 
	AcctFrom = max(convert(int,[Account number])) , 
	UserCount = count(*)
into Staging.MergeList_CA
from Staging.tmp_MergeSource_CA
group by [dupe sequence]
having COUNT(*) > 1

declare @mergecount int, @passnumber int
set @mergecount = 1
set @passnumber = 2
while @mergecount > 0
begin
      print 'Running pass ' + convert(varchar(4), @passnumber)
      Insert into Staging.MergeList_CA
      select 
			[dupe sequence], 
			AcctTo = MIN([account number]), 
			AcctFrom = max([Account number]) , 
			UserCount = count(*)
      from Staging.tmp_MergeSource_CA
      where [Account number] not in (
      select acctfrom from Staging.MergeList_CA)
      group by [dupe sequence]
      having COUNT(*) > 1
      
      set @mergecount = @@ROWCOUNT
      set @passnumber = @passnumber + 1
end

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'FinalMergeList_CA')
	DROP TABLE Marketing.FinalMergeList_CA
	
select GoodAcct = CONVERT(char(10),AcctTo), DupAcct = CONVERT(char(10),AcctFrom)
into Marketing.FinalMergeList_CA
from Staging.MergeList_CA
order by AcctTo
GO

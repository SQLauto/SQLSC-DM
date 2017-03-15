SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[SP_Directory_UK_PM_Mailfile] @source varchar(1000) output,@dest varchar(1000) output  
as  
  
begin  
  
select top 1 @source = directory from  Mapping.MailHistoryPMCountrySubjectAdcode   
where countrycd='UK' --and PMUpdateflag = 0   
order by 1 desc  
  
/*Keep in same folder*/  
--set  @source ='\\File1\groups\Marketing\MailFiles\2016\PostMergeMailFile\UK_AddedToMHTable'
set @dest = @source  
  
End
GO

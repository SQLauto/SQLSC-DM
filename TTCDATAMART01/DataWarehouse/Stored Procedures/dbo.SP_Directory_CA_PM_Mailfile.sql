SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[SP_Directory_CA_PM_Mailfile] @source varchar(1000) output,@dest varchar(1000) output  
as  
  
begin  
  
select top 1  @source = directory from  Mapping.MailHistoryPMCountrySubjectAdcode   
where countrycd='CA' and PMUpdateflag = 0   
order by 1   
  
/*Keep in same folder*/  
set @dest = @source  
  
End
GO

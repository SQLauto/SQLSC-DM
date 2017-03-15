SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_GA_Load_Visits]
as
Begin
Declare @adcode int      
select @adcode = MAX(adcode)+ 1000  from DataWarehouse.Mapping.vwAdcodesAll           
    
Declare @specialchars varchar(200)  = '%[~,@,#,$,%,&,*,(,),.,!^?:]%'      
          
 
/*Update TGCPLus campaign (Integer)*/    
Update Staging.GA_ssis_visitor     
set Campaign = 
		Case  when LEN(campaign)>10 then 120091 /* Default*/     
         when patindex('%[a-z]%', campaign)> 0 then 120091 /* Default*/            
         when patindex(@specialchars, campaign)> 0 then 120091 /* Default*/    
         when isnull(campaign,'') = '' then 120091 /* Default*/            
		 when ISNUMERIC(campaign)=0 then 120091 /* Default*/
         when cast(campaign as int)> @adcode then 120091 /* Default*/           
         else campaign end              

select Campaign, DATE, [Hour],	[Minute],
sum(convert(int,Sessions)) Sessions
into #Visits
from Staging.GA_ssis_visitor 
group by Campaign, date ,[Hour],	[Minute]

Delete from Marketing.TGCPLus_GA_Visits 
where [DATE] in (select cast (Date as date) from #Visits group by cast (Date as date))

insert into Marketing.TGCPLus_GA_Visits  
select * from #Visits

Drop table #Visits

End
GO

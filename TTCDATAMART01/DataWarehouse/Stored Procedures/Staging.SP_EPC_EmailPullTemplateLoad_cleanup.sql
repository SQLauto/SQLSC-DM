SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [Staging].[SP_EPC_EmailPullTemplateLoad_cleanup]
as
begin

insert into mapping.Email_adcode_Historical 
(EmailID,Adcode,AdcodeName,Startdate,EndDate,Subjectline,SegmentGroup,TestFlag,CourseFlag,MaxCourses,EmailCompletedFlag,Countrycode,split_percentage,primary_adcode,DLRAdcode,DLRFlag,DLRTestFlag,DLRSplit_percentage,lastupdateddate)

select EmailID,Adcode,AdcodeName,Startdate,EndDate,Subjectline,SegmentGroup,TestFlag,CourseFlag,MaxCourses,EmailCompletedFlag,Countrycode,split_percentage,primary_adcode,DLRAdcode,DLRFlag,DLRTestFlag,DLRSplit_percentage,GETDATE() as lastupdateddate 
from mapping.Email_adcode 
where EmailCompletedFlag = 1

insert into Datawarehouse.mapping.Email_WishlistCourses_history  ( [EmailID],[CourseID])
select [EmailID],[CourseID] from Datawarehouse.mapping.Email_WishlistCourses

insert into mapping.Email_landingpage_historical
select *,GETDATE() as archiveddate 
from  mapping.Email_landingpage


insert into mapping.Email_adcode_cyc_historical
select * from mapping.Email_adcode_cyc
where EmailCompletedFlag = 1 

insert into mapping.Email_adcode_Format_historical
select distinct * from mapping.Email_adcode_format
where EmailCompletedFlag = 1

truncate table mapping.Email_adcode

truncate table mapping.Email_landingpage

truncate table mapping.Email_WishlistCourses 

truncate table mapping.Email_adcode_cyc

truncate table mapping.Email_adcode_format

End


GO

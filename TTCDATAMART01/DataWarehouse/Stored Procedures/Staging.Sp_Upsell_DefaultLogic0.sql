SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[Sp_Upsell_DefaultLogic0]  
as  
Begin  
  
/* This Sp is to populate the Default List id = 0 and Customerid = 0*/  
  
Truncate table [Staging].[Logic0ListCourseRank]  
  
--bondugulav 4/12/2017  
--Insert into [Staging].[Logic0ListCourseRank]  
--select 0 as ListID,CourseID,DisplayOrder,UpsellCourseID from  [Staging].[Logic1ListCourseRank] a  
--join   
--(  
--select top 1 listid,count(*)cnt from  [Staging].[Logic1CustomerList]  
--group by listid   
--order by 2 desc  
--)b  
--on a.ListId = b.ListId  
  
/*Do not load Customerid = 0 and listid = 0 as it will cause duplicates in the Customerlist table*/  
--Truncate table [Staging].[Logic0CustomerList]  
--insert into [Staging].[Logic0CustomerList]  
--select 0 as customerid, 0 as listid   
  
--updating list 0 to use code from logic 2 tables. bondugulav 4/12/2017  
--updating list 0 to use code from logic 3 tables. bondugulav 7/21/2017  
  
Insert into [Staging].[Logic0ListCourseRank]  
select 0 as ListID,CourseID,DisplayOrder,UpsellCourseID from  [Staging].[Logic3ListCourseRank] a  
join   
(  
select top 1 listid,count(*)cnt from  [Staging].[Logic3CustomerList]  
group by listid   
order by 2 desc  
)b  
on a.ListId = b.ListId  
where DisplayOrder<=500  

--Code for making Default after Control has been changed
/*
Insert into [Staging].[Logic0ListCourseRank]  
select 0 as ListID,CourseID,DisplayOrder,UpsellCourseID from  [Staging].[Logic3ListCourseRank] a  
join   
(  
select top 1 listid,count(*)cnt from  [Staging].[Logic4CustomerList]  
group by listid   
order by 2 desc  
)b  
on a.ListId = b.ListId  
where DisplayOrder<=500  

Insert into [Staging].[Logic0ListCourseRank]  
select 0 as ListID,CourseID,DisplayOrder,UpsellCourseID from  [Staging].[Logic3ListCourseRank] a  
join   
(  
select top 1 listid,count(*)cnt from  [Staging].[Logic5CustomerList]  
group by listid   
order by 2 desc  
)b  
on a.ListId = b.ListId  
where DisplayOrder<=500  
*/  
  
END
GO

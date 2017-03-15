SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE View [Mapping].[Vw_ConvertalogSubjectCat]  
as  
  
select 'MH' as ConvertalogSubject,'MH,AH' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
UNION  
select 'AH' as ConvertalogSubject,'MH,AH' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
Union  
  
select 'FW' as ConvertalogSubject,'FW' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
UNION  
  
select 'LIT' as ConvertalogSubject,'LIT,VA,MSC' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
UNION  
select 'VA' as ConvertalogSubject,'LIT,VA,MSC' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
UNION  
select 'MSC' as ConvertalogSubject,'LIT,VA,MSC' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
UNION  
  
select 'MTH' as ConvertalogSubject,'MTH,SCI,HS' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
UNION  
select 'SCI' as ConvertalogSubject,'MTH,SCI,HS' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
UNION  
select 'HS' as ConvertalogSubject,'MTH,SCI,HS' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
UNION  
  
select 'EC' as ConvertalogSubject,'EC,PR' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
UNION  
select 'PR' as ConvertalogSubject,'EC,PR' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
Union  
  
select 'PH' as ConvertalogSubject,'PH,RL' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
UNION  
select 'RL' as ConvertalogSubject,'PH,RL' as ConvertalogSubjectCat, 'CONTROL' CustGroup  
  
  
Union  
select 'Humanities' as ConvertalogSubject,'Humanities' as ConvertalogSubjectCat, 'TEST' CustGroup  
UNION  
select 'Culinary Arts' as ConvertalogSubject,'Culinary Arts' as ConvertalogSubjectCat, 'TEST' CustGroup  
UNION  
select 'Health & Wellness' as ConvertalogSubject,'Health & Wellness' as ConvertalogSubjectCat, 'TEST' CustGroup  
UNION  
select 'Photography' as ConvertalogSubject,'Photography' as ConvertalogSubjectCat, 'TEST' CustGroup  
UNION  
select 'Professional' as ConvertalogSubject,'Professional' as ConvertalogSubjectCat, 'TEST' CustGroup  
UNION  
select 'Science & Math' as ConvertalogSubject,'Science & Math' as ConvertalogSubjectCat, 'TEST' CustGroup  
GO

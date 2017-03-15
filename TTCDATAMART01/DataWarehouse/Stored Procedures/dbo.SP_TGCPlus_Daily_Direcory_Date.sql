SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE Proc [dbo].[SP_TGCPlus_Daily_Direcory_Date] @DateFolder varchar(200)=null output                
as                
                
Begin                
                
 Declare @DT Datetime = GETDATE()                 
 select @DateFolder = cast(convert(char(8), @DT, 112) as varchar(10))                
                
/*Drop folder*/                
                
--set @DateFolder = '\\File1\Marketing\Vikram\test\'              
--set @DateFolder = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\SnagFilms\DropFolder\Daily\'              
--set @DateFolder = '\\ttcdatamart01\ETLDax\TGCplus\Daily\'  
--set @DateFolder = '\\file1\ServerRepo\DatamartETL\TGCPLUS\DAILY\'  
set @DateFolder = '\\TTCDMFS01\ServerRepo\DatamartETL\TGCPLUS\DAILY\'  

                
select @DateFolder                
                
                
End 
GO

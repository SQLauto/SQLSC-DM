SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Comcast_Directory] @DateFolder varchar(200)=null output,@ArchiveFolder varchar(200)=null output                   
as                  
                  
Begin                  
                  
 Declare @DT Datetime = GETDATE()                   
 select @DateFolder = cast(convert(char(8), @DT, 112) as varchar(10))                  
   
                  
/*Drop folder*/                  
                  
  
set @DateFolder = '\\TTCDMFS01\ServerRepo\DatamartETL\Comcast\DropFolder'    
  
set @ArchiveFolder = '\\TTCDMFS01\ServerRepo\DatamartETL\Comcast\Archive\'  
select @DateFolder , @ArchiveFolder             
                  
                  
End 
GO

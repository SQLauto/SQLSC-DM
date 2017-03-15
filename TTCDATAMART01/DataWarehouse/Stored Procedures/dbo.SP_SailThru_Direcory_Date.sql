SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_SailThru_Direcory_Date] @DateFolder varchar(200) output    
as    
    
Begin    
    
 Declare @DT Datetime = GETDATE()     
 select @DateFolder = cast(convert(char(8), @DT, 112) as varchar(10))    
    
/*Drop folder*/    
    
set @DateFolder = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\SailThru\DropFolder\' + @DateFolder    
    
select @DateFolder    
    
    
End 
GO

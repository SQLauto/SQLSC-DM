SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_TGC_Affiliate_Directory] @DateFolder varchar(200)=null output,@ArchiveFolder varchar(200)=null output                 
as                
                
Begin                
                
 Declare @DT Datetime = GETDATE()                 
 select @DateFolder = cast(convert(char(8), @DT, 112) as varchar(10))                
 
                
/*Drop folder*/                
                

set @DateFolder = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\ECommerce\Affiliate\DropFolder\'  

set @ArchiveFolder = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\ECommerce\Affiliate\Archive\'
select @DateFolder , @ArchiveFolder           
                
                
End 
GO

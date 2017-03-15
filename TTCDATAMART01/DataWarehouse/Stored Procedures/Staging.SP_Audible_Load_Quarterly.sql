SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_Audible_Load_Quarterly]
as
Begin

/* Only Inserting Values*/

 insert into archive.Audible_Quarterly (Year,Quarter,Marketplace,ProductID,CourseID,DigitalISBN,RoyaltySharepct,Offer,AlaCarteQty,AlaCarteNetSales,AlaCarteRoyalty,
										CashQty,CashNetSales,CashRoyalty,CreditsQty,CreditsNetSales,CreditsRoyalty,TotalQty,TotalNetSales,TotalRoyalty)
 select  cast(left(Quarter,4) as int) as Year,cast(right(Quarter,1) as int) as Quarter,Marketplace,ProductID,CourseID,NULLIF(DigitalISBN,'')DigitalISBN,RoyaltySharepct,Offer,AlaCarteQty,
		 AlaCarteNetSales,AlaCarteRoyalty,CashQty,CashNetSales,CashRoyalty,CreditsQty,
		 CreditsNetSales,CreditsRoyalty,TotalQty,TotalNetSales,TotalRoyalty
 from staging.Audible_ssis_quarterly

End
GO

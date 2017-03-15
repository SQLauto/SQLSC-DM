SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[SP_TGC_Upsell_Contactcenter]
as
Begin

	select dax_customer_id,location_id,test_rank,list_id 
	Into #CustomerList
	from DataWarehouse.Archive.tgc_upsell_customer_list 
	where location_id = 4
	and test_rank = 0


	select list_id,course_id,recommended_course_rank,recommended_course_id 
	Into #ListRank
	from DataWarehouse.Archive.tgc_upsell_product_detail_page
	where course_id = 0

	Begin tran

	Truncate table DataWarehouse.Archive.tgc_upsell_ContactCenter

	insert into DataWarehouse.Archive.tgc_upsell_ContactCenter 
	(list_id,course_id,recommended_course_rank,recommended_course_id)

	select list_id,course_id,recommended_course_rank,recommended_course_id 
	from #ListRank
	order by 1,3


	Truncate table DataWarehouse.Archive.tgc_upsell_customer_list_ContactCenter

	insert into DataWarehouse.Archive.tgc_upsell_customer_list_ContactCenter
	(dax_customer_id,location_id,test_rank,list_id)

	select dax_customer_id,location_id,test_rank,list_id
	from #CustomerList
	order by 1,4


	commit tran


	drop table #CustomerList
	drop table #ListRank

End



 
GO

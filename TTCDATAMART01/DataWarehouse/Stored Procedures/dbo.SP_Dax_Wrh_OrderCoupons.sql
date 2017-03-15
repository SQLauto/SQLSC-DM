SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_Dax_Wrh_OrderCoupons]
as
Begin


--Deletes
delete DM
from datawarehouse.Marketing.DMPurchaseOrderCoupons DM
left join DAXImports..DAX_OrderCouponsExport   ex
on dm.OrderID=ex.salesid and dm.Coupon = ex.Coupon
where ex.salesid is null


--New Inserts
insert into datawarehouse.Marketing.DMPurchaseOrderCoupons
select ex.salesid as OrderID,ex.Coupon,ex.CouponDesc 
from DAXImports..DAX_OrderCouponsExport   ex
left join datawarehouse.Marketing.DMPurchaseOrderCoupons DM
on dm.OrderID=ex.salesid and dm.Coupon = ex.Coupon
where dm.OrderID is null


end

GO

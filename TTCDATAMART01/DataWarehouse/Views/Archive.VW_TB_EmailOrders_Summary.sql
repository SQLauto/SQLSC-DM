SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [Archive].[VW_TB_EmailOrders_Summary]
as
select * from archive.EmailOrders_Summary
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [Archive].[Vw_TGCPlus_ValidUser]
as
SELECT ID as CustomerID FROM DataWarehouse.archive.TGCPlus_User 
WHERE email NOT LIKE '%+%'  AND   email NOT  LIKE '%plustest%'  AND email NOT  LIKE '%teachco%'
GO

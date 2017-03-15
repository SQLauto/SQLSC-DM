SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
 Create Proc [dbo].[SP_Archive_DRTV_Weekly]
 as
 Begin
 insert into archive.DRTV_Weekly
 (Telemarketer, TollFreeNum, Date, MilitaryTime, Response, TotalCounts, DNISCode, ZIP, AreaCode, Output )
 
 select Telemarketer, TollFreeNum, Date, MilitaryTime, Response, TotalCounts, DNISCode, ZIP, AreaCode, Output
 from archive.Vw_DRTV_Weekly
 
 End
GO

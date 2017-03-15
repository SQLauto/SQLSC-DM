SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spMoveWebAccounts]
AS
/* This procedure is used to import the working account info in to the final version.
   Date Written: 2014-05-14 tom jones, TGC
*/
delete from WebAcctInfo_Final
where email in (
select distinct email from tmp_WebAcctInfo_Working)

declare @now datetime = getutcdate()

Insert into WebAcctInfo_Final
select distinct *, @now from tmp_WebAcctInfo_Working
GO

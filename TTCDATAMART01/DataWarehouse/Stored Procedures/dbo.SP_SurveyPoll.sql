SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
create procedure [dbo].[SP_SurveyPoll]
as

begin

declare @BU VARCHAR(50), @SurveyType varchar(50), @table varchar(100)

if @SurveyType='Cover Poll'

exec SP_TGC_CoverPoll


end
GO

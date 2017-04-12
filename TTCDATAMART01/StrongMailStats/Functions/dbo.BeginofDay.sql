SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create FUNCTION [dbo].[BeginofDay]
(@DateValue varchar(50) )
RETURNS datetime
AS  
/* This routine returns the beginning of the day for the date passed
     Date Written: 01/24/2004 tom jones, xsynthesis
*/
BEGIN
Declare @DateReturn datetime,
	@DateHold Datetime

if isdate(@DateValue) = 0 
begin
	select @DateReturn = NULL
end
else
begin
	Select @DateHold = convert(datetime,@DateValue)
	Select @DateReturn = convert(datetime,
	convert(varchar(2), month(@DateHold)) + '/' + 
	convert(varchar(2), day(@DateHold)) + '/' + 
	convert(varchar(4), year(@DateHold)) 
	)
end
Return (@DateReturn)
End
GO

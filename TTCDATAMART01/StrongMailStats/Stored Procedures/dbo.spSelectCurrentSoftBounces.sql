SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[spSelectCurrentSoftBounces]
AS
/* This procedure is used to select current soft bounces that should be unsubscribed in DAX.
   Date Written: 2012-12-10 Fei Xin
   Date Updated: 2013-01-17 Fei Xin: remove CustTable because it is not available on this server ttcsql01
*/   

select rtrim(Email), SoftBounces from mktSoftBounces 
where SoftBounces >= 5
GO

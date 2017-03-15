SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[ProcessOrderItems]
AS
BEGIN
	set nocount on
    
	update oi
	set 
    	oi.ShipDate = 
        case
        	when oi.ShipDateGMT < '1/2/2012' then oi.ShipDateGMT
            else dbo.GMTToLocalDateTime(oi.ShipDateGMT)
        end            
    from Staging.OrderItems oi
END
GO

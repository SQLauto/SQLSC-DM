SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Mapping].[LoadLegacyToDaxMappings]
AS
BEGIN
	set nocount on
    
    truncate table Mapping.LegacyDAX_CardType
    insert into Mapping.LegacyDAX_CardType
    	(LegacyID, DAXID, [Description])
	values
    	(1, 4, 'Visa'),
        (2, 3, 'MasterCard'),
        (3, 1, 'American Express'),
        (4, 2, 'Discover'),
        (5, 9, 'UK Domestic Meastro'),
        (0, 10, 'None'),
        (null, 10, 'None')
    
    truncate table Mapping.LegacyDAX_OrderStatus    
    insert into Mapping.LegacyDAX_OrderStatus
	    (LegacyStatus, DAXStatus, [Description])
	values
    	(0, 1, 'Backorder'),
        (1, 12, 'Pending'),
        (2, 3, 'Invoiced'),
        (3, 3, 'Invoiced'),
        (4, 4, 'Cancelled'),
        (5, 8, 'OnHold'),
        (7, 0, 'None'),        
        (10, 0, 'None'),
        (20, 0, 'None'),
        (40, 0, 'None'),
        (99, 0, 'None'),
        (101, 0, 'None'),
        (102, 0, 'None')

    truncate table Mapping.LegacyDAX_ShipMethodID
    insert into Mapping.LegacyDAX_ShipMethodID
    	(LegacyID, DAXMethod)
	values
    	(0, 'Home'),
        (1, 'Home'),
        (2, 'Home'),
        (3, 'Next Day'),
        (4, 'Express'),
        (5, 'Home'),
        (6, 'FXInt Othe'),
        (8, 'Home'),
        (9, 'UPS'),
        (10, 'UPS1Day'),
        (11, 'UPD2Day'),
        (12, 'USPS PM'),
        (13, 'USPS PM'),
        (14, 'USPS PM'),
        (15, 'DHL Global'),
		(18, 'SmartPost'),
		(21, 'Home'),
		(22, 'Home'),
		(23, 'Home'),
		(31, 'Home')
        
    truncate table Mapping.LegacyDAX_PmtMethodID    
    insert into Mapping.LegacyDAX_PmtMethodID
    	(LegacyID, DAXMethod)
    values
    	('0', 'None'),
       	('1', 'Cash'),
        ('2', 'None'),
        ('3', 'CreditCard'),
        ('4USD', 'Check US'),
        ('4GBP', 'Check UKI'),
        ('4AUD', 'Check AUD'),                
        ('5', 'PurchOrder'),
        ('6', 'None')                        
        
    truncate table Mapping.LegacyDAX_OrderSource
    insert into Mapping.LegacyDAX_OrderSource
    	(OrderSource, [Description])
    values
    	('P', 'Phone'),
       	('W', 'Web'),
        ('V', 'VoiceMail'),
        ('M', 'Mail'),
        ('F', 'Fax'),
        ('E', 'Email'),
        ('X', 'Unknown'),                
        ('C', 'Exchange'),
        ('R', 'Replace'),
        ('D', 'Ven-phone')                      
END
GO

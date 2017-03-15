SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Combine Return and Order information
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2067	07/19/2016	CollinsB		Initial. Created by eBridge, formatting / standardization by BryantJ
------------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW [Amazon].[V_Order_Return_Complete]
AS
	SELECT  o.Order_ID, 
		o.DateKey, 
		o.SenderID, 
		o.ReceiverID, 
		o.TransactionTime, 
		o.DocumentType, 
		o.DocumentID, 
		o.merchant_order_id, 
		o.shipment_id, 
		o.purchase_date, 
		o.payments_date, 
		o.shipment_date, 
		o.reporting_date, 
		o.buyer_email, 
		o.buyer_name, 
		o.buyer_phone_number, 
		o.ship_to_recipient_name, 
		o.ship_to_address_1, 
		o.ship_to_address_2, 
		o.ship_to_address_3, 
		o.ship_to_city, 
		o.ship_to_state, 
		o.ship_to_postal_code, 
		o.ship_to_country, 
		o.ship_to_phone_number, 
		o.bill_to_address_1, 
		o.bill_to_address_2, 
		o.bill_to_address_3, 
		o.bill_to_city, 
		o.bill_to_state, 
		o.bill_to_postal_code, 
		o.bill_to_country, 
		o.carrier, 
		o.tracking_number, 
		o.estimated_arrival_date, 
		o.fulfillment_center_id, 
		o.fulfillment_channel, 
		o.sales_channel, 
		o.delivery_start_date, 
		o.delivery_end_date, 
		o.delivery_time_zone, 
		o.delivery_instructions, 
		o.amazon_order_item_id, 
		o.merchant_order_item_id, 
		o.quantity_shipped, 
		o.currency, 
		o.item_price, 
		o.item_tax, 
		o.shipping_price, 
		o.shipping_tax, 
		o.ship_service_level, 
		o.gift_wrap_price, 
		o.gift_wrap_tax, 
		o.item_promotion_discount, 
		o.gift_wrap_type, 
		o.gift_message_text, 
		o.item_promotion_id, 
		o.ship_promotion_discount, 
		o.ship_promotion_id, 
		o.is_header_record, 
		o.Import_Timestamp, 
		r.Order_Return_ID, 
		r.DateKey AS Return_DateKey, 
		r.return_date, 
		r.amazon_order_id, 
		r.product_sku, 
		r.product_asin, 
		r.product_fnsku, 
		r.product_name, 
		r.quantity AS Returned_Quantity, 
		r.return_fulfillment_center_id, 
		r.return_detailed_disposition, 
		r.return_reason, 
		r.return_status, 
		r.Import_Timestamp AS Return_Import_Timestamp
	FROM Amazon.[Returns] r
		INNER JOIN Amazon.Orders o
			ON o.amazon_order_id = r.amazon_order_id 
				AND o.sku = r.product_sku


GO

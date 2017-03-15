CREATE TABLE [dbo].[Wishlist]
(
[Wishlist_Id] [int] NULL,
[Course_Id] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Wishlist_Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Magento_Customer_Id] [int] NULL,
[DAX_Customer_Id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customer_Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Magento_Email_Address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Visibility] [smallint] NULL,
[Item_Qty] [decimal] (12, 4) NULL,
[Wishlist_Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Product_Qty] [decimal] (12, 4) NULL,
[Qty_Diff] [decimal] (12, 4) NULL,
[Item_Added_Date] [datetime] NULL,
[Last_Modified_Date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

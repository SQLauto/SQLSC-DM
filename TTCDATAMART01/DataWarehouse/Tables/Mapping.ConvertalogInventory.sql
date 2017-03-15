CREATE TABLE [Mapping].[ConvertalogInventory]
(
[VersionID] [int] NOT NULL IDENTITY(1, 1),
[VersionName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustGroup] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVLVGroup] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CouponCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QTY] [int] NULL,
[ConvertalogSubjectCat] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

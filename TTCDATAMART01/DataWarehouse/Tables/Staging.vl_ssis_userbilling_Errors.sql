CREATE TABLE [Staging].[vl_ssis_userbilling_Errors]
(
[ColumnData] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorCode] [int] NULL,
[ErrorColumn] [int] NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__vl_ssis_u__DMlas__06772FB6] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
